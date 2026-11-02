#version 300 es
precision mediump float;

uniform sampler2D tex; // provided by Hyprland
in vec2 v_texcoord; // provided by Hyprland
out vec4 fragColor;

// Fake time animation using texture noise
float fake_time(vec2 uv) {
    vec3 n = texture(tex, uv * 0.1).rgb;
    return (n.r + n.g + n.b) * 10.0;
}

void main() {
    vec2 uv = v_texcoord;
    vec2 center = vec2(0.5);
    vec2 p = uv - center;
    float r = length(p);

    // Aspect correction removed (Hyprland handles coords correctly)

    // "Time"
    float t = fake_time(uv);

    // Parameters
    float bhRadius = 0.015;
    float diskRadius = 0.20;
    float diskWidth = 0.9;
    float lensStrength = 0.25;

    // Event horizon (black)
    if (r < bhRadius) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Gravitational lensing (radial displacement)
    float lens = lensStrength * exp(-pow((r - bhRadius) * 8.0, 2.0)) / (r + 0.001);
    vec2 dir = normalize(p);
    vec2 lensedUV = uv + dir * lens;

    // Background
    vec4 bg = texture(tex, clamp(lensedUV, 0.0, 1.0));

    // Accretion disk
    float dr = abs(r - diskRadius);
    float diskMask = smoothstep(diskWidth, 0.0, dr);

    float ang = atan(p.y, p.x);
    float swirl = sin(ang * 8.0 - t * 0.7);

    float diskBrightness = diskMask * (0.5 + 0.5 * swirl);

    // Disk color (orange → yellow → white)
    float d = 1.0 - smoothstep(bhRadius, diskRadius + diskWidth, r);
    vec3 diskColor = mix(
            vec3(1.0, 0.45, 0.05),
            vec3(1.0, 0.9, 0.6),
            d
        );

    // Halo glow
    float halo = exp(-pow((r - bhRadius) * 15.0, 2.0)) * 0.6;

    vec3 color = bg.rgb * (1.0 - halo) +
            diskColor * diskBrightness +
            vec3(halo * 0.8);

    fragColor = vec4(color, 1.0);
}
