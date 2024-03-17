/*!
@file FiltersAssignment.frag.glsl
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 9
@date 16/03/2024
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

uniform int Pass;       // Pass number

layout(location=0) out vec4 FragColor;

float Weight[5] = { 0.158435f, 0.148836f, 0.123389f, 0.0902733f, 0.0582848f };

// Pass 0

in vec3 Position;
in vec3 Normal;

uniform Light light[1];
uniform Material material;
uniform mat4 V;         // View transform matrix

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
void pass0()
{
    FragColor = vec4(BlinnPhong(Position, normalize(Normal), light[0], material, V), 1.0f);
}


// Pass 1

// Texture from the first pass
layout(binding=0) uniform sampler2D Texture;

// Parameters
uniform float EdgeThreshold;

float luminance(vec3 color) 
{
    return dot(vec3(0.2126f, 0.7152f, 0.0722f), color);
}

void pass1() //first blur
{
    ivec2 pix = ivec2(gl_FragCoord.xy);
    vec4 sum = texelFetch(Texture, pix, 0);

    sum *= Weight[0];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0,-4)) * Weight[4];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0,-3)) * Weight[3];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0,-2)) * Weight[2];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0,-1)) * Weight[1];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0, 1)) * Weight[1];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0, 2)) * Weight[2];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0, 3)) * Weight[3];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(0, 4)) * Weight[4];

    FragColor = sum;
}

void pass2() //second blur
{
    ivec2 pix = ivec2(gl_FragCoord.xy);
    vec4 sum = texelFetch(Texture, pix, 0);
        
    sum *= Weight[0];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(-4,0)) * Weight[4];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(-3,0)) * Weight[3];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(-2,0)) * Weight[2];
    sum += texelFetchOffset(Texture, pix, 0, ivec2(-1,0)) * Weight[1];
    sum += texelFetchOffset(Texture, pix, 0, ivec2( 1,0)) * Weight[1];
    sum += texelFetchOffset(Texture, pix, 0, ivec2( 2,0)) * Weight[2];
    sum += texelFetchOffset(Texture, pix, 0, ivec2( 3,0)) * Weight[3];
    sum += texelFetchOffset(Texture, pix, 0, ivec2( 4,0)) * Weight[4];

    FragColor = sum;
}

void pass3() //edge detect
{
    
    ivec2 pix = ivec2(gl_FragCoord.xy);

    // Apply edge detection on the blurred image
    float s00 = luminance(texelFetchOffset(Texture, pix, 0, ivec2(-1, 1)).rgb);
    float s10 = luminance(texelFetchOffset(Texture, pix + ivec2(-1, 0), 0, ivec2(0)).rgb);
    float s20 = luminance(texelFetchOffset(Texture, pix + ivec2(-1,-1), 0, ivec2(0)).rgb);
    float s01 = luminance(texelFetchOffset(Texture, pix + ivec2( 0, 1), 0, ivec2(0)).rgb);
    float s21 = luminance(texelFetchOffset(Texture, pix + ivec2( 0,-1), 0, ivec2(0)).rgb);
    float s02 = luminance(texelFetchOffset(Texture, pix + ivec2( 1, 1), 0, ivec2(0)).rgb);
    float s12 = luminance(texelFetchOffset(Texture, pix + ivec2( 1, 0), 0, ivec2(0)).rgb);
    float s22 = luminance(texelFetchOffset(Texture, pix + ivec2( 1,-1), 0, ivec2(0)).rgb);

    float sx = s00 + 2*s10 + s20 - (s02 + 2*s12 + s22);
    float sy = s00 + 2*s01 + s02 - (s20 + 2*s21 + s22);

    float g = sx*sx + sy*sy;

    FragColor = (g > EdgeThreshold) ? vec4(1.0f) : vec4(0.0f, 0.0f, 0.0f, 1.0f);
}

void main()
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
    else if (Pass==2) pass2();
    else if (Pass==3) pass3();
}
)"