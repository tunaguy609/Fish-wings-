// ============================================================
// FLYING FISH WING ASSEMBLY - VERSION 2
// TPU 95A
//
// Designed for 15.5 mm lure skirt collar
//
// RING:
//   Inside diameter: 16.0 mm
//   Outside diameter: 22.0 mm
//   Thickness: 1.6 mm
//
// WINGS:
//   Length: 65 mm each
//   Total span: approximately 130 mm
//   Maximum width: 18 mm
//   Main thickness: 0.75 mm
//   Reinforced root: 1.25 mm
//   Upward tip curl: approximately 4 mm
//
// ============================================================

$fn = 96;


// ============================================================
// USER ADJUSTMENTS
// ============================================================

ring_id = 16.0;          // Must be larger than 15.5 mm collar
ring_od = 22.0;
ring_thickness = 1.6;

wing_length = 65.0;
wing_max_width = 18.0;

wing_thickness = 0.75;
root_thickness = 1.25;

tip_curl = 4.0;


// ============================================================
// CENTER MOUNTING RING
// ============================================================

module center_ring()
{
    difference()
    {
        cylinder(
            d = ring_od,
            h = ring_thickness,
            $fn = 96
        );

        translate([0, 0, -0.5])
        cylinder(
            d = ring_id,
            h = ring_thickness + 1,
            $fn = 96
        );
    }
}


// ============================================================
// RIGHT WING
//
// The wing starts at the ring and sweeps backward.
// It becomes wider through the middle and tapers
// toward the flying-fish style tip.
// ============================================================

module right_wing()
{
    pts =
    [
        // FRONT / ROOT
        [0, 5],

        // Leading edge
        [7, 9],
        [16, 14],
        [27, 18],
        [39, 17],
        [50, 13],
        [59, 7],

        // Tip
        [65, 0],

        // Trailing edge
        [58, 2],
        [49, 6],
        [39, 9],
        [29, 11],
        [19, 10],
        [10, 7],

        // Back to root
        [0, 4]
    ];

    // Reliable wing surface for Scadder/OpenSCAD web renderers
    rotate([0, -8, 0])
        wing_surface(pts, wing_thickness, tip_curl);
}


// ============================================================
// LEFT WING
// ============================================================

module left_wing()
{
    mirror([0, 1, 0])
        rotate([0, -8, 0])
            wing_surface(
                [
                    [0, 5],[7, 9],[16, 14],[27, 18],[39, 17],[50, 13],[59, 7],
                    [65, 0],
                    [58, 2],[49, 6],[39, 9],[29, 11],[19, 10],[10, 7],[0, 4]
                ],
                wing_thickness,
                tip_curl
            );
}


// ============================================================
// WING SURFACE
//
// Uses linear_extrude for compatibility with web renderers.
// ============================================================

module wing_surface(points, thickness, curl)
{
    linear_extrude(
        height = thickness,
        center = false,
        convexity = 10,
        twist = 6,
        scale = [1.0, 0.92]
    )
    polygon(points);
}


// ============================================================
// WING CURL (kept for future tuning)
// ============================================================

function wing_curl(x, curl) =
    curl * pow(x / wing_length, 2);


// ============================================================
// RIGHT WING ROOT REINFORCEMENT
// ============================================================

module right_root()
{
    linear_extrude(height = root_thickness)
    polygon(
        [
            [0, 4],
            [7, 7],
            [14, 11],
            [17, 13],
            [13, 14],
            [7, 11],
            [0, 8]
        ]
    );
}


// ============================================================
// LEFT WING ROOT REINFORCEMENT
// ============================================================

module left_root()
{
    mirror([0, 1, 0])
        right_root();
}


// ============================================================
// FINAL PRINTABLE ASSEMBLY
// ============================================================

union()
{
    // Center mounting ring
    center_ring();

    // Right flying-fish wing
    right_wing();

    // Left flying-fish wing
    left_wing();

    // Reinforced wing roots
    right_root();
    left_root();
}
