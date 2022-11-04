"""Simple parsing library for the extravaganza toolset.

https://github.com/FrostSource/hla_extravaganza
"""
import re

class StringParser:
    """Parse arbitary string data.

    Returns:
        StringParser: _description_
    """
    whitespace_chars = [' ','\t','\n','\r']
    number_chars = ['1','2','3','4','5','6','7','8','9','0']
    index = 0
    line_num = 1
    line_row = 1
    _cache_stack:list[tuple[int,int,int]] = []
    _cache_index = 0
    _cache_line_num = 1
    _cache_line_row = 1
    def __init__(self, string:str):
        self.string = string
        # Used for debugging
        self._sub_string = string
    
    def _save(self):
        self._cache_stack.append((self.index, self.line_num, self.line_row))
    
    def _load(self):
        self.index, self.line_num, self.line_row = self._pop()
        self._sub_string = self.string[self.index:]
    
    def _pop(self):
        return self._cache_stack.pop()
    
    def finished(self)->bool:
        return self.index >= len(self.string)

    def skip_whitespace(self, _except=[]):
        """Skip all whitespace and returns it.
        """
        whitespace_chars = [x for x in self.whitespace_chars if x not in _except]
        st = ''
        while not self.finished() and self.current() in whitespace_chars:
            st += self.__next()
        return st
    
    def current(self):
        """Get the current char.

        Returns:
            str: Current char.
        """
        if self.finished(): return ''
        return self.string[self.index]
    
    def __next(self)->str:
        """Internal function for handling each character.

        Returns:
            str: Next character.
        """
        if self.string[self.index] == '\n':
            self.line_row += 1
            self.line_num = 0
        else:
            self.line_num += 1
        self.index += 1
        self._sub_string = self.string[self.index:]
        return self.string[self.index-1]

    def next(self, count:int = 1)->str:
        """Move to the next character.

        Args:
            count (int, optional): How many characters to move past. Defaults to 1.

        Returns:
            str: Next character(s).
        """
        if self.finished():
            raise Exception('Tried to access character past string bounds.')
        _next_str = ''
        while not self.finished() and count > 0:
            _next_str += self.__next()
            count -= 1
        return _next_str
    
    def peek(self, count:int = 1, skip_whitespace = False)->str:
        """Peek at the next character(s).

        Args:
            count (int, optional): Number of chars to peek at. Defaults to 1.
            skip_whitespace (bool, optional): If should skip whitespace before peeking. Defaults to False.

        Returns:
            str: Peeked character(s).
        """
        self._save()
        if skip_whitespace: self.skip_whitespace()
        c = self.next(count)
        self._load()
        return c
    
    def eat(self, strings:str|list[str]):
        """Eats a string or list of strings in order.

        Args:
            strings (str|list[str]): Strings to eat.

        Raises:
            Exception: If a string isn't found.
        """
        if type(strings) is str: strings = [strings]
        for string in strings:
            if not self.skip_word(string):
                raise Exception(f"Expecting '{string}'")
    
    def either(self, *strings:list[str]):
        """Tests a series of strings or string lists with the eat function until one matches.
        
        Raises:
            Exception: If no options match.
        """
        match_found = False
        for string in strings:
            self._save()
            try:
                self.eat(string)
            except:
                self._load()
                continue
            else:
                self._pop()
                match_found = True
                break
        if not match_found:
            #TODO: Make this message easier to read
            raise Exception(f'Expecting one of {strings}')
    
    def skip_word(self, string:str, skip_whitespace = True)->bool:
        """Skip an entire word if it's next.

        Args:
            string (str): Word to skip.

        Returns:
            bool: If the skip was successful.
        """
        if self.finished(): return False
        self._save()
        if skip_whitespace: self.skip_whitespace()
        if self.string[self.index:self.index+len(string)] == string:
            self.next(len(string))
            self._pop()
            return True
        else:
            self._load()
            return False
    
    def get_word(self, stop_at:list[str] = whitespace_chars)->str:
        self.skip_whitespace()
        word = ''
        while self.peek() not in stop_at and not self.finished():
            word += self.next()
        return word
        
    def peek_word(self, stop_at:list[str] = whitespace_chars)->str:
        self._save()
        word = self.get_word(stop_at)
        self._load()
        return word
    
    def get_string(self, boundary_chars = ["'", '"']):
        self.skip_whitespace()
        if self.current() in boundary_chars:
            boundary_char = self.current()
            string = ''
            while self.peek() != boundary_char:
                string += self.next()
            return string
    
    def startswith(self, substr:str, skip_whitespace = True)->bool:
        self._save()
        if skip_whitespace: self.skip_whitespace()
        ret = self.string[self.index:].startswith(substr)
        self._load()
        return ret

    
    def get_number(self, allow_decimal = True, number_chars = number_chars, decimal_char = "."):
        num = ''
        is_decimal = False
        self.skip_whitespace()
        while self.current() in number_chars or (self.current() == decimal_char and allow_decimal):
            if self.current() == decimal_char:
                is_decimal = True
            num += self.next()
        if is_decimal:
            num = float(num)
        else:
            num = int(num)
        return num
    
    def skip_line(self, count = 1):
        lines:list[str] = []
        line = ''
        for x in range(count):
            while not self.finished() and self.current() != '\n':
                line += self.next()
            lines.append(line)
            line = ''
            if self.finished(): break
            self.next()
            
        return '\n'.join(lines)

    def regex(self, pattern:str)->re.Match[str]|None:
        """Match a given regex pattern and move past it if found.

        Args:
            pattern (str): The pattern.

        Returns:
            re.Match[str]|None: The match object if found.
        """
        self._save()
        self.skip_whitespace()
        m = re.match(pattern, self.string[self.index:])
        if m is None:
            self._load()
        else:
            self._pop()
            self.index += len(m.group(0))
        return m
    
    def __str__(self):
        return self.string[self.index:]