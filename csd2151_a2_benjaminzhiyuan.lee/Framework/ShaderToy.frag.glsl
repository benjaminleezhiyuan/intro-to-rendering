R"(
#version 330 core

uniform float iTime;
uniform vec2 iResolution;  // Viewport resolution (in pixels)

in vec3 TexCoord;

out vec4 FragColor;

// Simple permute function
// Source: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
vec3 permute(vec3 x) {
    return mod(((x*34.0)+1.0)*x, 289.0);
}

// Simplex Noise function
// Source: https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                       -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
   		   + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}


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

    // Add noise for more randomness
    float noiseValue = snoise(uv * 10.0);
    r += 0.2 * noiseValue;
    g += 0.2 * noiseValue;
    b += 0.2 * noiseValue;

    // Set the final color
    FragColor = vec4(r, g, b, 1.0);
}

)"