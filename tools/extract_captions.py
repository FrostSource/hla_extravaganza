
# Hacky quick script to extract captions from base game vo sound events.
# Written to make vo_captions.md less painful.
# replace � with …

import os

current_dir = os.path.dirname(__file__)
print("Current path:", current_dir)

file = open(os.path.join(current_dir, "__test_vo_soundevents.txt"), "r")
lines = file.readlines()
file.close()

file = open(os.path.join(current_dir, "__test_vo_captions.txt"), "w")
looking_for_text = False
soundevent_name = ""
soundevents = {}

for line in lines:
    line = line.strip()
    # Searching for line_text after encountering sound event
    if looking_for_text:
        if line.startswith("line_text = "):
            text = line[12:].replace("[", "\\[").replace("]", "\\]")
            #file.write(f"{soundevent_name} {text}  \n")
            soundevents[soundevent_name] = text
            looking_for_text = False
    # Searching for start of sound event
    elif line.startswith("vo."):
        soundevent_name = line[3:-2]
        looking_for_text = True

# Sorting by name
for soundevent in sorted(soundevents.items()):
    file.write(f"{soundevent[0]} {soundevent[1]}  \n")
    
print("Done extracting captions.")
