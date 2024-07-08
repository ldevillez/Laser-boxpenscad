"""
Generate multiple 3D View with openscad
"""


import subprocess
import os
import math

if not os.path.isdir("views"):
    os.mkdir("views")

DIST = 200
H_VIEW = 70
N_VIEW = 3
N_TURN = 1

WIDTH = 1920
HEIGHT = 1080

box_option = {
    "is_gridfinity": False,
    "length": 50,
    "width": 50,
    "height": 50,
    "thickness": 3,
    "length_notch": 10,
    "remove_small_notch": False,
    "use_label_top": False,
    "label_length": 9,
}

box_options = [
    {},
    {"length": 60},
    {"length": 70},
    {"length": 80},
    {"length": 90},
    {"length": 100},
    {"height": 40},
    {"height": 30},
    {"height": 20},
    {"thickness": 4},
    {"thickness": 5},
    {"thickness": 6},
    {"thickness": 3},
    {"height": 30},
    {"height": 38},
    {"length_notch": 12},
    {"length_notch": 14},
    {"length_notch": 16},
    {"length_notch": 18},
    {"remove_small_notch": True},
    {"use_label_top": True},
    {"label_length": 12},
]

g_box_option = {
    "is_gridfinity": True,
    "gridx": 1,
    "gridy": 1,
    "gridz": 5,
    "thickness": 3,
    "length_notch": 10,
    "force_half_unit": False,
    "bottom_type": 0,
    "use_label_top": False,
    "label_length": 9,
}

g_box_options = [
    {},
    {"gridx": 2},
    {"gridx": 3},
    {"gridy": 2},
    {"thickness": 4},
    {"thickness": 5},
    {"thickness": 6},
    {"thickness": 3},
    {"length_notch": 10},
    {"length_notch": 12},
    {"length_notch": 14},
    {"length_notch": 16},
    {"force_half_unit": True},
    {"gridy": 2.5},
    {"bottom_type": 1},
    {"gridy": 2},
    {"force_half_unit": False},
    {"use_label_top": True},
    {"label_length": 12},
]


def pop_or_none(list_to_pop):
    """
    Pop a list. If the list is empty, return None
    """
    if len(list_to_pop) == 0:
        return None
    return list_to_pop.pop()


def convert_options_to_text(options):
    arg = ""
    for key, val in options.items():
        arg += f"-D {key}={val} ".replace("True", "true")
    print(arg)
    return arg


def create_animated_view(
    filename,
    standard_options,
    frames_options,
    width=1920,
    height=1080,
    x=100,
    y=100,
    z=100,
    append_name="",
):
    """
    For a given filename will generate multiple views for a animation
    """

    for idx, frame_option in enumerate(frames_options):
        for key, val in frame_option.items():
            if key != "frame":
                standard_options[key] = val
        text_options = convert_options_to_text(standard_options)

        return_code = subprocess.call(
            f"openscad --preview --camera={x},{y},{z},0,0,0 {filename} --autocenter -o views/{filename.replace('.scad','')}{'' if len(append_name) == 0 else '_' + append_name}_{idx}.png --imgsize={width},{height} --render --colorscheme=Solarized -q {text_options}",
            shell=True,
        )


def create_animated_rotation_view(
    filename,
    standard_options,
    frames_options,
    n_view=3,
    n_turn=1,
    width=1920,
    height=1080,
):
    """
    For a given filename will generate multiple views for a animation
    """
    # Convert the standard option to flag for the command line
    text_options = convert_options_to_text(standard_options)

    # Get the next option to apply
    curr_option = pop_or_none(frames_options)
    for i in range(n_view):
        # If we have options to change at this frame
        if curr_option is not None and i == curr_option["frame"]:
            # Update the standard options
            for key, val in curr_option.items():
                if key != "frame":
                    standard_options[key] = val
            # Convert it to flags for the command line
            text_options = convert_options_to_text(standard_options)
            # Get the next option to apply
            curr_option = pop_or_none(frames_options)

        # Rotate around a circle
        x = DIST * math.cos(n_turn * 2 * math.pi * i / n_view)
        y = DIST * math.sin(n_turn * 2 * math.pi * i / n_view)

        return_code = subprocess.call(
            f"openscad --preview --camera={x},{y},{H_VIEW},0,0,0 {filename} --autocenter -o views/test_{i}.png --imgsize={width},{height} --render --colorscheme=Solarized -q {text_options}",
            shell=True,
        )

    # Add text on picture ?

    # TODO save list of picture to gif for README



create_animated_view("box.scad", box_option, box_options, x=150, y=200, z=300)
create_animated_view("box.scad", g_box_option, g_box_options, x=150, y=200, z=-300, append_name="gridfinity")
