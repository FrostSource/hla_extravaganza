"""Simple parsing library for the extravaganza toolset.

https://github.com/FrostSource/hla_extravaganza
"""
from typing import Union


class StringParser:
    """Parse arbitary string data.

    Returns:
        StringParser: _description_
    """
    whitespace_chars = [" ","\t","\n","\r"]
    number_chars = ["1","2","3","4","5","6","7","8","9","0"]
    string = ""
    sub_string = ""
    index = 0
    _cache_index = 0
    _cache_sub_string = ""
    def __init__(self, string:str):
        self.string = string
        self.sub_string = string
    
    def _save(self):
        self._cache_index = self.index
        self._cache_sub_string = self.sub_string
    
    def _load(self):
        self.index = self._cache_index
        self.sub_string = self._cache_sub_string

    def skip_whitespace(self):
        while self.peek() in self.whitespace_chars:
            self.next()
    
    def current(self):
        """Get the current char.

        Returns:
            str: Current char.
        """
        return self.string[self.index]

    def next(self, count:int = 1)->str:
        """Move to the next character.

        Args:
            count (int, optional): How many characters to move past. Defaults to 1.

        Returns:
            str: Next character(s).
        """
        self.index += count
        self.sub_string = self.string[self.index:]
        return self.string[self.index-count:self.index]
    
    def peek(self, count:int = 1, skip_whitespace = False)->str:
        """Peek at the next character(s).

        Args:
            count (int, optional): Number of chars to peek at. Defaults to 1.
            skip_whitespace (bool, optional): If should skip whitespace before peeking. Defaults to False.

        Returns:
            str: Peeked character(s).
        """
        cache_index = self.index
        if skip_whitespace: self.skip_whitespace()
        c = self.next(count)
        self.index = cache_index
        return c
        # return self.string[self.index:self.index+count]
    
    def eat(self, strings:Union[str,list[str]]):
        if type(strings) is str: strings = [strings]
        for string in strings:
            if not self.skip_word(string):
                raise Exception(f"Expecting '{string}'")
    
    def either(self, *strings:list[str]):
        for string in strings:
            self._save()
            try:
                self.eat(string)
            except:
                self._load()
                continue
            else:
                break
    
    def skip_word(self, string:str)->bool:
        """Skip an entire word if it's next.

        Args:
            string (str): Word to skip.

        Returns:
            bool: If the skip was successful.
        """
        cache_index = self.index
        self.skip_whitespace()
        if self.string[self.index:self.index+len(string)] == string:
            self.next(len(string))
            return True
        else:
            self.index = cache_index
            return False
        
    def peek_word(self, stop_at:list[str] = whitespace_chars)->str:
        cache_index = self.index
        word = self.get_word(stop_at)
        self.index = cache_index
        return word
    
    def get_word(self, stop_at:list[str] = whitespace_chars)->str:
        self.skip_whitespace()
        word = ""
        while self.peek() not in stop_at and not self.finished():
            word += self.next()
        return word
    
    def get_string(self, boundary_chars = ["'", '"']):
        self.skip_whitespace()
        if self.current() in boundary_chars:
            boundary_char = self.current()
            string = ""
            while self.peek() != boundary_char:
                string += self.next()
            return string
    
    def startswith(self, substr:str, skip_whitespace = True)->bool:
        self._save()
        if skip_whitespace:
            self.skip_whitespace()
        ret = self.string[self.index:].startswith(substr)
        self._load()
        return ret

    
    def get_number(self, allow_decimal = True, number_chars = number_chars, decimal_char = "."):
        num = ""
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
        c = ""
        for x in range(count):
            while c != "\n":
                c = self.next()
            c = self.next()
    
    def finished(self)->bool:
        return self.index >= len(self.string)