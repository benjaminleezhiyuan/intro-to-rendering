R"(
#version 330 core

uniform float iTime;
uniform vec2 iResolution;  // Viewport resolution (in pixels)

in vec3 TexCoord;

out vec4 FragColor;

void main()
{
    // Calculate normalized coordinates
    vec2 uv = gl_FragCoord.xy / iResolution;

    // Create a kaleidoscope pattern
    float numSegments = 24.0;
    float angle = iTime;

    // Calculate polar coordinates
    float radius = length(uv - 0.5);
    float theta = atan(uv.y - 0.5, uv.x - 0.5);

    // Apply kaleidoscope symmetry
    theta = mod(theta + angle, 2.0 * 3.1416 / numSegments);
    theta = abs(theta - 3.1416 / numSegments);

    // Convert back to Cartesian coordinates
    uv = vec2(cos(theta) * radius + 0.5, sin(theta) * radius + 0.5);

    // Create a color pattern using sine and cosine functions
    float r = 0.5 + 0.5 * sin(iTime + uv.x * 10.0);
    float g = 0.5 + 0.5 * cos(iTime + uv.y * 10.0);
    float b = 0.5 + 0.5 * sin(iTime + uv.x * 5.0 + uv.y * 5.0);

    // Set the final color
    FragColor = vec4(r, g, b, 1.0);
}

)"