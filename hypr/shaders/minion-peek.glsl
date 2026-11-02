#version 300 es
// A minion peeks up from the bottom-right corner of your screen.
// It bobs, blinks every few seconds, and its eye follows your cursor.
// Animated: needs debug.damage_tracking = 0 (the shader cycle bind sets it).

precision highp float;

uniform sampler2D tex;
uniform float time;
uniform vec2 fullSize;
uniform vec2 pointer_position; // 0..1, provided by Hyprland
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

// If the minion hangs from the top of the screen and its eye looks the wrong way vertically, set this to 1
#define FLIP_Y 0

const float SIZE   = 0.20; // minion size, fraction of screen height
const float MARGIN = 0.80; // distance of its center from the right edge, in minion sizes

const vec3 SKIN    = vec3(1.00, 0.83, 0.10);
const vec3 DENIM   = vec3(0.18, 0.36, 0.72);
const vec3 IRIS    = vec3(0.42, 0.25, 0.08);

float fill(float d, float aa) {
    return 1.0 - smoothstep(-aa, aa, d);
}

float sdSegment(vec2 p, vec2 a, vec2 b) {
    vec2  pa = p - a, ba = b - a;
    float h  = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h);
}

// screen pixel -> minion space (units of SIZE, y up from the bottom edge, x from the minion's center)
vec2 toMinion(vec2 uv, float s, float bob) {
    vec2 pix = uv * fullSize;
#if FLIP_Y
    float up = pix.y;
#else
    float up = fullSize.y - pix.y;
#endif
    return vec2((pix.x - (fullSize.x - MARGIN * s)) / s, up / s - bob);
}

void main() {
    float s   = fullSize.y * SIZE;
    float aa  = 1.5 / s;
    float bob = 0.04 * sin(time * 2.2);

    vec2 p  = toMinion(v_texcoord, s, bob);
    vec2 pp = toMinion(pointer_position, s, bob);

    vec4 screen = texture(tex, v_texcoord);
    vec3 col    = screen.rgb;

    // body: capsule sticking up from below the screen edge
    float body = length(p - vec2(0.0, clamp(p.y, -1.0, 0.6))) - 0.5;
    float bodyMask = fill(body, aa);

    vec3 m = SKIN * (0.78 + 0.22 * (1.0 - 3.0 * p.x * p.x));

    // overalls, shoulder straps and buttons
    vec2 ap = vec2(abs(p.x), p.y);
    m = mix(m, DENIM, fill(p.y - 0.12, aa));
    m = mix(m, DENIM, fill(sdSegment(ap, vec2(0.28, 0.10), vec2(0.46, 0.34)) - 0.045, aa));
    m = mix(m, vec3(0.08), fill(length(ap - vec2(0.29, 0.13)) - 0.028, aa));

    // mouth (little smile)
    vec2 mo = p - vec2(0.0, 0.40);
    m = mix(m, vec3(0.30, 0.10, 0.05), fill(abs(length(mo) - 0.14) - 0.014, aa) * step(mo.y, -0.06));

    // goggle strap
    m = mix(m, vec3(0.08), fill(abs(p.y - 0.68) - 0.075, aa));

    // goggle rim
    vec2  e  = p - vec2(0.0, 0.68);
    float re = length(e);
    vec3  rim = vec3(0.62, 0.64, 0.68) * (0.65 + 0.35 * dot(e / max(re, 1e-4), normalize(vec2(-0.6, 0.8))));
    m = mix(m, rim, fill(re - 0.30, aa));
    m = mix(m, vec3(0.15), fill(abs(re - 0.30) - 0.008, aa));

    // eye: white, iris + pupil looking at the cursor, highlight
    vec2  look = pp - vec2(0.0, 0.68);
    vec2  gaze = normalize(look + vec2(1e-4)) * 0.09 * clamp(length(look) / 2.0, 0.0, 1.0);
    vec3  eye  = vec3(0.97);
    eye = mix(eye, IRIS, fill(length(e - gaze) - 0.10, aa));
    eye = mix(eye, vec3(0.02), fill(length(e - gaze) - 0.05, aa));
    eye = mix(eye, vec3(1.0), fill(length(e - gaze - vec2(-0.03, 0.03)) - 0.018, aa));

    // blink: an eyelid of skin slides down every 4 seconds
    float phase = mod(time, 4.0);
    float blink = phase < 0.18 ? sin(phase / 0.18 * 3.14159) : 0.0;
    float lidEdge = 0.22 - 0.44 * blink;
    eye = mix(eye, SKIN * 0.92, fill(lidEdge - e.y, aa) * step(0.001, blink));
    eye = mix(eye, vec3(0.25, 0.15, 0.02), fill(abs(e.y - lidEdge) - 0.01, aa) * step(0.001, blink));

    m = mix(m, eye, fill(re - 0.22, aa));

    // cartoon outline
    m = mix(m, vec3(0.1), fill(abs(body) - 0.012, aa));

    col = mix(col, m, bodyMask);

    // a few hairs on top
    float hair = 1e9;
    for (int i = -2; i <= 2; i++) {
        float x = float(i) * 0.07;
        hair = min(hair, sdSegment(p, vec2(x, 1.05), vec2(x * 1.9, 1.22 + 0.02 * float(2 - abs(i)))));
    }
    col = mix(col, vec3(0.05), fill(hair - 0.010, aa));

    fragColor = vec4(col, screen.a);
}
