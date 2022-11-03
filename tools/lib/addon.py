
from pathlib import Path

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
