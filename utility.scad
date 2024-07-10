
module rounded_square(length, radius){
    // Positive and then negative to round
    offset(radius)
    offset(-radius)
    square([length,length], center = true);
}

module grid(nx, ny, l) {
  translate([-nx*l/2 - l/2, -ny*l/2 - l/2, 0])
    for (i = [1:nx]){
      for (j = [1:ny]){
        translate([i*l,j*l,0])
        children();
      }
    }
}

module panel(length, width){
  square([length, width], center=true);
}

module center_notch(length_side, reverse=true){
  //_To have nice cut
  offset_cut = 1;

  //TODO remove small notch if the option is selected

  // Number of cut on ecah side
  nx = length_side / (2*length_notch);

   intersection(){
    // To let material on each side the notchs are resctriced
    translate([0, -offset_cut/2, 0])
    square([length_side, thickness+offset_cut], center=true);
    union(){
      if(reverse){
        for (i = [1:nx]){
          translate([i*length_notch*2,-offset_cut/2,0])
          square([length_notch,thickness+offset_cut],center=true);

          translate([-i*length_notch*2,-offset_cut/2,0])
          square([length_notch,thickness+offset_cut],center=true);
        }
        // Central notch
        translate([0, -offset_cut/2, 0])
        square([length_notch,thickness+offset_cut],center=true);
      } else {
        union(){
          for (i = [1:nx]){
            translate([(i-0.5)*length_notch*2,-offset_cut/2,0])
            square([length_notch,thickness+offset_cut],center=true);

            translate([-(i-0.5)*length_notch*2,-offset_cut/2,0])
            square([length_notch,thickness+offset_cut],center=true);
          }
        }
      }
    }
  }
}

module notch(length_side, l_notch, reverse=true){
  l_n = is_undef(l_notch) ? length_notch : l_notch;
  // Offset needed for clear removal
  off_th = 1;

  // Is the first element a notch or a tab
  off = reverse ? l_n : 0;

  // Floating number of notch
  x = length_side / (2*l_n);
  // Floating number of notch + tabs
  x_bis = length_side / l_n;

  // Remaining of the part if the side is not divisible by l_n
  diff = (x_bis - floor(x_bis)) * l_n;

  // Is there a little part to remove ?
  // if we want to avoid little notch (< thickness)
  // And the remaining part is less than the thickness
  // And the remaining part is bigger than 0
  remove_notch = remove_small_notch && diff < thickness  && diff > 0 && abs(diff - thickness) > 1e-5;

  // is the remaining part in the first part or the second part of the combo notch+tab
  first_half = x - floor(x) - 0.5 < 0;
  // Check if this part is a notch or not
  last_is_notch = (!reverse && first_half) || (reverse && !first_half);

  // if this little part is a notch, we will not cut it
  nx = remove_notch && last_is_notch ? x-1 : x;
  intersection(){
    translate([0, off_th/2, 0])
    square([length_side, thickness+off_th], center=true);
    union(){
    // For each notch
      for (i = [0:nx]){
        // Shift half the total length for each element
        // + the offset (in case of reverse)
        // + the i * 2 * l_n
        translate([i*l_n*2 + off - length_side/2, -thickness/2-off_th/2, -thickness/2-off_th/2])
        square([l_n, thickness+off_th]);
      }

      // If we are in the regular case
      if (!reverse){
        // If the the remaining part is a tab
        if(!last_is_notch && remove_notch){
          // We remove it
          translate([(nx-0.5)*l_n*2 + off -length_side/2 - off_th/2,-thickness/2-off_th/2, -thickness/2-off_th/2])
          square([l_n+thickness+off_th, thickness+off_th]);
        }

        // If not reverse always add a small piece on the beginning end to have nice cut
        translate([-length_side/2-off_th/2,-thickness/2-off_th/2, -thickness/2-off_th/2])
        square([off_th, thickness+off_th]);

        // Add it to the other end if need
        if((x*10) % 10 < 5.01){
          translate([-length_side/2 + (floor(x)+0.5)*l_n*2-off_th/2,-thickness/2-off_th/2, -thickness/2-off_th/2])
          square([off_th, thickness+off_th]);
        }

      } else {
        // In the reverse case

        // if the remain part is a tab
        if(!last_is_notch && remove_notch){
          // Remove it
          translate([(nx-1)*l_n*2 + off -length_side/2 - off_th/2,-thickness/2-off_th/2, -thickness/2-off_th/2])
          square([l_n+thickness+off_th, thickness+off_th]);
        }

        // Check if we need to add a part to have a nice cut
        if((x*10) %10 == 0){
          translate([-length_side/2 + (floor(x))*l_n*2-off_th/2,-thickness/2-off_th/2, -thickness/2-off_th/2])
          square([off_th, thickness+off_th]);

        }
      }
    }
  }
}

module bottom(){
  difference(){
    panel(l, w);
    union(){
      translate([0, w/2-thickness/2,0])
      notch(l, reverse=false);

      translate([-l/2+thickness/2, 0,0])
      rotate([0, 0, 90])
      notch(w, reverse=false);

      translate([0, -w/2+thickness/2,0])
      rotate([0, 0, 180])
      notch(l, reverse=false);

      translate([l/2-thickness/2, 0,0])
      rotate([0, 0, 270])
      notch(w, reverse=false);

      if(bottom_type == 1 && is_gridfinity){
        grid(g_nx, g_ny,g_used_unit)
        square([thickness,g_connector_piece_box_length], center=true);
      }
    }
  }
}

module side(length, height, with_top_notch=false){
  difference(){
    panel(length, height);
    union(){
      translate([0, height/2-thickness/2,0])
      notch(length, reverse=true);

      translate([length/2-thickness/2, 0,0])
      rotate([0, 0, -90])
      notch(height, reverse=false);

      translate([-length/2+thickness/2, 0,0])
      rotate([0, 0, -90])
      mirror([0, 1, 0])
      notch(height, reverse=true);

      if(with_top_notch){
        translate([0, -height/2+thickness/2,0])
        center_notch(length - 2 * thickness, reverse=true);
      }
    }
  }
}

module label(){
  difference(){
    panel(w, label_length);
    translate([0,-label_length/2+thickness/2,0])
    center_notch(width - 2 * thickness, reverse=false);

    translate([-w/2+thickness/2, 0, 0])
    rotate([0,0,-90])
    mirror([0,1,0])
    notch(label_length, l_notch=min(length_notch, label_length/2));

    translate([w/2-thickness/2, 0, 0])
    rotate([0,0,-90])
    notch(label_length, l_notch=min(length_notch, label_length/2));
  }
}

module box(){
  color("tomato")
  translate([0,0,0])
  linear_extrude(height=thickness,center=true)
  bottom();

  color("blue")
  translate([0, w/2-thickness/2,h/2-thickness/2])
  rotate([-90,0,0])
  linear_extrude(height=thickness,center=true)
  difference(){
    side(l, h);

    if(use_label_top){
      translate([l/2-label_length/2,-h/2+thickness/2,0])
      rotate([0,0,180])
      notch(label_length, l_notch=min(length_notch, label_length/2), reverse=true);
    }
  }

  color("green")
  translate([-l/2 +thickness/2, 0,h/2-thickness/2])
  rotate([-90,0,90])
  linear_extrude(height=thickness,center=true)
  side(w, h);

  color("blue")
  translate([0, -w/2+thickness/2,h/2-thickness/2])
  rotate([-90,0,180])
  linear_extrude(height=thickness,center=true)
  difference(){
    side(l, h);
    if(use_label_top){
      translate([-l/2+label_length/2,-h/2+thickness/2,0])
      rotate([0, 0, 0])
      mirror([0,1,0])
      notch(label_length, l_notch=min(length_notch, label_length/2), reverse=true);
    }
  }

  color("green")
  translate([l/2 -thickness/2, 0,h/2-thickness/2])
  rotate([-90,0,270])
  linear_extrude(height=thickness,center=true)
  side(w, h, with_top_notch=use_label_top);

  if(use_label_top){
    color("tomato")
    translate([l/2 -label_length/2, 0,h-thickness])
    rotate([0,0,90])
    linear_extrude(height=thickness,center=true)
    label();
  }
}


module plan(){

  translate([(l + offset_laser_part)/2, -(h + offset_laser_part)/2, 0])
  rotate([0,0,0])
  mirror([1,0,0])
  difference(){
    side(l, h);

    if(use_label_top){
      translate([l/2-label_length/2,-h/2+thickness/2,0])
      rotate([0,0,180])
      notch(label_length, l_notch=min(length_notch, label_length/2), reverse=true);
    }
  }

  translate([(l + offset_laser_part)/2, (h + offset_laser_part)/2, 0])
  rotate([0,0,180])
  mirror([1,0,0])
  difference(){
    side(l, h);
    if(use_label_top){
      translate([-l/2+label_length/2,-h/2+thickness/2,0])
      rotate([0, 0, 0])
      mirror([0,1,0])
      notch(label_length, l_notch=min(length_notch, label_length/2), reverse=true);
    }
  }

  translate([-(w + offset_laser_part)/2, (h+offset_laser_part)/2, 0])
  rotate([0,0,180])
  side(w, h);

  translate([-(w + offset_laser_part)/2, -(h+offset_laser_part)/2, 0])
  rotate([0,0,0])
  side(w, h);

  translate([l + w/2 + offset_laser_part*3/2, 0, 0])
  rotate([0,0,90])
  bottom();

  if(use_label_top){
    translate([l + w + label_length/2 + 2*offset_laser_part, 0, 0])
    rotate([0,0,90])
    label();
  }
}

module g_box(){
    box();
    g_grid_base();

    if(bottom_type == 1){
      color("purple")
      grid(g_nx, g_ny, g_used_unit)
      translate([0,0,-thickness])
      rotate([90,0,90])
      linear_extrude(height=thickness, center=true)
      g_connector_piece();
    }
}

module g_plan(){

  plan();

  translate([-w -l/2 - offset_laser_part,0,0])
  g_grid_base_plan();

  if(bottom_type == 1){
    translate([-w-l*3/2 - -offset_laser_part,0,0])
    grid(g_nx, g_ny, max(g_connector_piece_feet_length, g_connector_piece_box_length) + offset_laser_part)
    g_connector_piece();
  }
}

module g_grid_base(){

  g_offset = thickness < g_thickness_theshold ? g_off_before_thickness : g_off_after_thickness;
  used_hole_unit = g_is_half_unit ? g_unit_plan/2 - g_offset : g_unit_plan - g_offset;


  translate([0, 0, -thickness*1.5])
  linear_extrude(height=thickness)
  grid(g_nx, g_ny, g_used_unit)
  difference(){
    rounded_square(used_hole_unit, g_radius);
    if(bottom_type == 1){
      square([thickness,g_connector_piece_feet_length], center=true);
    }
  }
}

module g_grid_base_plan(){
  // Half unit or not

  g_offset = thickness < g_thickness_theshold ? g_off_before_thickness : g_off_after_thickness;
  used_hole_unit = g_is_half_unit ? g_unit_plan/2 - g_offset : g_unit_plan - g_offset;


  grid(g_nx, g_ny, used_hole_unit + offset_laser_part)
  rounded_square(used_hole_unit, g_radius);
}

module g_connector_piece(){
  union(){
    translate([0, 0.5*thickness,0])
    square([g_connector_piece_box_length, 2*thickness], center=true);
    square([g_connector_piece_feet_length, thickness], center=true);
  }
}
