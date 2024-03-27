/*!
@file FiltersAssignment.frag.glsl
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 11
@date 27/03/2024
@brief Implementation of assignment vertex shader
*/

R"(
#version 420

struct Light 
{
    vec3 position;      // Position of the light source in the world space
    vec3 La;            // Ambient light intensity
    vec3 Ld;            // Diffuse light intensity
    vec3 Ls;            // Specular light intensity
};

struct Material 
{
    vec3 Ka;            // Ambient reflectivity
    vec3 Kd;            // Diffuse reflectivity
    vec3 Ks;            // Specular reflectivity
    float shininess;    // Specular shininess factor
};

uniform int Pass;   // Pass number

// For pass 0

in vec3 Position;
in vec3 Normal;

uniform Material material;

layout(location=1) out vec3 PositionData;
layout(location=2) out vec3 NormalData;

void pass0() 
{
    // Store position and normal in textures
    PositionData = Position;
    NormalData = normalize(Normal);
}


// For pass 1

in vec2 TexCoord;

layout(binding=0) uniform sampler2D PositionTex;
layout(binding=1) uniform sampler2D NormalTex;

uniform Light light[1];
uniform mat4 V;         // View transform matrix

layout(location=0) out vec4 FragColor;

/**
 * Calculate the Blinn-Phong shading model for a given point on a surface.
 *
 * This function computes the Blinn-Phong lighting model for a point on a surface
 * using the provided parameters, including the position, normal vector,
 * light source properties, material properties, and the view matrix.
 *
 * @param position The 3D position of the point on the surface.
 * @param normal The normalized surface normal vector at the point.
 * @param light The properties of the light source (position, color).
 * @param material The material properties (ambient, diffuse, specular, shininess).
 * @param view The view matrix to transform the light source position to view space.
 * @return The resulting color (vec3) at the given point using Blinn-Phong shading.
 */
vec3 BlinnPhong(vec3 position, vec3 normal, Light light, Material material, mat4 view) {
    if (dot(normal,normal) == 0.0f) {
        return vec3(0.0f);
    }

    // Transform light position to view space
    vec3 lightPositionInViewSpace = vec3(view * vec4(light.position, 1.0));

    // Normalized vectors
    vec3 normalSurface = normalize(normal);
    vec3 viewDirection = normalize(-position);
    vec3 lightDirection = normalize(lightPositionInViewSpace - position);
    vec3 halfVector = normalize(lightDirection + viewDirection);

    // Calculate diffuse and specular components
    float diffuse = max(dot(normal, lightDirection), 0.0f);
    float specular = 0.0f;
    if (diffuse > 0)
    {
        specular = pow(max(dot(normalSurface, halfVector), 0.0f), material.shininess);
    }

    // Calculate the final color using the Blinn-Phong model
    vec3 ambientColor = material.Ka * light.La;
    vec3 diffuseColor = material.Kd * light.Ld * diffuse;
    vec3 specularColor = material.Ks * light.Ls * specular;

    // Final color is the sum of ambient, diffuse, and specular components
    vec3 finalColor = ambientColor + diffuseColor + specularColor;

    return finalColor;
}

void pass1() 
{
    // Retrieve position and normal information from textures
    vec3 position = vec3(texture(PositionTex, TexCoord));
    vec3 normal = vec3(texture(NormalTex, TexCoord));

    FragColor = vec4(BlinnPhong(position, normal, light[0], material, V), 1.0f);
}

void main() 
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
}
)"