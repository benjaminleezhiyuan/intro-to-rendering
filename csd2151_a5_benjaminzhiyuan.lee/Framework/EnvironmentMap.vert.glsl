/*!
@file 
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 5
@date 11/2/2024
@brief Implementation of assignment vertex shader 
*/

R"(
#version 330 core

struct Camera 
{
    vec3 position;    // In world space
};

struct Material 
{
    vec4 color;             
    float reflectionFactor; // The light reflection factor
    float eta;              // The ratio of indices of refraction
};

uniform int Pass; // Pass number

layout(location=0) in vec3 VertexPosition;

uniform mat4 M; // Model transform matrix
uniform mat4 V; // View transform matrix
uniform mat4 P; // Projection transform matrix


// Pass 0

out vec3 Vec;

void pass0()
{
    Vec = VertexPosition; 
    gl_Position = P * V * M * vec4(VertexPosition, 1.0f);
}

// Pass 1

layout(location=1) in vec3 VertexNormal;

uniform Camera camera;
uniform Material material;
uniform float factor;
uniform float refraction;

out vec3 ReflectDir;
out vec3 RefractDir;

void pass1()
{
    vec3 viewDirection = normalize(camera.position - VertexPosition);
    vec3 normal = normalize(VertexNormal);
    
    // Calculate the reflection direction
    ReflectDir = reflect(viewDirection, normal);

    // Blend between the reflection direction and view direction based on reflectionFactor
    vec3 blendedDirection = mix(viewDirection, ReflectDir, factor);

    // Set the blended direction as the final reflection direction
    ReflectDir = normalize(blendedDirection);

    // Calculate the refraction direction using Schlick's approximation
    float cosTheta = dot(-viewDirection, normal);
    float eta = refraction; // Refractive index of the material
    float F0 = pow((1.0 - eta) / (1.0 + eta), 2.0);
    float F = F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0); // Fresnel factor

    vec3 refractDirection = refract(viewDirection, normal, eta);

    // Use Schlick's approximation to blend between reflection and refraction
    vec3 finalDirection = mix(refractDirection, ReflectDir, F);

    // Set the final refraction direction
    RefractDir = normalize(finalDirection);
  
    gl_Position = P * V * M * vec4(VertexPosition, 1.0f);
}



void main()
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
}
)"