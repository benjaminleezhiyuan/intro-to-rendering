/*!
@file 
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 5
@date 11/2/2024
@brief Implementation of assignment fragment shader
*/

R"(
#version 420

// Material properties for reflection and refraction
struct Material 
{
    vec4 color;             
    float reflectionFactor; // The light reflection factor
    float eta;              // The ratio of indices of refraction
};


vec4 checkerboardTexture(vec2 uv, float size)
{
    // Calculate the position within the checkerboard texture
    vec2 uvScaled = uv * size;

    // Determine which square the UV coordinates are in
    int x = int(floor(uvScaled.x)) % 2;
    int y = int(floor(uvScaled.y)) % 2;

    // If both x and y are either both even or both odd, it's black; otherwise, it's white
    if ((x == 0 && y == 0) || (x == 1 && y == 1))
    {
        return vec4(0.0f, 0.0f, 0.0f, 1.0f); // Black
    }
    else
    {
        return vec4(1.0f, 1.0f, 1.0f, 1.0f); // White
    }
}


vec2 vec2uv(vec3 v) {
    // Take the absolute value of v
    vec3 absolute_v = abs(v);
    vec2 uv;

    // Determine which face of the cube v lies on
    if (v.x >= absolute_v.y && v.x >= absolute_v.z) {
        // Right face
        uv = vec2(-v.z, -v.y) / v.x / 2.0f + 0.5f;
        uv.x = 1.0f - uv.x;
        uv.y = 1.0f - uv.y;
    }
    else if (absolute_v.x > absolute_v.y && absolute_v.x > absolute_v.z) {
        // Left face
        uv = vec2(v.z, -v.y) / absolute_v.x / 2.0f + 0.5f;
        uv.x = 1.0f - uv.x;
        uv.y = 1.0f - uv.y;
    }
    else if (absolute_v.y > absolute_v.z) {
        // Top / Bottom face, which we're not handling, returning (0, 0)
        return vec2(0.0f, 0.0f);
    }
    else {
        // Front / Back face
        uv = vec2(v.x, -v.y) / absolute_v.z / 2.0f + 0.5f;
        if (v.z > 0) uv.x = 1.0f - uv.x;
        uv.y = 1.0f - uv.y;
    }

    // Clamp uv within the range of [0, 1]
    uv = clamp(uv, 0.0f, 1.0f);
    return uv;
}

uniform int Pass; // Pass number

layout(binding=0) uniform samplerCube CubeMapTex;

layout(location=0) out vec4 FragColor;


// Pass 0

in vec3 Vec;


void pass0() 
{
    // Access the cube map texture
    vec4 color = checkerboardTexture(vec2uv(Vec), 8.0f);

    // Gamma correction
    color.rgb = pow(color.rgb, vec3(1.0f/2.2f));

    FragColor = color;
}

// Pass 1

in vec3 ReflectDir;
in vec3 RefractDir;

uniform Material material;

void pass1() 
{
    // Access the cube map texture
    vec4 color = checkerboardTexture(vec2uv(ReflectDir), 10.0f);

    // Gamma correction
    color.rgb = pow(color.rgb, vec3(1.0f/2.2f));

    FragColor = color;
}


void main()
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
}
)"
