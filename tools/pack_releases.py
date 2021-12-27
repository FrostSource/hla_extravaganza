# Simple zipping automation for release packages.
# In future this should generate checksums and compare differences to output change log.
from types import LambdaType
from zipfile import ZipFile
import tools_base
import os
from pathlib import Path
import datetime
import shutil
import sys, getopt

root = tools_base.addon_dir
release = root.joinpath("release/")

def add_asset(asset_dict: dict, asset_path: Path, title: str):
    asset_dict[asset_path] = title

def get_assets_from_readme(readme_file):
    assets: list[Path] = []
    in_asset_catagory = False
    with open(readme_file) as f:
        for line in f:
            if in_asset_catagory:
                # Break at end of asset catagory.
                if "---" in line:
                    break
                # Get non blank asset lines
                asset = line[1:].strip()
                if asset != "":
                    #print("Asset found:", asset)
                    assets.append(Path(root, asset))
                    #print(Path(root, asset))
            elif "Assets required" in line:
                in_asset_catagory = True
    return assets

def zip_path(input_path: Path, output_path: Path, filter_func: LambdaType, mode: str = "w"):
    with ZipFile( output_path , mode ) as zip_obj:
        for folder_name, subfolders, filenames in os.walk( input_path ):
            for filename in filenames:
                if filter_func(filename):
                    #print(Path( folder_name, filename ).relative_to( root ))
                    zip_obj.write( Path( folder_name, filename ), Path( folder_name, filename ).relative_to( root ) )

def zip_files(files: 'list[Path]', output_path: Path):
    with ZipFile( output_path , "w" ) as zip_obj:
        for file in files:
            if file.exists:
                #print(file.relative_to( root ))
                zip_obj.write( file, file.relative_to( root ) )
            else:
                print("File Doesn't Exist (check readme):", file)

def compare_zips(new_zip: Path, old_zip: Path) -> 'list[str]':
    new_assets = {}
    old_assets = {}
    with ZipFile(new_zip, "r") as zip_obj:
        for info in zip_obj.infolist():
            new_assets[info.filename] = {
                'crc': info.CRC
            }
    with ZipFile(old_zip, "r") as zip_obj:
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
            crc = new_assets[asset]["crc"]
            if crc != old_assets[asset]["crc"]:
                log.append(f"Updated {asset}")
                #print(f"Updated {asset}", crc, old_assets[asset]["crc"])
            else:
                #print(f"No change for {asset}")
                pass
            # Remove from old_assets so we end up with any assets deleted
            old_assets.pop(asset)
        else:
            log.append(f"Created {asset}")
            #print(f"Created {asset}")
    
    for asset in old_assets:
        log.append(f"Deleted {asset}")
        #print(f"Deleted {asset}")
    
    # Remove duplicates and sort
    log = list(set(log))
    log.sort()

    return log

def copy_unpacked_files(assets: 'list[Path]'):
    print(f"Copying {len(assets)} assets.")
    for asset in assets:
        p = root.joinpath(Path("release/unpacked/").joinpath(asset.relative_to(root)).parent)
        #print( p )
        p.mkdir(parents=True, exist_ok=True)
        shutil.copy(asset, p )

# Packing

def pack_prefabs(no_pack = False):
    title = "prefabs"
    print(f"Doing {title}")
    # Handle file creation and renaming
    output = release.joinpath(f"{title}.zip")
    if not no_pack:
        if not output.exists():
            with ZipFile(output, "w"): pass
        old = release.joinpath(f"{title}.zip.old")
        print(f"Renaming old {title} release...")
        if old.exists():
            os.remove(old)
        os.rename(output, old)

    # Find all assets from readmes
    print("Finding prefab assets...")
    assets: "list[Path]" = []
    for folder_name, subfolders, filenames in os.walk( root.joinpath("maps/prefabs") ):
        for filename in filenames:
            if filename == "README.md":
                assets.extend(get_assets_from_readme(Path(folder_name, filename)))
    # Used to remove duplicates
    assets = list(set(assets))

    # Writing all assets to zip
    if not no_pack:
        print("Packing prefabs...")
        zip_files(assets, output)

    copy_unpacked_files(assets)

    # Compare changes
    if not no_pack:
        print("Comparing zips...")
        log = compare_zips(output, old)
        if len(log) > 0:
            changelog.append("**Prefabs:**")
            for message in log:
                changelog.append("- " + message)
            changelog.append("")

    # Clean up
    if not no_pack:
        print("Deleting old zip...")
        os.remove(old)

    print("DONE")

def pack_scripting_environment(no_pack = False):
    title = "scripting_environment"
    print(f"Doing {title}")
    # Handle file creation and renaming
    output = release.joinpath(f"{title}.zip")
    if not no_pack:
        if not output.exists():
            with ZipFile(output, "w"): pass
        old = release.joinpath(f"{title}.zip.old")
        print(f"Renaming old {title} release...")
        if old.exists():
            os.remove(old)
        os.rename(output, old)

    # Find all utility scripts
    print("Finding scripting_environment assets...")
    assets: "list[Path]" = []
    for folder_name, subfolders, filenames in os.walk( root.joinpath("scripts/vscripts/util") ):
        for filename in filenames:
            if ".lua" in filename and not "__test" in filename:
                assets.append(Path(folder_name, filename))
    # Find all vscode files
    for folder_name, subfolders, filenames in os.walk( root.joinpath("scripts/.vscode") ):
        for filename in filenames:
            assets.append(Path(folder_name, filename))
    # Add global script
    assets.append(root.joinpath("scripts/vlua_globals.lua"))
    # Used to remove duplicates
    assets = list(set(assets))

    # Writing all assets to zip
    if not no_pack:
        print("Packing scripting_environment...")
        zip_files(assets, output)
    
    copy_unpacked_files(assets)

    # Compare changes
    if not no_pack:
        print("Comparing zips...")
        log = compare_zips(output, old)
        if len(log) > 0:
            changelog.append("**Scripting Environment:**")
            for message in log:
                changelog.append("- " + message)
            changelog.append("")

    # Clean up
    if not no_pack:
        print("Deleting old zip...")
        os.remove(old)
    print("DONE")

def pack_fgd(no_pack = False):
    title = "fgd"
    print(f"Doing {title}")
    # Handle file creation and renaming
    output = release.joinpath(f"{title}.zip")
    if not no_pack:
        if not output.exists():
            with ZipFile(output, "w"): pass
        old = release.joinpath(f"{title}.zip.old")
        print(f"Renaming old {title} release...")
        if old.exists():
            os.remove(old)
        os.rename(output, old)

    # Find all utility scripts
    print("Finding fgd assets...")
    assets: "list[Path]" = []
    assets.append( root.joinpath("fgd/hlvr.fgd") )
    assets.append( root.joinpath("fgd/base.fgd") )
    # Used to remove duplicates
    assets = list(set(assets))

    # Writing all assets to zip
    # Files are not relative to addon so can't be packed normally
    if not no_pack:
        print("Packing scripting_environment...")
        with ZipFile( output , "w" ) as zip_obj:
            zip_obj.write( root.joinpath("fgd/hlvr.fgd"), "Half-Life Alyx\\game\\hlvr\\hlvr.fgd" )
            zip_obj.write( root.joinpath("fgd/base.fgd"), "Half-Life Alyx\\game\\core\\base.fgd" )
    
    copy_unpacked_files(assets)

    # Compare changes
    if not no_pack:
        print("Comparing zips...")
        log = compare_zips(output, old)
        if len(log) > 0:
            changelog.append("**FGD:**")
            for message in log:
                changelog.append("- " + message)
            changelog.append("")

    # Clean up
    if not no_pack:
        print("Deleting old zip...")
        os.remove(old)
    print("DONE")

if __name__ == '__main__':
    no_pack = False
    opts, args = getopt.getopt(sys.argv[1:], "", ["nopack"])
    for opt, arg in opts:
        if opt == "--nopack":
            print("--No pack mode. Assets will not be packed.")
            no_pack = True

    changelog = []
    pack_prefabs(no_pack)
    pack_scripting_environment(no_pack)
    pack_fgd(no_pack)

    if not no_pack and len(changelog) > 0:
        with open(root.joinpath("release/changelog.txt"), "a") as file:
            file.write(datetime.datetime.now().date().strftime("%d/%m/%y") + ":\n\n")
            for message in changelog:
                file.write(message + "\n")
            file.write("\n")
    else:
        print("No changes.")
