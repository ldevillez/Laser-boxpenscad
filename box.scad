include <utility.scad>
include <standard.scad>


// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// length of the box
length = 51.0;
// width of the box
width = 50.0;
// Height of the box
height = 50.0;
// material thickness
thickness = 3;
// length of a notch
length_notch = 10;

/* [Specific Settings] */
// Avoid tabs < thickness
remove_small_notch=true;

// Add a part to have a label on
use_label_top=true;
// Label size
label_length=12;

/* [Gridfinity Settings] */
//Use gridfinity principle. Half unit are possible
is_gridfinity=false;

// number of bases along x-axis
gridx = 2; // .5
// number of bases along y-axis
gridy = 2; // .5
// number of bases along z-axis
gridz = 5;
// Is half unit to be used
force_half_unit=false;
// Type of attachement for the feet
bottom_type = 0; // [0: Flat, 1: T-connector]


/* [Manufacturing Settings] */
// Arrange the parts for lasercutting
output_plan=false;
// offset between the parts
offset_laser_part=1;

l_notch = remove_small_notch && length_notch < thickness ? thickness : length_notch;


// ===== IMPLEMENTATION ===== //

l = is_gridfinity ? gridx * g_unit_plan: length;
w = is_gridfinity ? gridy * g_unit_plan: width;
h = is_gridfinity ? gridz * g_unit_height - thickness: height;

// Is it half unit or not
g_is_half_unit = force_half_unit || (gridx * 10) % 10 == 5 ||  (gridy * 10) % 10 == 5;

// Unit used
g_used_unit = g_is_half_unit ? g_unit_plan /2 : g_unit_plan;
// Number of elements
g_nx = g_is_half_unit ? 2 * gridx : gridx;
g_ny = g_is_half_unit ? 2 * gridy : gridy;


// For Z we need to add locator elements
// For simple glued system, should we suggest to add a jig (Laser, cut) ?
// Improve arrangement plan ?
// Check 4mm thickness

if(output_plan){
  if(is_gridfinity){
    g_plan();
  } else {
    plan();
  }

} else {
  if(is_gridfinity){
    g_box();
  } else {
    box();
  }
}
