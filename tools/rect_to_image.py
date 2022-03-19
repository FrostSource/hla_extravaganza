"""Creates a PNG image with outlines based on a .rect file.

https://github.com/FrostSource/hla_extravaganza
"""

from ast import Tuple
from pathlib import Path
from lib.parsing import StringParser
from PIL import Image, ImageDraw


def parse_rect_file(rect: Path):
    def rectangle():
        sp.skip_line()
        sp.eat(["min","=","["])
        rect_min = []
        rect_min.append(sp.get_number(allow_decimal=False))
        sp.eat(",")
        rect_min.append(sp.get_number(allow_decimal=False))
        sp.eat("]")
        sp.eat(["max","=","["])
        rect_max = []
        rect_max.append(sp.get_number(allow_decimal=False))
        sp.eat(",")
        rect_max.append(sp.get_number(allow_decimal=False))
        sp.eat("]")
        sp.either(
            ["properties","=","null"],
            ["properties","=","{","allowRotation","=","true","}"]
        )
        sp.skip_line(2)
        return ((rect_min[0],rect_min[1]),(rect_max[0],rect_max[1]))

    sp = StringParser(rect.read_text())
    shapes = []
    max_size = (0,0)
    if sp.startswith("<!-- kv3"):
        sp.skip_line(9)
        while sp.startswith("{"):
            r = rectangle()
            print(r)
            max_size = (max(max_size[0],r[1][0]),max(max_size[1],r[1][1]))
            shapes.append(r)
        print(len(shapes))
        print(max_size)
        return shapes, max_size


if __name__ == '__main__':
    rect_path = input("Enter .rect file:")
    if rect_path.startswith('"'): rect_path = rect_path[1:]
    if rect_path.endswith('"'): rect_path = rect_path[:-1]
    rect_path = Path(rect_path)
    if rect_path.exists():
        print(rect_path)
        size = input("Enter image size (single number):") or 4096
        size = int(size)
        shapes, max_size = parse_rect_file(rect_path)
        size_division = max_size[0]/size, max_size[1]/size
        image = Image.new("RGBA", (size,size))
        for shape in shapes:
            draw = ImageDraw.Draw(image)
            x1 = shape[0][0]/size_division[0]
            y1 = shape[0][1]/size_division[1]
            x2 = shape[1][0]/size_division[0]
            y2 = shape[1][1]/size_division[1]
            draw.rectangle( ((x1,y1),(x2,y2)), fill=None, outline="black", width=1 )
        image.save(rect_path.parent.joinpath(rect_path.stem+".png"),"PNG")
    else:
        print(f"File does not exist! {rect_path}")