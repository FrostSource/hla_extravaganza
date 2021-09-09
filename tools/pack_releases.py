from types import LambdaType
from zipfile import ZipFile
import tools_base
import os
from pathlib import Path

root = tools_base.addon_dir
release = root.joinpath("release/")

def zip_path(input_path: Path, output_path: Path, filter_func: LambdaType, mode: str = "w"):
    with ZipFile( output_path , mode ) as zip_obj:
        for folder_name, subfolders, filenames in os.walk( input_path ):
            for filename in filenames:
                if filter_func(filename):
                    print(Path( folder_name, filename ).relative_to( root ))
                    zip_obj.write( Path( folder_name, filename ).relative_to( root ) )

if __name__ == '__main__':
    # Prefabs
    output = release.joinpath("prefabs.zip")
    zip_path(root.joinpath("maps/prefabs"), output, lambda fn : ".vmap" in fn and not "example.vmap" in fn)

    # Scripting environment (helpful scripts to start a project with)
    output = release.joinpath("scripting_environment.zip")
    zip_path(root.joinpath("scripts/vscripts/util"), output, lambda fn : ".lua" in fn)
    with ZipFile( output , "a" ) as zip_obj:
        zip_obj.write( Path( root.joinpath("scripts/vlua_globals.lua") ).relative_to( root ) )
