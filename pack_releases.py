"""    
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    Simple zipping automation for release packages.
    A file named "release_assets.txt" must exist in the same folder as this script.
    If no category is defined, a default "main" name is used.
    
# RULES
# is a comment. Must be on its own line.
# Folders will select all files and subfiles.
# * is a wildcard matching any character.
#
# Special Symbols
# name:         - Define a release category.
# ~path         - Remove path(s) from the current category.
# ->path        - Prepend all subsequent paths with this when adding them to a category.
# <-            - Stop prepending.
# &name         - Include all paths from a named category in the current category.
# @path         - Pack paths under this path instead of its original path.
#                 Use @ on its own to reset.
# ?path         - Infer paths from files.
#                 Supported: README.md
# [exclude]path - Exclude this path when searching wildcard files.
# [readme]text  - Adds a line of text to a readme that will be zipped in this category.
#                 Escape sequences are consumed and must be taken into account.

"""

# TODO: Symbol for packing any file found from a single path line into their own zip inside the main zip (+)
# TODO: Only search Lua if using (?)
# TODO: Generalize the language to simplify rules

from glob import glob
import re
import sys
from zipfile import ZipFile
import os
from pathlib import Path
import datetime
import shutil
from enum import Enum
from typing import Union
from luaparser import ast, astnodes
import argparse
import time

from tools.lib.util import decode_escapes, print_list
import tools.lib.addon as addon
import tools.lua_doc_to_html as luadoc

release_path = addon.root.joinpath('release/')

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive

#region Parsing

def parse_readme(path):
    """Parses a README.md to find any asset paths.

    Args:
        path (str): Path to the README.md

    Returns:
        list[str]: List of assets.
    """
    assets:list[str] = []
    with open(path, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith('-'):
                line = line[1:]
                line = line.strip()
            if os.path.exists(line):
                assets.append(line)
    return assets


# Lua functions that call for an external script.
lua_funcs = [
    'require',
    'ifrequire',
    'IncludeScript',
    'DoIncludeScript',
    'entity',
    # 'inherit'
]

lua_cached_files:dict[str,list[str]] = {}

def get_required_from_lua(lua_file:str)->list[str]:
    """Searches a Lua script for any other scripts it calls upon.

    Args:
        lua_file (str): Path to the Lua file.

    Returns:
        list[str]: List of script files found.
    """
    if not os.path.exists(lua_file): return []
    abspath = os.path.abspath(lua_file)
    # Return cached files instead of re-parsing the script
    if abspath in lua_cached_files:
        return list(lua_cached_files[abspath])
    # Get the source string
    with open(lua_file) as f:
        src = f.read()
    tree = ast.parse(src)
    lua_cached_files[abspath] = []
    for node in ast.walk(tree):
        if isinstance(node, astnodes.Call) and isinstance(node.func, astnodes.Name):
            if node.func.id in lua_funcs:
                for arg in node.args:
                    if isinstance(arg, astnodes.String):
                        s = arg.s
                        fixed = s.removesuffix('.lua').replace('.','/')
                        path = f'scripts/vscripts/{fixed}.lua'
                        lua_cached_files[abspath].append(path)
    return list(lua_cached_files[abspath])

class CMD(Enum):
    NONE          = 0
    CATEGORY      = 1
    APPEND_PATH   = 2
    STOP_APPEND   = 3
    INCL_CATEGORY = 4
    REROUTE_PATH  = 5
    INFER_PATHS   = 6
    REMOVE_PATHS  = 7
    EXCLUDE_PATH  = 8
    README_TEXT   = 9

def parse_command_line(line:str):
    """Gets a command and path from a command line.

    Args:
        line (str): Command line.

    Returns:
        CMD: Command found.
        str: Path.
    """
    line = line.strip()
    command:CMD = CMD.NONE
    if line.endswith(':'):
        command = CMD.CATEGORY
        line = line[:-1]
    elif line.startswith('->'):
        command = CMD.APPEND_PATH
        line = line[2:]
    elif line.startswith('<-'):
        command = CMD.STOP_APPEND
        line = ''
    elif line.startswith('&'):
        command = CMD.INCL_CATEGORY
        line = line[1:]
    elif line.startswith('@'):
        command = CMD.REROUTE_PATH
        line = line[1:]
    elif line.startswith('?'):
        command = CMD.INFER_PATHS
        line = line[1:]
    elif line.startswith('~'):
        command = CMD.REMOVE_PATHS
        line = line[1:]
    elif line.startswith('[exclude]'):
        command = CMD.EXCLUDE_PATH
        line = line[9:]
    elif line.lower().startswith('[readme]'):
        command = CMD.README_TEXT
        line = line[8:]
    
    line = line.strip()
    if line.startswith('"'): line = line[1:]
    if line.endswith('"'): line = line[:-1]

    return command, line


class Asset:
    def __init__(self, path:str, reroute:str=''):
        self.original_path = path
        self.file = Path(path)
        self.reroute = reroute
        self.name = self.file.name
    
    def get_path(self)->Path:
        """Get the path of this asset, taking reroutes into account.

        Returns:
            Path: Path asset should be at.
        """
        if self.has_reroute():
            return Path(os.path.join(self.reroute, self.file.name))
        else:
            return self.file

    def exists(self)->bool:
        """Get if the asset exists on disk.

        Returns:
            bool: If asset exists.
        """
        return os.path.exists(self.original_path)
    
    def relative_to(self, other):
        return self.file.absolute().relative_to(os.path.abspath(other))
    
    def has_reroute(self)->bool:
        """Get if this asset has a reroute.
        Can also do if asset.reroute:

        Returns:
            bool: Asset has reroute.
        """
        return self.reroute != ''
    
    def __eq__(self, other):
        if isinstance(other, Asset):
            other = other.original_path
        elif not isinstance(other, str):
            return False
        return os.path.realpath(self.original_path) == os.path.realpath(other)

    def __str__(self):
        return str(self.file)
    
    def __repr__(self) -> str:
        return f'Asset({self.file.parent.name}/{self.name})'
    
    def pretty(self):
        if self.has_reroute():
            return f'{self.file} -> {self.get_path()}'
        else:
            return str(self.file)
    
    def clone(self):
        return Asset(self.original_path, self.reroute)

class AssetCategory:
    def __init__(self, name:str, assets:list[Asset]=[]):
        self.name = name
        self.category = name
        self.assets = list(assets)

        self._index = -1
        self._iterlist = []
    
    def add(self, asset:Asset|str, reroute:str=''):
        """Add a new asset to this category if it doesn't exist.

        Args:
            asset (Asset|str): Either an existing asset or a path to a file.
            reroute (str, optional): If `asset` is a string then the reroute can be defined. Defaults to ''.
        """
        if isinstance(asset, str):
            asset = Asset(asset, reroute)
        if asset not in self.assets:
            self.assets.append(asset)
    
    def remove_list(self, assets:list[str]):
        for asset in self.assets:
            for remove_asset in assets:
                if remove_asset == asset:
                    self.assets.remove(asset)

    def extend(self, category:Union['AssetCategory',list[str]]):
        for asset in category:
            if isinstance(asset, Asset):
                self.add(asset.clone())
            elif isinstance(asset, str):
                self.add(Asset(asset))
    
    def verify(self)->list[Asset]:
        """Removes any assets in the category which don't exist.

        Returns:
            _type_: _description_
        """
        
        removed = []
        for x in self.assets:
            if not x.exists(): removed.append(x)
        self.assets[:] = [x for x in self.assets if x.exists()]
        return removed
    
    def __contains__(self, item:Asset|str):
        if isinstance(item, str): item = Asset(item)
        return item in self.assets
    
    def __iter__(self):
        self._iterlist = list(self.assets)
        self._index = -1
        return self
    
    def __next__(self):
        self._index += 1
        if self._index >= len(self._iterlist):
            self._index = -1
            raise StopIteration
        else:
            return self._iterlist[self._index]
    
    def __str__(self):
        return self.name
    
    def __repr__(self) -> str:
        return f'AssetCategory({self.name}, {len(self.assets)})'

class AssetCategories():
    def __init__(self, categories:list[AssetCategory] = []):
        self.categories:list[AssetCategory] = categories

        self._index = -1

    def add(self, category:AssetCategory|str):
        if isinstance(category, str):
            category = AssetCategory(category)
        self.categories.append(category)

    def verify(self):
        for category in self.categories:
            category.verify()
        
    def all_assets(self) -> list[Asset]:
        all: list[Asset] = []
        for category in self.categories:
            for asset in category.assets:
                if asset not in all:
                    all.append(asset)
        return all
    
    def __contains__(self, item):
        for category in self.categories:
            if category.name == item:
                return True
        return False

    def __getitem__(self, key):
        for category in self.categories:
            if category.name == key:
                return category
        raise KeyError
    
    def __iter__(self):
        self._index = -1
        return self
    
    def __next__(self):
        self._index += 1
        if self._index >= len(self.categories):
            self._index = -1
            raise StopIteration
        else:
            return self.categories[self._index], self.categories[self._index].assets

readme_text:dict[str,str] = {}

def parse_assets():
    """Parse the release_assets.txt file in the same folder and return the asset paths.

    Returns:
        list[str]: The assets.
    """
    asset_categories = AssetCategories()
    with open('release_assets.txt', 'r') as file:
        prefix_path = ''
        reroute_path = ''
        remove_paths = False
        current_category_name = 'main'

        asset_categories.add(current_category_name)
        for line in file:
            # Skip comments and empty
            if line.isspace() or line.lstrip().startswith('#'): continue

            cmd, path = parse_command_line(line)

            match cmd:
                case CMD.NONE:
                    pass
                
                # Create or set a new category
                case CMD.CATEGORY:
                    current_category_name = path
                    if not current_category_name in asset_categories:
                        asset_categories.add(current_category_name)
                    continue

                # Join the given path to the beginning of each subsequent asset
                case CMD.APPEND_PATH:
                    prefix_path = path
                    continue
                # Stop prefixing asset paths
                case CMD.STOP_APPEND:
                    prefix_path = ''
                    continue

                case CMD.INCL_CATEGORY:
                    asset_categories[current_category_name].extend(asset_categories[path])
                    continue

                case CMD.REROUTE_PATH:
                    reroute_path = path
                    continue

                case CMD.INFER_PATHS:
                    for file in addon.find_content_files(os.path.join(path, '*.md')):
                        asset_categories[current_category_name].extend(parse_readme(file))
                    continue

                case CMD.REMOVE_PATHS:
                    remove_paths = True
                
                case CMD.EXCLUDE_PATH:
                    addon.exclude_content_files(path)
                    continue
                
                case CMD.README_TEXT:
                    if not current_category_name in readme_text:
                        readme_text[current_category_name] = ''
                    if readme_text[current_category_name] != '': readme_text[current_category_name] += '\n'
                    readme_text[current_category_name] += decode_escapes(path)
                    continue


            # Asset line

            if prefix_path != '':
                path = os.path.join(prefix_path, path)

            new_assets = [Asset(x, reroute_path) for x in addon.find_content_files(path)]
            
            if remove_paths:
                asset_categories[current_category_name].remove_list(new_assets)
                remove_paths = False
            else:
                new_scripts = []
                for asset in new_assets:
                    if asset.file.suffix.lower() == '.lua':
                        new_scripts.extend([Asset(x) for x in get_required_from_lua(asset.original_path)])
                new_assets.extend(new_scripts)
                asset_categories[current_category_name].extend(new_assets)

    if VERBOSE: print('Assets collected from release_assets.txt:')
    for category, assets in asset_categories:
        removed = category.verify()

        if VERBOSE:
            print()
            print(f'  {category}:')
            print('    README:')
            if category.name in readme_text:
                print('    ' + readme_text[category.name])
            print('    verified:')
            for asset in assets:
                print(f'      {asset.pretty()}')
            print('    removed:')
            print_list(removed, '      ')
            
    return asset_categories

#endregion Parsing

def zip_files(assets: 'list[Asset]', output_path: Path):
    """Zips a list of files to a given output zip file.

    Args:
        files (list[Path]): The files to zip.
        output_path (Path): The destination for the zip file.
    """
    with ZipFile( output_path , 'w' ) as zip_obj:
        for asset in assets:
            if asset.exists():
                zip_obj.write( asset.file, os.path.relpath(asset.get_path(), addon.root) )
            else:
                print(f'{asset} File Doesn\'t Exist:', asset)

def compare_zips(new_zip: Path, old_zip: Path|None) -> 'list[str]':
    """Compares two zip files and returns a readable log of changes to the files.

    Args:
        new_zip (Path): The new zip that might have changes to it.
        old_zip (Path): The old zip of similar structure.

    Returns:
        list[str]: List of changes.
    """
    log = []
    new_assets = {}
    old_assets = {}
    with ZipFile(new_zip, 'r') as zip_obj:
        for info in zip_obj.infolist():
            new_assets[info.filename] = {
                'crc': info.CRC
            }
    if old_zip is not None and os.path.exists(old_zip):
        with ZipFile(old_zip, 'r') as zip_obj:
            for info in zip_obj.infolist():
                old_assets[info.filename] = {
                    'crc': info.CRC
                }

    for asset in new_assets:
        # If this asset is in the old assets then it might be updated
        if asset in old_assets:
            # If CRC is different then it was updated
            crc = new_assets[asset]['crc']
            if crc != old_assets[asset]['crc']:
                log.append(f'Updated {asset}')
                #print(f'Updated {asset}', crc, old_assets[asset]['crc'])
            else:
                #print(f'No change for {asset}')
                pass
            # Remove from old_assets so we end up with any assets deleted
            old_assets.pop(asset)
        else:
            log.append(f'Created {asset}')
            #print(f'Created {asset}')
    
    for asset in old_assets:
        log.append(f'Deleted {asset}')
        #print(f'Deleted {asset}')
    
    # Remove duplicates and sort
    log = list(set(log))
    log.sort()

    return log

def copy_unpacked_files(assets: 'list[Asset]'):
    """Copies all assets into an unpacked folder in the release directory
    instead of zipping them.

    Args:
        assets (list[Path]): The assets to copy.
    """
    # print(f'Copying {len(assets)} assets.')
    unpacked_path = release_path.joinpath('unpacked/')
    if not PRINT_ONLY:
        if unpacked_path.exists():
            shutil.rmtree(unpacked_path)
    if VERBOSE: print('')
    for asset in assets:
        rel = os.path.relpath(asset.get_path(), addon.root)
        p = unpacked_path.joinpath(rel).parent
        if VERBOSE: print(f'  Copying unpacked file {asset.file.name} to {os.path.relpath(p, addon.root)}')
        if not PRINT_ONLY:
            p.mkdir(parents=True, exist_ok=True)
            shutil.copy(asset.file, p )
            pass

def generate_releases(asset_categories:AssetCategories):
    changelog:list[str] = []
    changes = 0

    print()

    if not PRINT_ONLY:
        release_path.mkdir(parents=False, exist_ok=True)

    for category, assets in asset_categories:

        if len(assets) == 0:
            print(f'Category "{category}" has no assets, skipping...')
            continue

        print(f'Preparing category "{category}"...', end='')

        output = release_path.joinpath(f'{category}.zip')

        # Create backup of previous release
        old = None
        if output.exists():
            old = output.with_suffix(output.suffix + '.old')
            print(f' Renaming previous {category} release for comparing...',end='')
            if not PRINT_ONLY:
                if old.exists():
                    os.remove(old)
                os.rename(output, old)
        print(' DONE.')
        
        print(f'Packing {len(assets)} assets...', end='')
        if not PRINT_ONLY:
            zip_files(assets, output)
            if category.name in readme_text:
                with ZipFile( output , 'a' ) as zip_obj:
                    zip_obj.writestr('readme.txt', readme_text[category.name])
        print(' DONE')

        # Compare changes
        if not PRINT_ONLY:
            print('Comparing zips...', end='')
            # if old is not None:
            log = compare_zips(output, old)
            changes += len(log)
            if len(log) > 0:
                changelog.append(f'**{category}.zip**')
                for message in log:
                    changelog.append('- ' + message)
                changelog.append('')
            print(f' Found {len(log)} changes.')
            # else:
                # print(' No previous zip to compare to.')

        # Clean up
        if not PRINT_ONLY:
            print('Deleting old zip...', end='')
            if old is not None:
                os.remove(old)
                print(' DONE.')
            else:
                print(' No old zip to delete.')
    
    print()

    # Generate changelog
    if not PRINT_ONLY:
        print('Generating changelog...', end='')
        if len(changelog) > 0:
            with open(release_path.joinpath('changelog.txt'), 'a') as file:
                file.write(datetime.datetime.now().date().strftime('%d/%m/%y') + ':\n\n')
                for message in changelog:
                    file.write(message + '\n')
                file.write('\n')
            print(f' {changes} total changes.')
        else:
            print(' No changes.')
    
    print('\nFinished generating all releases!')


# Hardcoded for now, consider extracting to file
readme_paths = [
    'scripts/vscripts',
    'scripts/vscripts/data',
    'scripts/vscripts/debug',
    'scripts/vscripts/extensions',
    'scripts/vscripts/math',
    'scripts/vscripts/util',
]

def generate_script_readmes():
    for path in readme_paths:
        if USE_TEST_RELEASE:
            output = addon.root.joinpath('test_release/readmes',path,'README.md')
        else:
            output = Path(path).joinpath('README.md')
        luas = [f for f in glob(os.path.join(path,'*.lua')) if not os.path.basename(f).startswith('__test')]
        if len(luas) > 0:
            print(f'Generating readme in "{os.path.relpath(output.parent, addon.root)}" for {len(luas)} Lua files... ', end='')
            doc = ''
            prev_doc = ''
            for lua in luas:
                doc += f'---\n\n{luadoc.lua_file_to_html(lua)}\n\n'
            if os.path.exists(output):
                with open(output, 'r') as f:
                    prev_doc = f.readlines()
            if not ''.join(prev_doc[2:]) == doc:
                with open(output, 'w') as f:
                    f.write(f'> Last Updated {datetime.datetime.now().strftime("%Y-%m-%d")}\n\n{doc}')
                print('DONE')
            else:
                print('NO CHANGES')

def file_mimetype(file) -> str:
    match os.path.splitext(file)[1]:
        case '.fgd'|'.lua'|'.md'|'.py'|'.gitignore'|'.gitattributes'|'.bat'|'.yaml':
            return 'text/plain'
        case '.json'|'.code-snippets'|'.vrman'|'.vsndevts'|'.vmdl'|'.vmat'|'.rect':
            return 'text/plain'
        case _:
            return None
            # This is invalid apparently
            # return 'application/vnd.google-apps.unknown'

if __name__ == '__main__':

    try:
        parser = argparse.ArgumentParser(
            prog = 'pack_releases',
            description='Packs release assets into zips and generates readmes'
        )
        parser.add_argument('--debug', action='store_true', help='print information without actually modifying files')
        parser.add_argument('--verbose', action='store_true', help='print more information')
        parser.add_argument('--pack', action='store_true', help='pack release assets into zips')
        parser.add_argument('--copy', action='store_true', help='copy release assets to release folder')
        parser.add_argument('--readmes', action='store_true', help='readmes will be generated')
        parser.add_argument('--testrelease', action='store_true', help='files will be generated in test_release folder')
        parser.add_argument('--pause', action='store_true', help='wait for input after finishing')
        parser.add_argument('--upload', action='store_true', help='upload assets to google drive')

        args = parser.parse_args()

        # Script will run without modifying files
        PRINT_ONLY = args.debug
        # More text will show
        VERBOSE = args.verbose
        # Assets will get packed into zips
        PACK_ASSETS = args.pack
        # Assets get copied to a folder
        COPY_UNPACKED_ASSETS = args.copy
        # Readmes are written into the script folders outside the release folder
        GENERATE_READMES = args.readmes
        # Release folder is 'test_release/'
        USE_TEST_RELEASE = args.testrelease
        # Console won't exit immediately
        PAUSE_AT_END = args.pause
        # BACKUP_PREVIOUS_RELEASES = False
        UPLOAD_TO_DRIVE = args.upload

        # UPLOAD_TO_DRIVE = True
        # VERBOSE = True
        # USE_TEST_RELEASE = True

        if USE_TEST_RELEASE:
            release_path = addon.root.joinpath('test_release/')

        print()

        if not PACK_ASSETS\
        and not GENERATE_READMES\
        and not COPY_UNPACKED_ASSETS\
        and not PRINT_ONLY\
        and not PAUSE_AT_END\
        and not UPLOAD_TO_DRIVE\
        :
            parser.print_help()
            exit()

        print('Parsing release assets... ', end='')
        sys.stdout.flush()
        asset_categories = parse_assets()
        print('DONE\n')

        if PACK_ASSETS:
            generate_releases(asset_categories)
            pass

        all = asset_categories.all_assets()

        if COPY_UNPACKED_ASSETS:
            print(f'Copying {len(all)} unpacked assets...', end='')
            sys.stdout.flush()
            copy_unpacked_files(all)
            print(' DONE.')
        if GENERATE_READMES:
            generate_script_readmes()
            pass

        if UPLOAD_TO_DRIVE:
            print(f'\nUploading {len(all)} assets to google drive... ', end='')
            upload_time_start = time.time()
            gauth = GoogleAuth()
            if gauth.credentials is None:
                print('Google Drive waiting for authorization...')
                gauth.LocalWebserverAuth()
            elif gauth.access_token_expired:
                print('Google Drive token expired, refreshing...')
                gauth.Refresh()
            else:
                gauth.Authorize()
            gauth.SaveCredentialsFile('credentials.json')
            drive = GoogleDrive(gauth)
            if VERBOSE: print()
            for asset in all:
                lastid = '1SCVtkcVs6I3Gwhqqehh7NsR74qs_fAq-'
                rel = asset.relative_to(addon.root)
                print(f'  Uploading "{rel}" ... ', end='')
                sys.stdout.flush()
                for folder in rel.parts:
                    if folder == rel.name: break
                    # Check if the folder exists before creating new one
                    file_list = drive.ListFile({"q": f"title='{folder}' and '{lastid}' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false"}).GetList()
                    if not file_list:
                        lastfile = drive.CreateFile({
                            'title': str(folder),
                            'parents': [{'id': lastid}],
                            'mimeType': 'application/vnd.google-apps.folder'
                        })
                        lastfile.Upload()
                    else:
                        lastfile = file_list[0]
                    lastid = lastfile['id']
                # Upload actual file
                file_list = drive.ListFile({"q": f"title='{asset.name}' and '{lastid}' in parents and trashed=false"}).GetList()
                if not file_list:
                    gfile = drive.CreateFile({
                        'title': asset.name,
                        'parents': [{'id': lastid}],
                    })
                else:
                    gfile = file_list[0]
                if mime := file_mimetype(asset.name):
                    gfile['mimeType'] = mime
                gfile.SetContentFile(str(asset.file))
                gfile.Upload()
                print('DONE')
            print(f'DONE - Time taken: {time.time() - upload_time_start}')
            
        if PAUSE_AT_END:
            input("Press enter to exit...")
            
    except Exception as e:
        import traceback
        print(traceback.format_exc())
        input("Press enter to exit...")
