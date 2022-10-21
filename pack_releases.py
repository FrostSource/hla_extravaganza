"""    

    Simple zipping automation for release packages.
    A file named "release_assets.txt" must exist in the same folder as this script.
    If no category is defined, a default "main" name is used.

    RULES
    # is a comment. Must be on its own line.
    Folders will select all files and subfiles.
    If file is .lua it will be searched for any external references and those will be added.

    Special Symbols
    name:  - Define a release category.
    ->path - Prepend all subsequent paths with this.
    <-     - Stop prepending.
    &name  - Include all paths from a named category in the current category.
    @path  - Pack paths under this path instead of the original path.
             Use @ alone to reset.
    ?path  - Infer paths from files.
             Supported: README.md
    ~path  - Remove path(s) from the current category.

"""

from calendar import c
from types import LambdaType
from zipfile import ZipFile
import os
from pathlib import Path
import datetime
import shutil
from enum import Enum
from typing import Union
from luaparser import ast, astnodes

# TODO: Symbol for packing prefabs into their own zips.
# TODO: Cache Lua externals
# TODO: Only search Lua if using ?

# Script will run without modifying files.
PRINT_ONLY = False

# More text will show.
VERBOSE = False

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

def get_files_in_folder(src, subfolders=False):
    """Get a list of all files in a

    Args:
        src (str): Source path to search.
        subfolders (bool, optional): If subfolders should be searched too. Defaults to False.

    Returns:
        list[str]: List of files found.
    """
    all_files:list[str] = []
    for (dirpath, dirs, files) in os.walk(src):
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

def get_required_from_lua(src:str)->list[str]:
    """Searches a Lua script for any other scripts it calls upon.

    Args:
        src (str): Lua source code string.

    Returns:
        list[str]: List of script files found.
    """
    tree = ast.parse(src)
    required_scripts = []
    for node in ast.walk(tree):
        if isinstance(node, astnodes.Call) and isinstance(node.func, astnodes.Name):
            if node.func.id in lua_funcs:
                for arg in node.args:
                    if isinstance(arg, astnodes.String):
                        s = arg.s
                        fixed = s.removesuffix('.lua').replace('.','/')
                        path = f'scripts/vscripts/{fixed}.lua'
                        required_scripts.append(path)
    return required_scripts

class CMD(Enum):
    NONE          = 0
    CATEGORY      = 1
    APPEND_PATH   = 2
    STOP_APPEND   = 3
    INCL_CATEGORY = 4
    REROUTE_PATH  = 5
    INFER_PATHS   = 6
    REMOVE_PATHS  = 7

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
    
    line = line.strip()
    if line.startswith('"'): line = line[1:]
    if line.endswith('"'): line = line[:-1]

    return command, line


class Asset:
    def __init__(self, path:str, reroute:str=''):
        self.original_path = path
        self.file = Path(path)
        self.reroute = reroute
    
    def get_path(self):
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


def parse_assets():
    """Parse the release_assets.txt file in the same folder and return the asset paths.

    Returns:
        list[str]: The assets.
    """
    asset_categories = AssetCategories()
    try:
        with open('release_assets.txt', 'r') as file:
            prefix_path = ''
            reroute_path = ''
            remove_paths = False
            current_category = 'main'
            asset_categories.add(current_category)
            for line in file:
                # Skip comments and empty
                if line.isspace() or line.lstrip().startswith('#'): continue

                cmd, path = parse_command_line(line)

                match cmd:
                    case CMD.NONE:
                        pass
                    
                    # Create or set a new category
                    case CMD.CATEGORY:
                        current_category = path
                        if not current_category in asset_categories:
                            asset_categories.add(current_category)
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
                        asset_categories[current_category].extend(asset_categories[path])
                        continue

                    case CMD.REROUTE_PATH:
                        reroute_path = path
                        continue

                    case CMD.INFER_PATHS:
                        for file in get_files_in_folder(path, subfolders=True):
                            match os.path.basename(file).lower():
                                case 'readme.md':
                                    asset_categories[current_category].extend(parse_readme(file))
                        continue

                    case CMD.REMOVE_PATHS:
                        remove_paths = True


                # Asset line
                #TODO: Support wildcard (*)

                if prefix_path != '':
                    path = os.path.join(prefix_path, path)

                if os.path.isdir(path):
                    new_assets = [Asset(x, reroute_path) for x in get_files_in_folder(path, subfolders=True)]
                else:
                    new_assets = [Asset(path, reroute_path)]
                
                if remove_paths:
                    asset_categories[current_category].remove_list(new_assets)
                    remove_paths = False
                else:
                    new_scripts = []
                    for asset in new_assets:
                        if asset.file.suffix.lower() == '.lua':
                            with asset.file.open('r') as f:
                                src = f.read()
                            new_scripts.extend([Asset(x) for x in get_required_from_lua(src)])
                    new_assets.extend(new_scripts)
                    asset_categories[current_category].extend(new_assets)

        if VERBOSE: print('Assets collected from release_assets.txt:')
        for category, assets in asset_categories:
            removed = category.verify()

            if VERBOSE:
                print()
                print(f'  {category}:')
                print('    verified:')
                for asset in assets:
                    print(f'      {asset.pretty()}')
                print('    removed:')
                print_list(removed, '      ')
                
        return asset_categories

    except Exception as e:
        raise e
        # template = "\nAn exception of type {0} occurred. Arguments:\n{1!r}"
        # print(template.format(type(e).__name__, e.args))
        # import traceback
        # print(traceback.format_exc())
    # input('Could not open release_assets.txt! Press enter to exit...')

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
