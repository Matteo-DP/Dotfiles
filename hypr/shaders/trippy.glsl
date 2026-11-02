#version 300 es
// Trippy: breathing swirl, wobbling radial warp, rotating RGB split,
// hue cycling across the screen and rainbow ripple bands. Not for productivity.
// Animated: needs debug.damage_tracking = 0 (the shader cycle bind sets it).

precision highp float;

uniform sampler2D tex;
uniform float time;
uniform vec2 fullSize;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

const float SWIRL      = 0.35;  // max swirl angle (radians) at the center
const float WOBBLE     = 0.010;
const float RGB_SPLIT  = 0.004;
const float HUE_SPEED  = 0.8;
const float SATURATION = 1.6;
const float RAINBOW    = 0.25;  // strength of the rainbow bands overlay

// rotate a color around the grey axis
vec3 hueShift(vec3 c, float a) {
    const vec3 k = vec3(0.57735);
    float ca = cos(a);
    return c * ca + cross(k, c) * sin(a) + k * dot(k, c) * (1.0 - ca);
}

vec2 mirror(vec2 uv) {
    return 1.0 - abs(1.0 - mod(uv, 2.0));
}

void main() {
    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2  scale  = vec2(aspect, 1.0);
    vec2  p      = (v_texcoord - 0.5) * scale;

    float r   = length(p);
    float ang = atan(p.y, p.x);

    ang += SWIRL * sin(time * 0.7) * exp(-r * 2.0);
    r   += WOBBLE * sin(ang * 6.0 + time * 2.0);

    vec2 uv = mirror(vec2(cos(ang), sin(ang)) * r / scale + 0.5);

    vec2 d   = RGB_SPLIT * vec2(cos(time * 1.3), sin(time * 1.7));
    vec3 col = vec3(texture(tex, mirror(uv + d)).r, texture(tex, uv).g, texture(tex, mirror(uv - d)).b);

    col = hueShift(col, time * HUE_SPEED + r * 6.0 + sin(v_texcoord.y * 10.0 + time) * 0.5);

    float l = dot(col, vec3(0.299, 0.587, 0.114));
    col     = mix(vec3(l), col, SATURATION);

    vec3 rainbow = 0.5 + 0.5 * cos(6.28318 * (vec3(0.0, 0.33, 0.67) + r * 3.0 - time * 0.5));
    col          = mix(col, col * rainbow * 1.4, RAINBOW);

    fragColor = vec4(clamp(col, 0.0, 1.0), texture(tex, v_texcoord).a);
}
