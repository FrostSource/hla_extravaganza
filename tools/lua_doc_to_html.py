# Simple html table generation of lua docs for github readmes.
# Copies to clipboard.
from collections import OrderedDict
from datetime import datetime
import os
from pathlib import Path
from string import whitespace
import sys
import pyperclip as pc
import re
if __name__ == '__main__':
    from lib.parsing import StringParser
else:
    from .lib.parsing import StringParser

# No line templates

file_template = '''## {} ({})\n\n{}\n\n'''

table_template = '''<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr>{}</table>'''
# table_template = '''<table><tr><td><b>Function</b></td></tr>{}</table>'''

# function_template = '''<tr><td width="75%">{}</td width="25%"><td>{}</td></tr>'''
function_template = '''<tr><td>{}</td><td>{}</td></tr>'''
# function_template = '''<tr><td>\n\n```lua\n{}\n```\n\n</td><td>{}</td></tr> <tr><td></td><td></td></tr>'''
# function_template = '''<tr><td>\n\n```lua\n{}\n```\n\n</td></tr>'''

# Lined templates

# table_base = '''<table>
# <tr>
# <td><b>Function</b></td><td><b>Description</b></td>
# </tr>
# {}
# </table>'''

# function_template = '''<tr>
# <td width="75%">
# <code>{}</code>
# </td width="25%">
# <td>{}</td>
# </tr>
# '''

# Code version of signature

# function_template = '''<tr>
# <td>

# ```lua
# {}
# ```
# </td>
# <td>{}</td>
# </tr>
# '''

# class StringParser:
#     whitespace_chars = [' ', '\t', '\r', '\n']
#     def __init__(self, string:str):
#         self.string = string or ""
#         self.index = 0
    
#     def finished(self)->bool:
#         return self.index >= len(self.string)

#     def skip_whitespace(self, _except=[]):
#         """Skip all whitespace except new lines.
#         """
#         whitespace_chars = [x for x in self.whitespace_chars if x not in _except]
#         while not self.finished() and self.peek() in whitespace_chars:
#             self.next()

#     def next(self, count:int = 1)->str:
#         """Returns the next `count` characters and moves past them.

#         Args:
#             count (int, optional): Number of next chars to get. Defaults to 1.

#         Returns:
#             str: Found chars.
#         """
#         if self.finished(): return ''
#         self.index += count
#         return self.string[self.index-count:self.index]
    
#     def peek(self, count:int = 1)->str:
#         """Returns the next `count` characters without moving past them

#         Args:
#             count (int, optional): Number of chars to. Defaults to 1.

#         Returns:
#             str: Found chars.
#         """
#         if self.finished(): return ''
#         return self.string[self.index:self.index+count]
    
#     def skip_word(self, string:str)->bool:
#         """Attempts to skip past a word if it is found next.

#         Args:
#             string (str): Word to skip.

#         Returns:
#             bool: If the skip was successful.
#         """
#         if self.finished(): return False
#         cache_index = self.index
#         self.skip_whitespace()
#         if self.string[self.index:self.index+len(string)] == string:
#             self.next(len(string))
#             return True
#         else:
#             self.index = cache_index
#             return False
    
#     def get_word(self, stop_at:list[str] = whitespace_chars)->str:
#         """Gets a string of characters until hitting `stop_at`.

#         Args:
#             stop_at (list[str], optional): Chars to stop at. Defaults to [" ","\n","\r"].

#         Returns:
#             str: String found.
#         """
#         if self.finished(): return ''
#         self.skip_whitespace(stop_at)
#         word = ""
#         while self.peek() not in stop_at and not self.finished():
#             word += self.next()
#         return word
    
#     def skip_line(self)->str:
#         """Moves past the next occurance of \n.
#         """
#         line = ''
#         while not self.finished() and self.peek() != '\n':
#             line += self.next()
#         self.next()
#         return line
    
#     def startswith(self, substr:str)->bool:
#         if self.finished(): return False
#         return self.string[self.index:].startswith(substr)

#     def regex(self, pattern:str)->re.Match[str]|None:
#         """Match a given regex pattern and move past it if found.

#         Args:
#             pattern (str): The pattern.

#         Returns:
#             re.Match[str]|None: The match object if found.
#         """
#         cache = self.index
#         self.skip_whitespace()
#         m = re.match(pattern, self.string[self.index:])
#         if m is None:
#             self.index = cache
#         else:
#             self.index += len(m.group(0))
#         return m


# class LuaFunction:
#     params = OrderedDict()
#     name = ""
#     return_type = ""
#     description = ""
#     def __init__(self, function_line:str, doc_lines:list[str]):
#         self.params = OrderedDict()
#         parser = StringParser(function_line)
        
#         # Function name
#         parser.skip_word("function")
#         self.name = parser.get_word([" ","("])
#         parser.next()

#         # Gather params
#         while parser.peek() not in [")","\n"] and not parser.finished():
#             # Added without type to keep order
#             self.params[parser.get_word([" ",",",")"])] = ""
#             # Skipping , or )
#             parser.next()

#         # Get doc info
#         description_builder = ""
#         for doc_line in doc_lines:
#             parser = StringParser(doc_line)
#             if parser.skip_word("---@param"):
#                 param_name = parser.get_word()
#                 param_type = parser.get_word([" ","#","\n","\r"])
#                 self.params[param_name] = param_type
#             elif parser.skip_word("---@return"):
#                 self.return_type = parser.get_word([" ","#","\n","\r"])
#             elif parser.skip_word("---@"):
#                 # Skip all other special doc lines
#                 pass
#             elif parser.skip_word("---"):
#                 desc = parser.get_word(["\n","\r"])
#                 description_builder += desc+" " if desc != "" else "\n"
#         self.description = description_builder.rstrip()
    
#     def get_signature(self, valve:bool = True)->str:
#         p = ""
#         if valve:
#             p = ", ".join([f"{v} <i>{k}</i>" for k,v in self.params.items()])
#             return f"{self.return_type} {self.name}({p})"
#         else:
#             p = ", ".join([f"<i>{k}</i>: {v}" for k,v in self.params.items()])
#             return f"{self.name}({p})->{self.return_type}"




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

    # while not parser.finished():
    #     if inside_code_block:
    #         if parser.skip_word('```'):
    #             header += f'```\n'
    #             inside_code_block = False
    #         else:
    #             parser.skip_word(subtracted_whitespace, False)
    #             line = parser.skip_line()
    #             header += f'{line}\n'

    #     elif parser.startswith('```lua'):
    #         subtracted_whitespace = parser.skip_whitespace()
    #         line = parser.skip_line()
    #         header += f'\n\n```lua\n'
    #         inside_code_block = True

    #     elif m := parser.regex(r'-+\r?\n'):
    #         # header += f'\n\n---\n'
    #         header += '\n\n'

    #     elif m := parser.regex(r'[-=]+\s*([\w\s]+)\s*[-=]+'):
    #         header += f'\n\n----\n#### {m[1]}\n'

    #     else:
    #         # line = parser.get_word(['\n'])
    #         line = parser.skip_line().strip()
    #         if line == '':
    #             header += '\n'
    #         else:
    #             header += f'{line} '
    #         # parser.next()

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
        # {self.name}
        # ', '.join([param.emmylua_str() for param in self.params.values()])
        # '|'.join([ret.type_str() for ret in self.returns])
        # return ''
        return f"{self.name}({', '.join([param.emmylua_str() for param in self.params.values()])}) -> {'|'.join([ret.type_str() for ret in self.returns])}"

    def simple_str(self)->str:
        #TODO: Make generalized function for this if
        ps = ', '.join([param.simple_str() for param in self.params.values()])
        if len(ps) > 90: ps = ',\n'.join([param.simple_str() for param in self.params.values()])
        if len(self.returns) == 1 and len(self.returns[0].types) == 1 and self.returns[0].types[0] == 'nil':
            return f"{self.name}({ps})"
        else:
            return f"{self.name}({ps}) -> {'|'.join([ret.type_str() for ret in self.returns])}"
    
    # def lua_str(self)->str:
    #     doc = '---' + '\n---'.join(self.doc_lines) + '\n'
    #     for param in self.params:
    #         doc += param.lua_str() + '\n'
    #     for ret in self.returns:
    #         doc += ret.lua_str() + '\n'
    #     return doc + f"{self.name}({', '.join([param.name for param in self.params.values()])})"
        

    def __str__(self)->str:
        s = ''
        # s += '---\n'
        s += '\n'.join(['---'+doc for doc in self.doc_lines])
        s += '\n'
        # s += '\n---\n'
        s += '\n'.join([str(param) for param in self.params.values()])
        s += '\n'
        s += '\n'.join([str(ret) for ret in self.returns])
        s += '\n'
        # s += f'function {self.name}'
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

# r'(?P<name>([\w\d]+)|\.\.\.)(?P<name_optional>\?)?\s+(?P<type>[^\s\?]+)(?P<type_optional>\?)?\s*(#\s*(?P<comment>.+))?'
# regex_comment = r'(#\s*(?P<comment>.+))?'
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
pc.copy(regex_function)
# m = re.match(r'(?P<name>[\w\d]+|\.\.\.)((?P<name_optional>\?))?[ ]*(?P<types>[^\s\?]+)((?P<types_optional>\?))?[ ]*(#?[ ]*(?P<comment>.+))?', 'handle EntityHandle\n---@param name string')
# print(m.group(0))
# print('hehe')
# exit()

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
            # print(current_params[-1])
        elif parser.skip_word('---@return '):
            returns = parser.regex(regex_return)
            current_returns.append(LuaReturn(
                returns.group('types').split('|'),
                returns.group('name'),
                (returns.group('name_optional') is not None) or (returns.group('types_optional') is not None),
                returns.group('comment')
            ))
            parser.skip_line()
            # print(current_returns[-1])
        elif parser.skip_word('---@generic '):
            parser.regex(regex_generic)
            is_generic = True
            parser.skip_line()
            pass
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
            # print(parser.peek(20))
            func = parser.regex(regex_function)
            functions.append(LuaFunction(func.group('name'), current_params, current_returns, is_generic, current_doclines))
            #Debug
            # print(str(functions[-1]) + '\n')
            #EndDebug
            current_params.clear()
            current_returns.clear()
            current_doclines.clear()
            is_generic = False
            parser.skip_line()
        else:
            parser.skip_line()
    
    # file_documentation = f'## {os.path.basename(file)} (v{version})\n\n'
    # file_documentation += header
    # file_documentation += '\n\n'
    # file_documentation += table_template.format(''.join([function_template.format(func.simple_str(), func.doc_str()) for func in functions]))
    # file_documentation += '\n\n'
    # pc.copy(file_documentation)
    # return file_documentation
    return functions, header, version

def lua_file_to_html(file:str|os.PathLike)->str:
    # Last Updated {datetime.now().strftime("%Y-%m-%d")}
    functions, header, version = parse_lua_file(str(file))
    file_documentation = f'## {os.path.basename(file)} (v{version})\n\n'
    file_documentation += header
    file_documentation += '\n\n'
    # file_documentation += table_template.format(''.join([function_template.format(str(func)) for func in functions]))
    file_documentation += table_template.format(
        ''.join([function_template.format(
            f'{func.name}({", ".join([param.name for param in func.params.values()])})',
            func.doc_str())
                for func in functions])
        )
    # file_documentation += table_template.format(
    #     ''.join([function_template.format(f'{func.name}({", ".join([param.name for param in func.params])})') for func in functions]),
        
    #     )
    file_documentation += '\n\n'
    return file_documentation


# f = sys.argv[1]
# f = r'C:\Program Files (x86)\SteamLibrary\steamapps\common\Half-Life Alyx\content\hlvr_addons\hla_extravaganza\scripts\vscripts\storage.lua'
# f = r'C:\Program Files (x86)\SteamLibrary\steamapps\common\Half-Life Alyx\content\hlvr_addons\hla_extravaganza\scripts\vscripts\input.lua'
# f = r'C:\Program Files (x86)\SteamLibrary\steamapps\common\Half-Life Alyx\content\hlvr_addons\hla_extravaganza\scripts\vscripts\player.lua'
# f = r'C:\Program Files (x86)\SteamLibrary\steamapps\common\Half-Life Alyx\content\hlvr_addons\hla_extravaganza\scripts\vscripts\core.lua'
# with open(f,'r') as file:
#     src = file.read()
# parser = StringParser(src)
# comment = parse_multiline_comment(parser)
# header, version, website = parse_header(comment)
# pc.copy(header)
# print(header)
# parse_lua_file(f)

# exit()



# def lua_doc_from_file(file:Path)->str:
#     """Generate HTML table doc from a .lua file.

#     Args:
#         file (Path): File to generate from.

#     Returns:
#         str: The complete doc table.
#     """
#     with file.open("r") as f:
#         lines = f.readlines()
#     version = ""
#     found_desc = False
#     desc = ""
#     function_docs = list()
#     i = 0
#     while i < len(lines):
#         line = lines[i].lstrip()
#         # Naive multiline comment skipping
#         if line.startswith("--[["):
#             while not "]]" in line:
#                 i += 1
#                 line = lines[i].lstrip()
#                 if not found_desc and version and not "https://github.com/FrostSource/hla_extravaganza" in line:
#                     if not line.strip():
#                         desc += '\n\n'
#                     else:
#                         desc += f'{line.rstrip()} '
#                 if not version:
#                     version = re.match(".*v(\d+\.\d+\.\d+).*", line)[0]
#                     print(version)
#             found_desc = True
#         # Gather function signature
#         elif line.startswith("function"):
#             function_line = line
#             doc_lines = list()
#             # Backtrack through doc lines
#             j = i - 1
#             while lines[j].lstrip().startswith("---"):
#                 doc_lines.append(lines[j])
#                 j -= 1
#             doc_lines.reverse()
#             luaFunction = LuaFunction(function_line, doc_lines)
#             function_docs.append(function_template.format(luaFunction.get_signature(), luaFunction.description))
#         i += 1
#     doc_table = table_template.format("\n".join(function_docs))
#     header = file_template.format(file.name, version, desc)
#     # print(desc)
#     pc.copy(header + doc_table)


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


if __name__ == '__main__':
    pc.copy(lua_file_to_html("scripts/vscripts/core.lua"))
    # __iterate_files(sys.argv[1:])
    # test = LuaFunction(
    #     "    function Storage.SaveString(handle, name, value)\n",
    #     [
    #     "    ---Save a string. Strings seem to be limited to 63 characters!\n",
    #     "    ---Second line to see what happens.\n",
    #     "    ---@param handle CBaseEntity # Entity to save on.\n",
    #     "    ---@param name string # Name to save as.\n",
    #     "    ---@param value string # String to save.\n",
    #     "    ---@return boolean # If the save was successful.\n"
    #     ]
    #     )
    # print(test.get_signature())
    # input('DONE')
