#version 300 es
// Black hole that follows your cursor: gravitational lensing (Einstein ring),
// a spinning tilted accretion disk with one side brighter (Doppler beaming), and a photon ring.
// Your original blackhole.glsl is untouched; this one uses the real `time` + cursor uniforms.
// Animated: needs debug.damage_tracking = 0 (the shader cycle bind sets it).

precision highp float;

uniform sampler2D tex;
uniform float time;
uniform vec2 fullSize;
uniform vec2 pointer_position; // 0..1, provided by Hyprland
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

// If the hole moves the opposite way vertically to your cursor, set this to 1
#define FLIP_Y 0

const float HORIZON    = 0.035; // event horizon radius, fraction of screen height
const float EINSTEIN   = 0.060; // lensing strength (Einstein ring radius)
const float DISK_INNER = 1.6;   // in horizon radii
const float DISK_OUTER = 4.5;
const float DISK_TILT  = 0.28;  // 1 = face-on, small = edge-on
const float SPIN       = 2.5;

vec2 mirror(vec2 uv) {
    return 1.0 - abs(1.0 - mod(uv, 2.0));
}

void main() {
    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2  scale  = vec2(aspect, 1.0);

    vec2 center = pointer_position;
#if FLIP_Y
    center.y = 1.0 - center.y;
#endif

    vec2  p = (v_texcoord - center) * scale;
    float r = length(p);

    // lensing: the classic point-lens mapping, source = p - rE^2 * p / r^2
    vec2 src = p - EINSTEIN * EINSTEIN * p / max(r * r, 1e-5);
    vec3 col = texture(tex, mirror(src / scale + center)).rgb;

    // photon ring
    float ring = exp(-pow((r - HORIZON * 1.08) / (HORIZON * 0.10), 2.0));
    col += vec3(1.0, 0.85, 0.6) * ring * 1.2;

    // event horizon
    float hole = 1.0 - smoothstep(HORIZON * 0.97, HORIZON * 1.03, r);
    col = mix(col, vec3(0.0), hole);

    // accretion disk (tilted ellipse), front half drawn over the hole
    vec2  q     = vec2(p.x, p.y / DISK_TILT) / HORIZON;
    float dr    = length(q);
    float band  = smoothstep(DISK_INNER, DISK_INNER + 0.4, dr) * (1.0 - smoothstep(DISK_OUTER - 1.2, DISK_OUTER, dr));
    float ang   = atan(q.y, q.x);
    float streak = 0.55 + 0.45 * sin(ang * 7.0 - time * SPIN * 3.0 + dr * 5.0)
                        * sin(ang * 3.0 + time * SPIN + dr * 2.0);
    float doppler = 1.0 + 0.8 * (q.x / max(dr, 1e-4));
    float heat    = 1.0 - clamp((dr - DISK_INNER) / (DISK_OUTER - DISK_INNER), 0.0, 1.0);
    vec3  diskCol = mix(vec3(0.9, 0.25, 0.02), vec3(1.0, 0.95, 0.8), heat * heat);

    bool  behind = r < HORIZON * 1.03 && q.y < 0.0;
    float disk   = behind ? 0.0 : band * streak * doppler;
    col += diskCol * disk;

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
