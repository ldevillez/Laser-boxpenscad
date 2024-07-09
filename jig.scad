include <utility.scad>
include <standard.scad>


/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;


/* [General Settings] */

// Laser cutted or 3D printed Jig
is_laser_cutted = true;

// Prepare the plan for the laser cutted jig
output_plan = false;

// Laser cutted or 3D printed Jig
g_is_half_unit = false;

// Material thickness
thickness = 3;

// Number of holes in the grid
gridx=2;

// Length of a notch
length_notch = 10;



// ===== IMPLEMENTATION ===== //



// offset of the feet (related to the thickness)
g_offset = thickness < g_thickness_theshold ? g_off_before_thickness : g_off_after_thickness;
// Unit used
g_used_unit = g_is_half_unit ? g_unit_plan /2 : g_unit_plan;
used_hole_unit = g_is_half_unit ? g_unit_plan/2 - g_offset : g_unit_plan - g_offset;

// For notch function
remove_small_notch=true;

g_nx = g_is_half_unit ? 2 * gridx : gridx;

l = gridx*g_unit_plan + 2*thickness;

if(is_laser_cutted){
  if(output_plan){
    plan_corner_jig_laser();
  } else {
    corner_jig_laser();
  }
} else {
  corner_jig_3d();
}

module bottom_jig(){
  // Number of elements
  gridx=2;
  g_nx = g_is_half_unit ? 2 * gridx : gridx;

  difference(){
    rounded_square(gridx*g_unit_plan+thickness, g_radius);

    grid(g_nx, g_nx, g_used_unit)
    rounded_square(used_hole_unit, g_radius);
  }
}

module corner_jig_3d(){
  // Number of elements
  color("tomato")
  union(){
    linear_extrude(height=thickness)
    difference(){
      translate([thickness/2, thickness/2])
      square(l, center=true);

      translate([thickness, thickness, 0])
      grid(g_nx, g_nx, g_used_unit)
      rounded_square(used_hole_unit, g_radius);
    }
    linear_extrude(height=thickness*2)
    translate([thickness/2,-gridx * g_unit_plan/2, 0])
    square([l,thickness], center=true);

    linear_extrude(height=thickness*2)
    translate([-gridx * g_unit_plan/2, thickness/2,0])
    square([thickness, l], center=true);
  }
}

module bottom_corner_jig_laser(){
  difference(){
    translate([thickness/2, thickness/2])
    square(l, center=true);

    translate([thickness, thickness, 0])
    grid(g_nx, g_nx, g_used_unit)
    rounded_square(used_hole_unit, g_radius);

    translate([thickness/2,-gridx * g_unit_plan/2, 0])
    mirror([0,1,0])
    notch(l, length_notch);

    translate([-gridx * g_unit_plan/2,thickness/2, 0])
    rotate([0,0,90])
    /*mirror([0,1,0])*/
    notch(l, length_notch);
  }
}

module side_a_corner_jig_laser(){
  difference(){
    square([l, 2*thickness],center=true);
    translate([0,thickness/2,0])
    notch(l, length_notch, reverse=false);
  }
}

module side_b_corner_jig_laser(){
  difference(){
    side_a_corner_jig_laser();

    translate([-l/2+thickness/2-0.1,0,0])
    square([thickness+0.1,2*thickness+0.1],center=true);
  }
}

module corner_jig_laser(){
  // Number of elements

  color("tomato")
  linear_extrude(height=thickness)
  bottom_corner_jig_laser();

  color("blue")
  translate([thickness/2,-gridx * g_unit_plan/2,thickness])
  rotate([-90,0,0])
  linear_extrude(height=thickness, center=true)
  side_a_corner_jig_laser();


  color("green")
  translate([-gridx * g_unit_plan/2,thickness/2,thickness])
  rotate([-90,0,90])
  linear_extrude(height=thickness, center=true)
  side_b_corner_jig_laser();

}


module plan_corner_jig_laser(){
  // Number of elements

  color("tomato")
  bottom_corner_jig_laser();

  color("blue")
  translate([thickness/2,-gridx * g_unit_plan/2 - 1.5*thickness - 1,thickness/2])
  rotate([0,0,0])
  side_a_corner_jig_laser();


  color("green")
  translate([-gridx * g_unit_plan/2 - 1.5*thickness - 1,thickness/2,thickness/2])
  rotate([0,0,90])
  side_b_corner_jig_laser();

}
