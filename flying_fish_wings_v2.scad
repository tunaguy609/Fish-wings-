// ============================================================
// LOFTED FLYING FISH WINGS
// TPU 95A
//
// Parametric flying-fish style fins sized around a 15.5 mm
// lure skirt collar. The wings are built from stacked rounded
// sections that are hulled together for a smoother, more
// organic fin profile than a flat polygon extrusion.
// ============================================================

$fn = 72;


// ============================================================
// USER ADJUSTMENTS
// ============================================================

collar_diameter       = 15.5;
collar_clearance      = 0.7;

ring_inner_diameter   = collar_diameter + collar_clearance;
ring_outer_diameter   = 22.4;
ring_thickness        = 1.8;

wing_sections         = 9;
section_detail        = 28;
mid_span_bias         = 0.46;

wing_span             = 62.0;
wing_root_overlap     = 1.6;
wing_root_offset      = 0.0;
wing_sweep_back       = 0.0;
wing_tip_lift         = 5.8;
wing_tip_pitch        = 18.0;

wing_root_chord       = 13.0;
wing_mid_chord        = 21.0;
wing_tip_chord        = 5.8;

wing_root_thickness   = 2.2;
wing_mid_thickness    = 1.35;
wing_tip_thickness    = 0.8;

wing_root_depth       = 4.4;
wing_mid_depth        = 3.1;
wing_tip_depth        = 1.4;

root_anchor_depth     = 7.0;
root_anchor_chord     = 8.5;
root_anchor_thickness = 2.5;


// ============================================================
// HELPERS
// ============================================================

function clamp01(v) = max(0, min(1, v));
function lerp(a, b, t) = a + (b - a) * t;
function smoothstep(t) =
    let(u = clamp01(t))
        u * u * (3 - 2 * u);

function blend_profile(t, start_value, peak_value, end_value, peak_t) =
    t < peak_t
        ? lerp(start_value, peak_value, smoothstep(t / peak_t))
        : lerp(peak_value, end_value, smoothstep((t - peak_t) / (1 - peak_t)));

function chord_at(t) =
    blend_profile(t, wing_root_chord, wing_mid_chord, wing_tip_chord, mid_span_bias);

function thickness_at(t) =
    blend_profile(t, wing_root_thickness, wing_mid_thickness, wing_tip_thickness, 0.52);

function depth_at(t) =
    blend_profile(t, wing_root_depth, wing_mid_depth, wing_tip_depth, 0.40);

function span_x(t) =
    ring_outer_diameter / 2 - wing_root_overlap + wing_span * t;

function span_y(t) =
    wing_root_offset
    - wing_sweep_back * pow(t, 1.15)
    + 1.2 * sin(180 * t);

function span_z(t) =
    ring_thickness * 0.35 + wing_tip_lift * pow(t, 1.6);

function pitch_at(t) =
    wing_tip_pitch * pow(t, 1.35);


// ============================================================
// CORE SHAPES
// ============================================================

module center_ring()
{
    difference()
    {
        cylinder(d = ring_outer_diameter, h = ring_thickness);

        translate([0, 0, -0.5])
            cylinder(d = ring_inner_diameter, h = ring_thickness + 1);
    }
}

module loft_section(length, chord, thickness)
{
    scale([length / 2, chord / 2, thickness / 2])
        sphere(r = 1, $fn = section_detail);
}

module wing_anchor()
{
    translate([ring_outer_diameter * 0.16, wing_root_offset * 0.90, ring_thickness * 0.45])
        rotate([4, 0, 0])
            loft_section(root_anchor_depth, root_anchor_chord, root_anchor_thickness);
}

module wing_section(t)
{
    translate([span_x(t), span_y(t), span_z(t)])
        rotate([pitch_at(t), 0, 0])
            loft_section(depth_at(t), chord_at(t), thickness_at(t));
}


// ============================================================
// WING LOFT
// ============================================================

module single_wing()
{
    hull()
    {
        wing_anchor();
        wing_section(0);
    }

    for (i = [0 : wing_sections - 2])
    {
        hull()
        {
            wing_section(i / (wing_sections - 1));
            wing_section((i + 1) / (wing_sections - 1));
        }
    }
}


// ============================================================
// FINAL PRINTABLE ASSEMBLY
// ============================================================

union()
{
    center_ring();

    single_wing();

    mirror([0, 1, 0])
        single_wing();
}
