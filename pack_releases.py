"""    

    Simple zipping automation for release packages.
    A file named "release_assets.txt" must exist in the same folder as this script.
    If no category is defined, a default "main" name is used.

    RULES
    # is a comment. Must be on its own line.
    Folders will select all files and subfiles.

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

from types import LambdaType
from zipfile import ZipFile
import os
from pathlib import Path
import datetime
import shutil
from enum import Enum

PRINT_ONLY = True
VERBOSE = True
STOP_AFTER_ASSET_COLLECTION = True

# Doesn't work yet
BACKUP_PREVIOUS_RELEASES = True

root = Path(__file__).parent
release = root.joinpath('release/')
# release = root.joinpath('test_release/')

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

#endregion

#region Parsing/Packing

def parse_assets():
    """Parse the release_assets.txt file in the same folder and return the asset paths.

    Returns:
        list[str]: The assets.
    """
    assets:dict[str,list[str]] = {}
    try:
        with open('release_assets.txt', 'r') as file:
            prefix_path = ''
            current_category = 'main'
            assets[current_category] = []
            for line in file:
                line = line.rstrip()
                # Skip comments
                if line.lstrip().startswith('#') or line.strip() == '': continue
                # Create or set a new category
                if line.endswith(':'):
                    category = line.strip()[:-1]
                    current_category = category
                    if not category in assets:
                        assets[category] = []
                    continue
                # Join the given path to the beginning of each subsequent asset
                if line.lstrip().startswith('->'):
                    prefix_path = line.lstrip()[2:]
                    continue
                # Stop prefixing asset paths
                if line.lstrip().startswith('<-'):
                    prefix_path = ''
                    continue
                # Asset line
                #TODO: Support wildcard (*)
                #TODO: Check for asset existence
                path = line
                if prefix_path != '':
                    path = os.path.join(prefix_path, path)
                # if os.path.isdir(path) and not path.endswith(('/','\\')):
                #     path += os.path.sep
                if os.path.isdir(path):
                    assets[category].extend(get_files_in_folder(path, subfolders=True))
                else:
                    assets[category].append(path)
                
        return assets
    except:
        input('Could not open release_assets.txt! Press enter to exit...')

def zip_files(files: 'list[Path]', output_path: Path):
    """Zips a list of files to a given output zip file.

    Args:
        files (list[Path]): The files to zip.
        output_path (Path): The destination for the zip file.
    """
    with ZipFile( output_path , 'w' ) as zip_obj:
        for file in files:
            if file.exists:
                #print(file.relative_to( root ))
                zip_obj.write( file, file.relative_to( root ) )
            else:
                print(f'{file} File Doesn\'t Exist:', file)

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
    
    #for k,v in new_assets.items():
    #    print(k,v)
    #return
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

def copy_unpacked_files(assets: 'list[Path]'):
    """Copies all assets into an unpacked folder in the release directory
    instead of zipping them.

    Args:
        assets (list[Path]): The assets to copy.
    """
    # print(f'Copying {len(assets)} assets.')
    unpacked_path = release.joinpath('unpacked/')
    shutil.rmtree(unpacked_path)
    for asset in assets:
        p = unpacked_path.joinpath(asset.relative_to(root)).parent
        p.mkdir(parents=True, exist_ok=True)
        shutil.copy(asset, p )

def generate_releases():
    asset_categories = parse_assets()
    all_assets:list[Path] = []
    changelog:list[str] = []
    changes = 0

    release.mkdir(parents=False, exist_ok=True)

    for category, assets in asset_categories.items():
        # Remove duplicates and convert to Paths
        assets = list(set(assets))
        assets = [Path(os.path.abspath(x)) for x in assets]
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
            if old.exists():
                os.remove(old)
            os.rename(output, old)
        print(' DONE.')
        
        print(f'Packing {len(assets)} assets...', end='')
        zip_files(assets, output)
        print(' DONE')

        # Compare changes
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
        print('Deleting old zip...', end='')
        if old is not None:
            os.remove(old)
            print(' DONE.')
        else:
            print(' No old zip to delete.')

    # Copy unpacked files
    print(f'Copying {len(assets)} unpacked assets...', end='')
    copy_unpacked_files(all_assets)
    print(' DONE.')
    
    print()

    # Generate changelog
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
    try:
        print()
        assets = parse_assets()
        print_dict(assets)
        generate_releases()
        input('')
    except:
        input('Error...')
