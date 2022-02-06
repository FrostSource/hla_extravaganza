# Simple html table generation of lua docs for github readmes.
# Copies to clipboard.
from collections import OrderedDict
from pathlib import Path
import sys
import pyperclip as pc

# No line templates

table_base = '''<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr>{}</table>'''

function_template = '''<tr><td width="75%">{}</td width="25%"><td>{}</td></tr>'''

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

class StringParser:
    string = ""
    index = 0
    def __init__(self, string:str):
        self.string = string

    def skip_whitespace(self):
        while self.peek() in [" ","\t"]:
            self.next()

    def next(self, count:int = 1)->str:
        self.index += count
        return self.string[self.index-count:self.index]
    
    def peek(self, count:int = 1)->str:
        return self.string[self.index:self.index+count]
    
    def skip_word(self, string:str)->bool:
        cache_index = self.index
        self.skip_whitespace()
        if self.string[self.index:self.index+len(string)] == string:
            self.next(len(string))
            return True
        else:
            self.index = cache_index
            return False
    
    def get_word(self, stop_at:list[str] = [" ","\n","\r"])->str:
        self.skip_whitespace()
        word = ""
        while self.peek() not in stop_at and not self.finished():
            word += self.next()
        return word
    
    def startswith(self, substr:str)->bool:
        return self.string[self.index:].startswith(substr)
    
    def finished(self)->bool:
        return self.index >= len(self.string)


class LuaFunction:
    params = OrderedDict()
    name = ""
    return_type = ""
    description = ""
    def __init__(self, function_line:str, doc_lines:list[str]):
        self.params = OrderedDict()
        parser = StringParser(function_line)
        
        # Function name
        parser.skip_word("function")
        self.name = parser.get_word([" ","("])
        parser.next()

        # Gather params
        while parser.peek() not in [")","\n"] and not parser.finished():
            # Added without type to keep order
            self.params[parser.get_word([" ",",",")"])] = ""
            # Skipping , or )
            parser.next()

        # Get doc info
        description_builder = ""
        for doc_line in doc_lines:
            parser = StringParser(doc_line)
            if parser.skip_word("---@param"):
                param_name = parser.get_word()
                param_type = parser.get_word([" ","#","\n","\r"])
                self.params[param_name] = param_type
            elif parser.skip_word("---@return"):
                self.return_type = parser.get_word([" ","#","\n","\r"])
            elif parser.skip_word("---"):
                desc = parser.get_word(["\n","\r"])
                description_builder += desc+" " if desc != "" else "\n"
        self.description = description_builder.rstrip()
    
    def get_signature(self, valve:bool = True)->str:
        p = ""
        if valve:
            p = ", ".join([f"{v} <i>{k}</i>" for k,v in self.params.items()])
            return f"{self.return_type} {self.name}({p})"
        else:
            p = ", ".join([f"<i>{k}</i>: {v}" for k,v in self.params.items()])
            return f"{self.name}({p})->{self.return_type}"


def lua_doc_from_file(file:Path)->str:
    """Generate HTML table doc from a .lua file.

    Args:
        file (Path): File to generate from.

    Returns:
        str: The complete doc table.
    """
    f = file.open("r")
    lines = f.readlines()
    function_docs = list()
    i = 0
    while i < len(lines):
        line = lines[i].lstrip()
        # Naive multiline comment skipping
        if line.startswith("--[["):
            while not "]]" in line:
                i += 1
                line = lines[i].lstrip()
        # Gather function signature
        elif line.startswith("function"):
            function_line = line
            doc_lines = list()
            # Backtrack through doc lines
            j = i - 1
            while lines[j].lstrip().startswith("---"):
                doc_lines.append(lines[j])
                j -= 1
            doc_lines.reverse()
            luaFunction = LuaFunction(function_line, doc_lines)
            function_docs.append(function_template.format(luaFunction.get_signature(), luaFunction.description))
        i += 1
    doc_table = table_base.format("\n".join(function_docs))
    pc.copy(doc_table)


def iterate_files(files:"list[str]"):
    """Iterate a list of files and generate a full doc string.

    Args:
        files (list[str]): List of .lua files to iterate.
    """
    for arg in files:
        file = Path(arg)
        print()
        print()
        print(file)
        print(f"Testing {file.name}")
        if file.is_dir():
            print(f"Generating doc for folder {file.name}")
            for child in file.glob("*"):
                lua_doc_from_file(child)
        else:
            print(f"Gernerating doc for file {file.name}")
            lua_doc_from_file(file)


if __name__ == '__main__':
    iterate_files(sys.argv[1:])
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
    print("DONE")
