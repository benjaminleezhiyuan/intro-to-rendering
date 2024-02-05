/*!
@file Spotlight.frag.glsl
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 4
@date 03/02/2024
@brief Implementation of assignment fragment shader
*/

R"(
#version 330 core

struct Material 
{
    vec3 Ka;            // Ambient reflectivity
    vec3 Kd;            // Diffuse reflectivity
    vec3 Ks;            // Specular reflectivity
    float shininess;    // Specular shininess factor
};

struct Light 
{
    vec3 position;      // Position of the light source in the world space
    vec3 La;            // Ambient light intensity
    vec3 Ld;            // Diffuse light intensity
    vec3 Ls;            // Specular light intensity
};

in vec3 Position;       // In view space
in vec3 Normal;         // In view space

uniform Light light[1];
uniform Material material;
uniform mat4 V;         // View transform matrix
uniform int mode;   // lighting mode

layout(location=0) out vec4 FragColor;


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

vec3 Phong(vec3 position, vec3 normal, Light light, Material material, mat4 view) {
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
    vec3 reflectionVector = reflect(-lightDirection, normalSurface);

    // Calculate diffuse and specular components
    float diffuse = max(dot(normal, lightDirection), 0.0f);
    float specular = 0.0f;
    if (diffuse > 0)
    {
        specular = pow(max(dot(reflectionVector, viewDirection), 0.0f), material.shininess);
    }

    // Calculate the final color using the Blinn-Phong model
    vec3 ambientColor = material.Ka * light.La;
    vec3 diffuseColor = material.Kd * light.Ld * diffuse;
    vec3 specularColor = material.Ks * light.Ls * specular;

    // Final color is the sum of ambient, diffuse, and specular components
    vec3 finalColor = ambientColor + diffuseColor + specularColor;

    return finalColor;
}




void main() 
{
    if(mode==2)
    {
        FragColor = vec4(Phong(Position, normalize(Normal), light[0], material, V), 1.0f);
    }
    else
    {
        FragColor = vec4(BlinnPhong(Position, normalize(Normal), light[0], material, V), 1.0f);
    }
}
)"