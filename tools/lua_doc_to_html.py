# Simple html table generation of lua docs for github readmes.

from collections import OrderedDict
import os
from pathlib import Path
# import pyperclip as pc
import re
# Better way to import relative module? Python seems to be dumb
if __name__ == '__main__':
    from lib.parsing import StringParser
else:
    from .lib.parsing import StringParser

file_template = '''## {} ({})\n\n{}\n\n'''
table_template = '''<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr>{}</table>'''
function_template = '''<tr><td>\n\n`{}`</td><td>{}</td></tr>'''

def parse_multiline_comment(parser:StringParser)->str:
    comment = ''
    if not parser.skip_word('--[['):
        return ''
    
    while not parser.skip_word(']]'):
        comment += parser.next()
    return comment

def whitespace_count(whitespace:str)->tuple[int,int,int]:
    """Returns the number of spaces, tabs, newlines in a string.

    Args:
        whitespace (str): String the check.

    Returns:
        tuple[int,int,int]: Spaces, tabs, newlines.
    """
    return (whitespace.count(' '), whitespace.count('\t'), whitespace.count('\n'))

def parse_header(src: str)-> tuple[str, str, str]:

    parser = StringParser(src)
    m = parser.regex(r"v(\d+\.\d+\.\d+).*")
    version = ''
    if m is None:
        return
    version = m[1]
    
    website = ''
    m = parser.regex(r"(https?(://)?.+)")
    if m is not None:
        website = m[1]

    header = ''
    inside_code_block = False
    # Amount of whitespace to subtract from the line (for lua code blocks)
    subtracted_whitespace = ''
    count = 0
    # Any empty lines after an initial empty line are ignored
    ignore_extra_lines = False

    # Avoid leading whitespace
    parser.skip_whitespace()

    while not parser.finished():
        whitespace = parser.skip_whitespace(['\n'])
        line = parser.skip_line()
        count += 1

        if inside_code_block:
            if line.startswith('```'):
                header += f'```\n'
                subtracted_whitespace = ''
                inside_code_block = False
            else:
                repl = whitespace.replace(subtracted_whitespace, "", 1)
                header += f'{repl}{line}\n'

        elif line.startswith('```lua'):
            subtracted_whitespace = whitespace
            header += f'\n\n```lua\n'
            inside_code_block = True
            ignore_extra_lines = False

        # Parse line separator
        elif re.match(r'---+', line):
            header += '\n----\n'
            ignore_extra_lines = False

        # Parse header separator
        elif m := re.match(r'[-=]+\s*([\w\s]+)\s*[-=]+', line):
            header += f'### {m[1]}\n'
            ignore_extra_lines = False

        else:
            if line == '':
                if not ignore_extra_lines:
                    header += '\n\n'
                ignore_extra_lines = True
            else:
                ignore_extra_lines = False
                if line[0].isdigit() and line[1:3] == '. ':
                    header += f'{line}\n'
                else:
                    header += f'{line} '

    return header, version, website

class LuaParam:
    def __init__(self, name:str, types:list[str], is_optional:bool, comment:str):
        self.name = name
        self.types = list(types)
        self.is_optional = is_optional if is_optional else False
        self.comment = comment or ''
    
    def type_str(self)->str:
        return '|'.join(self.types)

    def valve_str(self)->str:
        if self.is_optional:
            return f'[{self.type_str()} <i>{self.name}</i>]'
        else:
            return f'{self.type_str()} <i>{self.name}</i>'
    
    def emmylua_str(self)->str:
        if self.name == '...':
            return f"{self.name}{'?' if self.is_optional else ''}{self.type_str()}"
        else:
            return f"{self.name}{'?' if self.is_optional else ''}: {self.type_str()}"
    
    def simple_str(self)->str:
        return f"{self.name}{'?' if self.is_optional else ''}"
    
    def __str__(self):
        return f'---@param {self.name}{"?" if self.is_optional else ""} {"|".join(self.types)} {"# "+self.comment if self.comment else ""}'

class LuaReturn:
    def __init__(self, types:list[str], name:str, is_optional:bool, comment:str):
        self.types = types
        self.name = name or ''
        self.is_optional = is_optional if is_optional else False
        self.comment = comment or ''
    
    def type_str(self)->str:
        return '|'.join(self.types)
    
    def __str__(self):
        return f'---@return {"|".join(self.types)}{"?" if self.is_optional else ""} {self.name} {"# "+self.comment if self.comment else ""}'

class LuaFunction:
    def __init__(self, name:str, params:list[LuaParam], returns:list[LuaReturn], is_generic:bool, doc_lines:list[str]):
        self.name = name
        self.params:OrderedDict[str,LuaParam] = {}
        for param in params:
            self.params[param.name] = param
        self.returns = list(returns) or [LuaReturn(['nil'], '', False, '')]
        self.is_generic = is_generic
        self.doc_lines = list(doc_lines)
    
    def doc_str(self)->str:
        """Returns the documentation string for the function.

        Returns:
            str: _description_
        """
        return ' '.join(self.doc_lines)
    
    def valve_str(self)->str:
        return f"{'|'.join([s.type_str() for s in self.returns])} {self.name}({', '.join([p.valve_str() for p in self.params.values()])})"
    
    def emmylua_str(self)->str:
        return f"{self.name}({', '.join([param.emmylua_str() for param in self.params.values()])}) -> {'|'.join([ret.type_str() for ret in self.returns])}"

    def simple_str(self)->str:
        #TODO: Make generalized function for this if
        ps = ', '.join([param.simple_str() for param in self.params.values()])
        if len(ps) > 90: ps = ',\n'.join([param.simple_str() for param in self.params.values()])
        if len(self.returns) == 1 and len(self.returns[0].types) == 1 and self.returns[0].types[0] == 'nil':
            return f"{self.name}({ps})"
        else:
            return f"{self.name}({ps}) -> {'|'.join([ret.type_str() for ret in self.returns])}"

    def __str__(self)->str:
        s = ''
        s += '\n'.join(['---'+doc for doc in self.doc_lines])
        s += '\n'
        s += '\n'.join([str(param) for param in self.params.values()])
        s += '\n'
        s += '\n'.join([str(ret) for ret in self.returns])
        s += '\n'
        s += f'{self.name}({", ".join(self.params.keys())})'
        return s
        

def combine(*regex:str)->str:
    return r'[ ]*'.join(regex)

def combine2(*regex:str)->str:
    return r'\s*'.join(regex)

def optional(regex:str)->str:
    return f'({regex})?'

def capture(name:str, regex:str)->str:
    return f'(?P<{name}>{regex})'

def zeroormore(regex:str)->str:
    return f'({regex})*'

def oneormore(regex:str)->str:
    return f'({regex})+'

def eitheror(*regex:str)->str:
    return f'({r"|".join(regex)})'

regex_comment = r'(#[ ]*(?P<comment>.+))?'
regex_identifier = r'[\w\d]+'
regex_types = r'[^\s\?]+'
regex_types_comment = r'(#?[ ]*(?P<comment>.+))?'
regex_param = combine(
    capture('name', regex_identifier + r'|\.\.\.') + optional(capture('name_optional', r'\?')),
    capture('types', regex_types) + optional(capture('types_optional', r'\?')),
    regex_types_comment
)
regex_return = combine(
    capture('types', regex_types) + optional(capture('types_optional', r'\?')),
    optional(capture('name', regex_identifier)) + optional(capture('name_optional', r'\?')),
    regex_types_comment
)
regex_generic = combine(
    capture('type', regex_identifier),
    optional(capture('types', r':' + regex_types)),
    regex_types_comment
)
regex_function = combine(
    capture('name', regex_identifier + optional(r'[:\.]' + regex_identifier)),
    combine2(r'\(', optional(capture('params', combine2(eitheror(regex_identifier,'\.\.\.') + zeroormore(combine2(r',', eitheror(regex_identifier,'\.\.\.')))) )), r'\)')
)

def parse_lua_file(file:str)->tuple[list[LuaFunction],str,str]:
    with open(file, 'r') as f:
        src = f.read()
    parser = StringParser(src)
    parser.whitespace_chars = [' ', '\t', '\r', '\n']

    header = ''
    version = ''
    website = ''

    if comment := parse_multiline_comment(parser):
        header, version, website = parse_header(comment)

    current_params:list[LuaParam] = []
    current_returns:list[LuaReturn] = []
    current_doclines:list[str] = []
    is_generic = False

    functions:list[LuaFunction] = []

    luadoc_ignore = False
    
    while not parser.finished():
        if parser.peek() == '\n':
            parser.next()
            current_params.clear()
            current_returns.clear()
            current_doclines.clear()
            is_generic = False

        if parser.skip_word('---@param '):
            param = parser.regex(regex_param)
            current_params.append(LuaParam(
                param.group('name'),
                param.group('types').split('|'),
                (param.group('name_optional') is not None) or (param.group('types_optional') is not None),
                param.group('comment')
            ))
            parser.skip_line()
            
        elif parser.skip_word('---@return '):
            returns = parser.regex(regex_return)
            current_returns.append(LuaReturn(
                returns.group('types').split('|'),
                returns.group('name'),
                (returns.group('name_optional') is not None) or (returns.group('types_optional') is not None),
                returns.group('comment')
            ))
            parser.skip_line()
            
        elif parser.skip_word('---@generic '):
            parser.regex(regex_generic)
            is_generic = True
            parser.skip_line()

        elif parser.skip_word('---@luadoc-ignore'):
            luadoc_ignore = True
            parser.skip_line()

        elif parser.skip_word('---@'):
            parser.skip_line()

        elif parser.skip_word('---'):
            line = parser.skip_line()
            current_doclines.append(line)

        elif parser.skip_word('function '):
            if luadoc_ignore:
                luadoc_ignore = False
                parser.skip_line()
                continue
            func = parser.regex(regex_function)
            functions.append(LuaFunction(func.group('name'), current_params, current_returns, is_generic, current_doclines))
            current_params.clear()
            current_returns.clear()
            current_doclines.clear()
            is_generic = False
            parser.skip_line()

        else:
            parser.skip_line()

    return functions, header, version

def lua_file_to_html(file:str|os.PathLike)->str:
    functions, header, version = parse_lua_file(str(file))
    file_documentation = f'# {os.path.basename(file)}\n\n> v{version}\n\n'
    file_documentation += header
    file_documentation += '\n\n'
    file_documentation += table_template.format(
        ''.join([function_template.format(
            f'{func.name}({", ".join([param.name for param in func.params.values()])})',
            func.doc_str())
                for func in functions])
        )

    file_documentation += '\n\n'
    return file_documentation


def __iterate_files(files:list[str])->str:
    """Iterate a list of files and generate a full doc string.

    Args:
        files (list[str]): List of .lua files to iterate.
    """
    all_files_doc = ''
    for arg in files:
        file = Path(arg)
        print()
        print()
        print(file)
        print(f'Testing {file.name}')
        if file.is_dir():
            print(f'Generating doc for folder {file.name}')
            for child in file.glob('*.lua'):
                all_files_doc += parse_lua_file(child.absolute())
        else:
            print(f'Gernerating doc for file {file.name}')
            all_files_doc += parse_lua_file(file.absolute())
    return all_files_doc


# if __name__ == '__main__':
#     pc.copy(lua_file_to_html("scripts/vscripts/core.lua"))
