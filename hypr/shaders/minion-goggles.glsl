#version 300 es
// Minion vision: you're looking at your desktop through a minion's goggle.
// Fisheye-magnified lens with a glass glint, chrome rim with bolts,
// the black goggle strap, and yellow minion head all around it.
// Static: works with damage tracking on, cheap to leave running.

precision highp float;

uniform sampler2D tex;
uniform vec2 fullSize;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

const float LENS    = 0.42;  // lens radius, fraction of screen height
const float RIM     = 0.49;  // outer rim radius
const float STRAP   = 0.10;  // half height of the strap
const float FISHEYE = 0.18;  // 0 = flat glass
const vec3  SKIN    = vec3(1.00, 0.84, 0.12);

float fill(float d, float aa) {
    return 1.0 - smoothstep(-aa, aa, d);
}

void main() {
    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2  scale  = vec2(aspect, 1.0);
    vec2  p      = (v_texcoord - 0.5) * scale;
    float r      = length(p);
    float aa     = 1.5 / max(fullSize.y, 1.0);
    vec2  n      = p / max(r, 1e-5);

    // head skin with some roundness shading, and the strap across it
    vec3 col = SKIN * (1.0 - 0.35 * pow(length(p / scale) * 1.3, 2.0));
    float strap = fill(abs(p.y) - STRAP, aa);
    vec3  strapCol = vec3(0.07) + vec3(0.05) * smoothstep(STRAP - 0.02, STRAP - 0.012, abs(p.y));
    col = mix(col, strapCol, strap);

    // chrome rim: light from top-left, bevelled profile, 8 bolts
    float rimT  = clamp((r - LENS) / (RIM - LENS), 0.0, 1.0);
    float bevel = sin(rimT * 3.14159);
    float shade = 0.45 + 0.35 * dot(n, normalize(vec2(-0.6, -0.8))) + 0.35 * bevel;
    vec3  rimCol = vec3(0.62, 0.64, 0.68) * shade;
    float boltAng = floor(atan(p.y, p.x) / 6.28318 * 8.0 + 0.5) / 8.0 * 6.28318;
    vec2  bolt    = vec2(cos(boltAng), sin(boltAng)) * (LENS + RIM) * 0.5;
    rimCol = mix(rimCol, vec3(0.30), fill(length(p - bolt) - 0.010, aa));
    col = mix(col, rimCol, fill(r - RIM, aa));
    // dark edge where rim meets the skin
    col = mix(col, vec3(0.1), fill(abs(r - RIM) - 0.003, aa));

    // the lens: fisheye magnification, edge darkening, glass glint
    float k   = r / LENS;
    vec2  src = p * (1.0 - FISHEYE + FISHEYE * k * k);
    vec3  view = texture(tex, clamp(src / scale + 0.5, 0.0, 1.0)).rgb;
    view *= 1.0 - 0.45 * pow(k, 4.0);
    float glint = fill(abs(dot(p, normalize(vec2(1.0, 1.0))) + LENS * 0.45) - 0.025, aa) * smoothstep(0.2, 0.9, k);
    view += vec3(0.10) * glint;
    col = mix(col, view, fill(r - LENS, aa));

    fragColor = vec4(clamp(col, 0.0, 1.0), 1.0);
}
