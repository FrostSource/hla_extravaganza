
from pathlib import Path
import os
from fnmatch import fnmatch
from typing import AnyStr

__script_dir = Path(__file__)

name = ''
script_is_in_content:bool = None
content_path:Path = None
game_path:Path = None

# This is the current base addon path that the script has been found in
# actual content/game paths will be resolved from this
root:Path = None

__p = __script_dir.parent
while __p.name != '':
    if __p.parent.name == 'hlvr_addons':
        name = __p.name
        root = __p
    elif __p.parent.name == 'Half-Life Alyx':
        if __p.name == 'content':
            script_is_in_content = True
            content_path = root
        elif __p.name == 'game':
            script_is_in_content = False
            game_path = root
        # Break here unless folders above are important
        break
    __p = __p.parent

if script_is_in_content:
    # Find game path
    game_path = content_path.joinpath(f'../../../game/hlvr_addons/{name}')
else:
    # Find content path
    content_path = game_path.joinpath(f'../../../content/hlvr_addons/{name}')

content_path = content_path.resolve()
game_path = game_path.resolve()

__ignore_paths = [
    '.git'
]

# Get all addon files
def __get_files(start: str) -> list[Path]:
    file_list: list[Path] = []
    for dirpath, dirs, files in os.walk(start):
        dirs[:] = [d for d in dirs if d not in __ignore_paths]
        file_list.extend([Path(os.path.join(dirpath, file)) for file in files])
    return file_list

content_files = __get_files(content_path)
game_files = __get_files(game_path)

def find_files(files: list[Path|str], pattern: AnyStr, relative_to: Path|str = content_path):
    if os.path.isdir(pattern): pattern = os.path.join(pattern, '*')
    return [str(file) for file in files if fnmatch(file.relative_to(relative_to), pattern)]

def exclude_files(files: list[Path|str], pattern: AnyStr|list[AnyStr], relative_to: Path|str = content_path) -> list[Path|str]:
    if isinstance(pattern, str):
        pattern = [pattern]
    pattern = [os.path.join(p, '*') if os.path.isdir(p) else p for p in pattern]
    return [file for file in files if not any(fnmatch(file.relative_to(relative_to), p) for p in pattern)]

def find_content_files(pattern: AnyStr):
    return find_files(content_files, pattern, relative_to=content_path)

def find_game_files(pattern: AnyStr):
    return find_files(game_files, pattern, relative_to=game_path)

def exclude_content_files(pattern: AnyStr):
    global content_files
    content_files = exclude_files(content_files, pattern, content_path)

def exclude_game_files(pattern: AnyStr):
    global game_files
    game_files = exclude_files(game_files, pattern, content_path)
