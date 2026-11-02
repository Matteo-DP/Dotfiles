#version 300 es
precision mediump float;

uniform sampler2D tex;   // provided by Hyprland
in vec2 v_texcoord;      // provided by Hyprland
out vec4 fragColor;

// 0.0 = no darkening, 1.0 = very dark.
// If you don't set it via Hyprland, most drivers default this to 0.0.
// Pass a value (e.g., 0.85) from your config for "extra dark".
const float u_strength = 0.60;

void main() {
    vec4 c = texture(tex, v_texcoord);

    // Map strength to a brightness multiplier:
    // strength=0.0 -> factor=1.0 (no change)
    // strength=1.0 -> factor=0.15 (very dark)
    float factor = 1.0 - 0.85 * clamp(u_strength, 0.0, 1.0);

    fragColor = vec4(c.rgb * factor, c.a);
}

