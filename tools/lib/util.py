# https://stackoverflow.com/a/24519338/15190248
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