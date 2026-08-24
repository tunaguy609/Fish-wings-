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
// aggressively toward the flying-fish style tip.
// ============================================================

module right_wing()
{
    pts =
    [
        // -------------------------
        // FRONT / ROOT
        // -------------------------

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

        // -------------------------
        // TRAILING EDGE
        // -------------------------

        [58, 2],
        [49, 6],
        [39, 9],
        [29, 11],
        [19, 10],
        [10, 7],

        // Back to root
        [0, 4]
    ];

    wing_surface(
        pts,
        wing_thickness,
        tip_curl
    );
}


// ============================================================
// LEFT WING
// ============================================================

module left_wing()
{
    mirror([0, 1, 0])
        right_wing();
}


// ============================================================
// WING SURFACE
//
// Creates a thin 3D wing while gradually raising the
// outer tip for the flying-fish curl.
// ============================================================

module wing_surface(points, thickness, curl)
{
    n = len(points);

    bottom =
    [
        for (p = points)
        [
            p[0],
            p[1],
            wing_curl(p[0], curl)
        ]
    ];

    top =
    [
        for (p = points)
        [
            p[0],
            p[1],
            wing_curl(p[0], curl) + thickness
        ]
    ];

    vertices = concat(bottom, top);

    faces = [];

    // Bottom face
    faces = concat(
        faces,
        [
            [for (i = [n-1:-1:0]) i]
        ]
    );

    // Top face
    faces = concat(
        faces,
        [
            [for (i = [0:n-1]) i+n]
        ]
    );

    // Outside walls
    for (i = [0:n-1])
    {
        j = (i + 1) % n;

        faces = concat(
            faces,
            [
                [i, j, j+n, i+n]
            ]
        );
    }

    polyhedron(
        points = vertices,
        faces = faces,
        convexity = 10
    );
}


// ============================================================
// WING CURL
//
// Flat near the ring.
// Gradually rises toward the outer tip.
// ============================================================

function wing_curl(x, curl) =
    curl * pow(x / wing_length, 2);


// ============================================================
// RIGHT WING ROOT REINFORCEMENT
//
// Thicker TPU where the flexible wing meets the ring.
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
