// Inside diameter
socket_diameter = 28;
socket_radius = socket_diameter / 2;
// Inside height
socket_height = 20;

// Outside
cone_height = 33;
//total_height = 53;
//cone_height = total_height - socket_height;

// Outside diameter
trim_diameter = 150;
trim_radius = trim_diameter / 2;

// Outer width of mounting tab
mount_width = 10;
// Distance between close screw holes
mount_separation = 70;
// Inside diameter
mount_hole = 5;

// Thickness
wall_thickness = 2;
wall_half = wall_thickness / 2;
wall_double = wall_thickness * 2;

// Outside diameter
cone_diameter = mount_separation - mount_hole - mount_width; //95;
cone_radius = cone_diameter / 2;
cone_angle = atan((cone_height + wall_thickness) / (cone_radius - socket_radius));
echo(cone_angle);

section_view = true;
sqrt2 = sqrt(2);
$fa = $preview ? 15 : 1;
$fs = $preview ? 3 : 1;

// soh | sin(a) = opp / hyp
// cah | cos(a) = adj / hyp
// toa | tan(a) = opp / adj
/*
rotate(cone_angle, [0,0,1])
square(10);
*/

/*
difference() {
	body();
	//mount();
	if ($preview && section_view) {
		translate([0, 0, -1])
			cube(trim_diameter);
	}
}
*/
difference() {
	rotate_extrude(angle=360, convexity=10)
		outline_points();
	translate([0, 0, socket_height + cone_height])
		mount_holes();
	if ($preview && section_view) {
		translate([0, 0, -wall_thickness-1])
			cube(trim_diameter);
	}
}

module outline_points() {
	a = cone_angle / 2;
	hyp = wall_thickness / cos(a);
	polygon([
		[0, 0],
		[socket_radius, 0], // __|
		[
			socket_radius, // /
			socket_height  // |
		],
		[
			cone_radius,                                 //  __
			socket_height + cone_height + wall_thickness // /
		],
		[
			trim_radius - wall_double,                   // __
			socket_height + cone_height + wall_thickness //   \
		],
		[
			trim_radius,
			socket_height + cone_height - wall_thickness // __\
		],
		[
			trim_radius - wall_thickness*sqrt2,
			socket_height + cone_height - wall_thickness // \__
		],
		[
			trim_radius - wall_thickness-wall_thickness*sqrt2, // __
			socket_height + cone_height                        //   \
		],
		[
			cone_radius + hyp*sin(a),   //   __
			socket_height + cone_height //  /
		],
		[
			socket_radius + wall_thickness,             // /
			socket_height - wall_thickness + hyp*sin(a) // |
		],
		[
			socket_radius + wall_thickness, // __|
			-wall_thickness
		],
		[
			0,
			-wall_thickness // |__
		],
	]);
}

module mount(wall = 0) {
	y = mount_width + wall*2;
	cylinder(d=y, h=cone_height);
	translate([0, -y/2, 0])
		cube([(cone_diameter-mount_separation)/2, y, cone_height]);
}

module mounts(wall = 0) {
	translate([mount_separation/2, 0, 0])
		mount(wall);
	rotate(180, [0,0,1])
		translate([mount_separation/2, 0, 0])
			mount(wall);
}

module mount_holes() {
	translate([mount_separation/2, 0, 0])
		cylinder(d1=mount_hole, d2=mount_hole+wall_double, h=wall_thickness);
		//cylinder(d=mount_hole, h=wall_thickness+1);
	rotate(180, [0,0,1])
		translate([mount_separation/2, 0, 0])
			cylinder(d1=mount_hole, d2=mount_hole+wall_double, h=wall_thickness);
			//cylinder(d=mount_hole, h=wall_thickness+1);
}

module body() {
	difference() {
		union() {
			// Socket
			cylinder(d=socket_diameter+wall_double, h=socket_height+wall_thickness);

			// Cone
			translate([0, 0, socket_height])
				cylinder(
					d1=socket_diameter+wall_double,
					d2=cone_diameter,
					h=cone_height
				);

			// Trim
			translate([0, 0, socket_height+cone_height-wall_thickness])
				difference() {
					cylinder(
						d1=trim_diameter+wall_double,
						d2=trim_diameter-wall_double,
						h=wall_thickness*2
					);
					cylinder(
						d1=trim_diameter,
						d2=trim_diameter-wall_double,
						h=wall_thickness
					);
				}
		}

		// Socket
		translate([0, 0, wall_thickness])
			cylinder(d=socket_diameter, h=socket_height+1);

		// Cone
		translate([0, 0, socket_height+wall_thickness])
			difference() {
				cylinder(
					d1=socket_diameter,
					d2=cone_diameter-wall_double,
					h=cone_height
				);
				mounts(wall_thickness);
			}

		translate([0, 0, socket_height]) {
			mounts();
			translate([0, 0, cone_height]) {
				mount_holes();
			}
		}

		if ($preview) {
			// Helper
			translate([0, 0, socket_height+cone_height+wall_thickness-0.001])
				cylinder(d=cone_diameter-wall_double, h=1);
		}
	}
}
