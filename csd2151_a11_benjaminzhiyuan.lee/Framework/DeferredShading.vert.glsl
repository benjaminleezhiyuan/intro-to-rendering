/*!
@file FiltersAssignment.vert.glsl
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 11
@date 27/03/2024
@brief Implementation of assignment vertex shader
*/

R"(
#version 330 core

/*
   This vertex shader for deferred shading.
*/

struct Light 
{
    vec3 position;      // Position of the light source in the world space
    vec3 La;            // Ambient light intensity
    vec3 Ld;            // Diffuse light intensity
    vec3 Ls;            // Specular light intensity
};

uniform int Pass; // Pass number

layout(location=0) in vec3 VertexPosition;
layout(location=1) in vec3 VertexNormal;
layout(location=2) in vec2 VertexTexCoord;
layout(location=3) in vec4 VertexTangent;

uniform Light light[1];
uniform mat4 M; // Model transform matrix
uniform mat4 V; // View transform matrix
uniform mat4 P; // Projection transform matrix


// Pass 0

out vec3 Position;
out vec3 Normal;

void pass0()
{
    // Get the position and normal in view space
    mat4 MV = V * M;
    mat3 N = mat3(vec3(MV[0]), vec3(MV[1]), vec3(MV[2])); // Normal transform matrix

    vec3 VertexNormalInView = normalize(N * VertexNormal);
    vec4 VertexPositionInView = MV * vec4(VertexPosition, 1.0f);
    
    Position = VertexPositionInView.xyz;
    Normal = VertexNormalInView;

    gl_Position = P * VertexPositionInView;
}


// Pass 1
out vec3 LightDir;
out vec3 ViewDir;
out vec2 TexCoord;

void pass1()
{
    TexCoord = VertexTexCoord; 
    gl_Position = P * V * M * vec4(VertexPosition, 1.0f);
}

void main()
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
}
)"