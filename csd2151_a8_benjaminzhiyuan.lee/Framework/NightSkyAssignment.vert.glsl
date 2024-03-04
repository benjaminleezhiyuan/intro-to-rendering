/*!
@file NightSkyAssignment.vert.glsl
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 8
@date 04/03/2024
@brief Implementation of assignment vertex shader 
*/

R"(
#version 330 core

/*
   This vertex shader calculates the vertex position in clipping space for both passes.
   For the first pass, it also calculates vectors for skybox mapping.
   For the second pass, it also calculates normals and positions in view space.
   All texture coordinates are passed through.
*/

struct Camera {
    vec3 position;    // In world space
};

struct Material 
{
    // For PBR
    float rough;            // Roughness
    float metal;            // Metallic (1.0f) or dielectric (0.0f)
    vec3 color;
    float effect;           // Additional effect (discard, cartoon, etc)
    vec3 Ka;            // Ambient reflectivity
    vec3 Kd;            // Diffuse reflectivity
    vec3 Ks;            // Specular reflectivity
    float shininess;    // Specular shininess factor
};


// Pass 0
in vec3 VertexPosition;
in vec3 VertexNormal;
in vec3 VertexTexCoord;

uniform mat4 M; // Model transform matrix
uniform mat4 V; // View transform matrix
uniform mat4 P; // Projection transform matrix
uniform int Pass; // Pass number
uniform Camera camera;
uniform Material material;

out vec3 TexCoord; 
out vec3 ReflectDir;
out vec3 RefractDir;
out vec3 Normal;
out vec3 ViewPosition;
out vec3 Vec;

vec4 worldPos;
vec3 worldNormal;

// Function to calculate vertex position in clipping space
vec4 calculateClipSpacePosition(vec3 vertexPosition) {
    return P * V * M * vec4(vertexPosition, 1.0);
}

// Pass 0
void pass0()
{
    Vec = VertexPosition; // Skybox uses position for sampling cube map
    worldPos = M * vec4(VertexPosition, 1.0);
    gl_Position = P * V * worldPos;
}

// Pass 1
void pass1()
{
    // Calculate the vertex position in clipping space
    gl_Position = calculateClipSpacePosition(VertexPosition);
    
    // Pass through texture coordinates
    TexCoord = VertexTexCoord;

    // Calculate normals and positions in view space
    worldPos = M * vec4(VertexPosition, 1.0);
    worldNormal = normalize(mat3(M) * VertexNormal);
    ViewPosition = (V * worldPos).xyz;
    Normal = normalize(mat3(V * M) * VertexNormal);

    // Calculate the reflection direction
    vec3 viewDirection = normalize(worldPos.xyz - camera.position);
    ReflectDir = reflect(viewDirection, worldNormal);

    // Calculate the refraction direction (using Snell's Law)
    RefractDir = refract(viewDirection, worldNormal, material.rough);
}

void main()
{
    if (Pass == 0)
        pass0();
    else if (Pass == 1)
        pass1();
}
)"