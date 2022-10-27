"""    
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    Simple zipping automation for release packages.
    A file named "release_assets.txt" must exist in the same folder as this script.
    If no category is defined, a default "main" name is used.
    
# RULES
# is a comment. Must be on its own line.
# Folders will select all files and subfiles.
# * is a wildcard matching any character but is only valid for paths being added/removed from a category.
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

import re
from zipfile import ZipFile
import os
from pathlib import Path
import datetime
import shutil
from enum import Enum
from typing import Union
from luaparser import ast, astnodes

# https://stackoverflow.com/a/24519338/15190248
# Extract below into a separate script
import re
import codecs
ESCAPE_SEQUENCE_RE = re.compile(r'''
    ( \\U........      # 8-digit hex escapes
    | \\u....          # 4-digit hex escapes
    | \\x..            # 2-digit hex escapes
    | \\[0-7]{1,3}     # Octal escapes
    | \\N\{[^}]+\}     # Unicode characters by name
    | \\[\\'"abfnrtv]  # Single-character escapes
    )''', re.UNICODE | re.VERBOSE)
def decode_escapes(s):
    def decode_match(match):
        return codecs.decode(match.group(0), 'unicode-escape')
    return ESCAPE_SEQUENCE_RE.sub(decode_match, s)

# Script will run without modifying files.
PRINT_ONLY = False

# More text will show.
VERBOSE = True

# Script will not enter the packing stage.
# Used for debug.
STOP_AFTER_ASSET_COLLECTION = False

# Doesn't work yet
BACKUP_PREVIOUS_RELEASES = True

root = Path(__file__).parent
# release = root.joinpath('release/')
release = root.joinpath('test_release/')

#region Utility

def print_list(l:list, prefix='>>'):
    """Prints all items in a list.

    Args:
        l (list): List to print.
        prefix (str, optional): Prefix for each item. Defaults to '>>'.
    """
    for x in l:
        print(f'{prefix}{x}')

def print_dict(d:dict):
    """Prints all items in a dictionary.

    Args:
        d (dict): Dictionary to print.
    """
    for k,v in d.items():
        print(str(k) + ':')
        if isinstance(v, list): print_list(v, '\t')
        else: print(f'\t{v}')

def get_files_in_folder(src, subfolders=False, ignore:list[str]=[]):
    """Get a list of all files in a

    Args:
        src (str): Source path to search.
        subfolders (bool, optional): If subfolders should be searched too. Defaults to False.

    Returns:
        list[str]: List of files found.
    """
    ignore = [os.path.normpath(x) for x in ignore]
    all_files:list[str] = []
    for (dirpath, dirs, files) in os.walk(src):
        if not [x for x in ignore if os.path.normpath(dirpath).startswith(x)]:
            for f in files:
                all_files.append(os.path.join(dirpath,f))
        if not subfolders: break
    return all_files

def verify_paths(paths:list[str]):
    """Removes any paths that don't exist and returns the removed paths.

    Args:
        paths (list[str]): Paths to verify.

    Returns:
        list[str]: Removed paths.
    """
    removed:list[str] = []
    for x in paths:
        if not os.path.exists(x):
            removed.append(x)
    paths[:] = [x for x in paths if os.path.exists(x)]
    return removed

#endregion

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
        # print(f'GOT CACHE {lua_file}')
        return list(lua_cached_files[abspath])
    # Get the source string
    # print(f'ACTUALLY PARSING {lua_file}')
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

def parse_wildcard_path(path:str):
    # Handle any wildcards
    if '*' in path:
        # Replace separators with regex version
        # line = line.replace('/', os.path.sep).replace('\\', os.path.sep)
        path = '[\\\\/]'.join([re.escape(x) for x in re.split('\\/', path)])
        # Replace wildcard with regex version
        path = '.*'.join(path.split('\\*'))
    return path


class Asset:
    def __init__(self, path:str, reroute:str=''):
        self.original_path = path
        self.file = Path(path)
        self.reroute = reroute
    
    def get_path(self)->Path:
        """Get the path of this asset, taking reroutes into account.

        Returns:
            Path: Path asset should be at.
        """
        if self.has_reroute():
            return Path(os.path.join(self.reroute, self.file.name))
            # return Path(self.reroute)
        else:
            return self.file

    def exists(self)->bool:
        """Get if the asset exists on disk.

        Returns:
            bool: If asset exists.
        """
        return os.path.exists(self.original_path)
    
    def relative_to(self, other):
        return self.file.relative_to(other)
    
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
        return os.path.normpath(self.original_path) == os.path.normpath(other)

    def __str__(self):
        return str(self.file)
    
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
    
    def add(self, asset:Union[Asset,str], reroute:str=''):
        """Add a new asset to this category if it doesn't exist.

        Args:
            asset (Union[Asset,str]): Either an existing asset or a path to a file.
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
    
    def __contains__(self, item:Union[Asset,str]):
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

class AssetCategories():
    def __init__(self, categories:list[AssetCategory] = []):
        self.categories:list[AssetCategory] = categories

        self._index = -1

    def add(self, category:Union[AssetCategory,str]):
        if isinstance(category, str):
            category = AssetCategory(category)
        self.categories.append(category)

    def verify(self):
        for category in self.categories:
            category.verify()
    
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
        exclude_paths = []

        all_addon_files = get_files_in_folder('.', subfolders=True, ignore=exclude_paths)
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
                    for file in get_files_in_folder(path, subfolders=True):
                        match os.path.basename(file).lower():
                            case 'readme.md':
                                asset_categories[current_category_name].extend(parse_readme(file))
                    continue

                case CMD.REMOVE_PATHS:
                    remove_paths = True
                
                case CMD.EXCLUDE_PATH:
                    if not path in exclude_paths:
                        exclude_paths.append(path)
                    # Recapture addon files, can be improved by just removing matching paths
                    all_addon_files = get_files_in_folder('.', subfolders=True, ignore=exclude_paths)
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

            if '*' in path:
                path = parse_wildcard_path(path)
                new_assets = []
                for file in all_addon_files:
                    if re.findall(path, file, re.I):
                        new_assets.append(Asset(file))
            elif os.path.isdir(path):
                new_assets = [Asset(x, reroute_path) for x in get_files_in_folder(path, subfolders=True)]
            else:
                new_assets = [Asset(path, reroute_path)]
            
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


def zip_files(assets: 'list[Asset]', output_path: Path):
    """Zips a list of files to a given output zip file.

    Args:
        files (list[Path]): The files to zip.
        output_path (Path): The destination for the zip file.
    """
    with ZipFile( output_path , 'w' ) as zip_obj:
        for asset in assets:
            if asset.exists():
                #print(file.relative_to( root ))
                # zip_obj.write( file.get_path(), file.relative_to( root ) )
                zip_obj.write( asset.file, asset.get_path() )
            else:
                print(f'{asset} File Doesn\'t Exist:', asset)

def compare_zips(new_zip: Path, old_zip: Path) -> 'list[str]':
    """Compares two zip files and returns a readable log of changes to the files.

    Args:
        new_zip (Path): The new zip that might have changes to it.
        old_zip (Path): The old zip of similar structure.

    Returns:
        list[str]: List of changes.
    """
    new_assets = {}
    old_assets = {}
    with ZipFile(new_zip, 'r') as zip_obj:
        for info in zip_obj.infolist():
            new_assets[info.filename] = {
                'crc': info.CRC
            }
    with ZipFile(old_zip, 'r') as zip_obj:
        for info in zip_obj.infolist():
            old_assets[info.filename] = {
                'crc': info.CRC
            }

    log = []
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
    unpacked_path = release.joinpath('unpacked/')
    if not PRINT_ONLY:
        if unpacked_path.exists():
            shutil.rmtree(unpacked_path)
    for asset in assets:
        # p = unpacked_path.joinpath(asset.relative_to(root)).parent
        p = unpacked_path.joinpath(asset.get_path()).parent
        if VERBOSE: print(f'Copying unpacked file {asset.file.name} to {p}\n')
        if not PRINT_ONLY:
            p.mkdir(parents=True, exist_ok=True)
            shutil.copy(asset.file, p )

def generate_releases(asset_categories:AssetCategories):
    all_assets:list[Asset] = []
    changelog:list[str] = []
    changes = 0

    print()

    if not PRINT_ONLY:
        release.mkdir(parents=False, exist_ok=True)

    for category, assets in asset_categories:
        # Collect all assets for unpacked
        all_assets.extend(assets)

        if len(assets) == 0:
            print(f'Category "{category}" has no assets, skipping...')
            continue

        print(f'Preparing category "{category}"...', end='')

        output = release.joinpath(f'{category}.zip')

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
            if old is not None:
                log = compare_zips(output, old)
                changes += len(log)
                if len(log) > 0:
                    changelog.append(f'**{category}.zip**')
                    for message in log:
                        changelog.append('- ' + message)
                    changelog.append('')
                print(f' Found {len(log)} changes.')
            else:
                print(' No previous zip to compare to.')

        # Clean up
        if not PRINT_ONLY:
            print('Deleting old zip...', end='')
            if old is not None:
                os.remove(old)
                print(' DONE.')
            else:
                print(' No old zip to delete.')

    # Copy unpacked files
    print(f'Copying {len(all_assets)} unpacked assets...', end='')
    copy_unpacked_files(all_assets)
    print(' DONE.')
    
    print()

    # Generate changelog
    if not PRINT_ONLY:
        print('Generating changelog...', end='')
        if len(changelog) > 0:
            with open(release.joinpath('changelog.txt'), 'a') as file:
                file.write(datetime.datetime.now().date().strftime('%d/%m/%y') + ':\n\n')
                for message in changelog:
                    file.write(message + '\n')
                file.write('\n')
            print(f' {changes} total changes.')
        else:
            print(' No changes.')
    
    print('\nFinished generating all releases!')

#endregion

if __name__ == '__main__':
        print()
        asset_categories = parse_assets()
        if not STOP_AFTER_ASSET_COLLECTION:
            generate_releases(asset_categories)
