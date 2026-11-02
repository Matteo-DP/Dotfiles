#version 300 es
// Every mouse click drops a stone in a pond: an expanding water ripple
// that refracts the screen and fades out. Up to 32 ripples at once.
// Animated: needs debug.damage_tracking = 0 (the shader cycle bind sets it).

precision highp float;

uniform sampler2D tex;
uniform vec2 fullSize;
uniform vec2 pointer_pressed_positions[32]; // newest first, 0..1, provided by Hyprland
uniform float pointer_pressed_times[32];    // seconds since each press
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

// If ripples appear mirrored vertically from where you click, set this to 1
#define FLIP_Y 0

const float LIFETIME  = 1.4;   // seconds
const float SPEED     = 0.45;  // ripple radius growth, screen heights per second
const float STRENGTH  = 0.018;
const float WAVELEN   = 0.035;

void main() {
    float aspect = fullSize.x / max(fullSize.y, 1.0);
    vec2  scale  = vec2(aspect, 1.0);

    vec2  offset = vec2(0.0);
    float light  = 0.0;

    for (int i = 0; i < 32; i++) {
        float t = pointer_pressed_times[i];
        if (t > LIFETIME)
            continue;

        vec2 c = pointer_pressed_positions[i];
#if FLIP_Y
        c.y = 1.0 - c.y;
#endif
        vec2  d    = (v_texcoord - c) * scale;
        float dist = length(d);
        float x    = (dist - t * SPEED) / WAVELEN;
        float fade = (1.0 - t / LIFETIME);
        float wave = sin(x * 6.28318) * exp(-x * x * 0.5) * fade * fade;

        offset += (d / max(dist, 1e-4)) * wave * STRENGTH;
        light  += wave;
    }

    vec2 uv  = clamp(v_texcoord + offset / scale, 0.0, 1.0);
    vec4 col = texture(tex, uv);
    col.rgb += vec3(0.08, 0.12, 0.15) * light;

    fragColor = vec4(clamp(col.rgb, 0.0, 1.0), col.a);
}
