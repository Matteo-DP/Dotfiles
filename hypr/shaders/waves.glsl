#version 300 es
// Underwater: the whole screen gently sways like it's under water,
// with rainbow fringing on the waves and caustic light shimmering over it.
// Animated: needs debug.damage_tracking = 0 (the shader cycle bind sets it).

precision highp float;

uniform sampler2D tex;
uniform float time;
uniform vec2 fullSize;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

const float AMPLITUDE = 0.005; // how far the waves push pixels (fraction of screen)
const float SPEED     = 1.0;
const float TINT      = 0.30;  // 0 = no underwater tint

vec2 waveOffset(vec2 uv, float t, float aspect) {
    vec2 p = vec2(uv.x * aspect, uv.y);
    float w1 = sin(p.y * 16.0 + t * 1.9);
    float w2 = sin(p.x * 11.0 - t * 1.4 + p.y * 5.0);
    float w3 = sin(length(p - vec2(aspect * 0.5, 0.5)) * 28.0 - t * 2.6);
    return vec2(w1 + 0.5 * w3, w2 + 0.5 * w3) * AMPLITUDE;
}

float caustics(vec2 uv, float t, float aspect) {
    vec2 p = vec2(uv.x * aspect, uv.y) * 7.0;
    float c = 0.0;
    for (int i = 0; i < 3; i++) {
        float fi = float(i);
        p += vec2(sin(p.y + t * (0.6 + 0.2 * fi)), cos(p.x - t * (0.5 + 0.15 * fi)));
        c += sin(p.x + p.y);
    }
    return pow(max(0.0, c / 3.0), 6.0);
}

void main() {
    float aspect = fullSize.x / max(fullSize.y, 1.0);
    float t      = time * SPEED;

    vec2 off = waveOffset(v_texcoord, t, aspect);
    vec2 uv  = clamp(v_texcoord + off, 0.0, 1.0);

    // chromatic fringe that grows with the wave displacement
    vec2 split = vec2(length(off) * 0.7, 0.0);
    vec4 base  = texture(tex, uv);
    vec3 col   = vec3(texture(tex, clamp(uv + split, 0.0, 1.0)).r, base.g, texture(tex, clamp(uv - split, 0.0, 1.0)).b);

    col  = mix(col, col * vec3(0.80, 1.00, 1.12), TINT);
    col += vec3(0.06, 0.10, 0.12) * caustics(v_texcoord, t, aspect);

    fragColor = vec4(clamp(col, 0.0, 1.0), base.a);
}
