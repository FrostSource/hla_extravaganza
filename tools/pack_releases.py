# Simple zipping automation for release packages.
# In future this should generate checksums and compare differences to output change log.
from types import LambdaType
from zipfile import ZipFile
import tools_base
import os
from pathlib import Path

root = tools_base.addon_dir
release = root.joinpath("release/")

def get_assets_from_readme(readme_file):
    assets: list[str] = []
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
                    print("Asset found:", asset)
                    assets.append(asset)
            elif "Assets required" in line:
                in_asset_catagory = True
    return assets

                

def zip_path(input_path: Path, output_path: Path, filter_func: LambdaType, mode: str = "w"):
    with ZipFile( output_path , mode ) as zip_obj:
        for folder_name, subfolders, filenames in os.walk( input_path ):
            for filename in filenames:
                if filter_func(filename):
                    #print(Path( folder_name, filename ).relative_to( root ))
                    zip_obj.write( Path( folder_name, filename ).relative_to( root ) )

if __name__ == '__main__':
    # Prefabs
    output = release.joinpath("prefabs.zip")
    # assets are grabbed from readme now
    #zip_path(root.joinpath("maps/prefabs"), output, lambda fn : ".vmap" in fn and not "example.vmap" in fn)
    # Find all assets from readmes
    assets: "list[str]" = []
    for folder_name, subfolders, filenames in os.walk( root.joinpath("maps/prefabs") ):
        for filename in filenames:
            if filename == "README.md":
                assets.extend(get_assets_from_readme(Path(folder_name, filename)))
    assets = list(set(assets))
    # Writing all assets to zip
    with ZipFile( output , "w" ) as zip_obj:
        for asset in assets:
            asset = root.joinpath(asset)
            if asset.exists():
                zip_obj.write( asset,  asset.relative_to(root))
            else:
                print("File Doesn't Exist (check readme):", asset)


    # Scripting environment (helpful scripts to start a project with)
    output = release.joinpath("scripting_environment.zip")
    zip_path(root.joinpath("scripts/vscripts/util"), output, lambda fn : ".lua" in fn)
    with ZipFile( output , "a" ) as zip_obj:
        zip_obj.write( Path( root.joinpath("scripts/vlua_globals.lua") ).relative_to( root ) )

    # FGD
    output = release.joinpath("fgd.zip")
    with ZipFile( output , "w" ) as zip_obj:
        zip_obj.write( Path( root.joinpath("fgd/hlvr.fgd") ), "Half-Life Alyx\\game\\hlvr\\hlvr.fgd" )
        zip_obj.write( Path( root.joinpath("fgd/base.fgd") ), "Half-Life Alyx\\game\\core\\base.fgd" )
