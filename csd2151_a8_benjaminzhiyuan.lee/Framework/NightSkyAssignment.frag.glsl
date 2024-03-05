/*!
@file NightSkyAssignment.frag.glsl
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 8
@date 04/03/2024
@brief Implementation of assignment vertex shader 
*/

R"(
#version 420

uniform int Pass; // Pass number

const vec3 FOG_COLOR = vec3(0.0f, 0.0f, 0.0f);
const float FOG_MAXDIST = 15.0f;
const float FOG_MINDIST = 5.0f;

const int CARTOON_LEVELS = 3;

const int CHECKERBOARD_SIZE = 50;
const float CHECKERBOARD_MIXLEVEL = 0.5f; // Mixing level with shade 
                                          // ex: color = mix(shade, checker, CHECKERBOARD_MIXLEVEL);

const int DISCARD_SCALE = 10;  // How many lines per polygon

struct Light 
{
    vec3 position;      // Position of the light source in the world space   
    vec3 L;             // Light intensity (for PBR)
    vec3 La;            // Ambient light intensity
    vec3 Ld;            // Diffuse light intensity
    vec3 Ls;            // Specular light intensity
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

struct Fog 
{
  float minDist;            
  float maxDist;            
  vec3 color;            
};

in vec3 Vec;
in vec3 Position;
in vec3 ViewPosition;
in vec3 Normal;
in vec3 TexCoord;

in vec3 ReflectDir;
in vec3 RefractDir;

vec3 color;

uniform mat4 V;         // View transform matrix

layout(location=0) out vec4 FragColor;

const float PI = 3.14159265358979323846;

uniform Material material;
uniform Light light[1];

//
// The Microgeometry Normal Distribution Function, based on GGX/Trowbrodge-Reitz, 
// that describes the relative concentration of microfacet normals 
// in the direction H. It has an effect on the size and shape 
// of the specular highlight.
//
// Parameter is cosine of the angle between the normal and H which is the halfway vector of 
// both the light direction and the view direction
//
float ggxDistribution(float nDotH) 
{
    float alpha2 = material.rough * material.rough * material.rough * material.rough;
    float d = (nDotH * nDotH) * (alpha2 - 1.0f) + 1.0f;
    return alpha2 / (PI * d * d);
}

//
// The Smith Masking-Shadowing Function describes the probability that microfacets with 
// a given normal are visible from both the light direction and the view direction.
//
// Parameter is cosine of the angle between the normal vector and the view direction.
//
float geomSmith(float nDotL) 
{
    float k = (material.rough + 1.0f) * (material.rough + 1.0f) / 8.0f;
    float denom = nDotL * (1.0f - k) + k;
    return 1.0f / denom;
}

//
// Schlick approximation for Fresnel reflection that defines the probability of light
// reflected from an optically flat surface.
//
// Parameter is cosine of the angle between the light direction vector and 
// the halfway vector of both the light direction and the view direction
//
vec3 schlickFresnel(float lDotH) 
{
    vec3 f0 = vec3(0.04f); // Dielectrics
    if (material.metal == 1.0f)
        f0 = material.color;
    return f0 + (1.0f - f0) * pow(1.0f - lDotH, 5);
}

//
// Bidirectional Reflectance Distribution Function.
// This is the common way to model reflectance based on microfacet theory. 
// This theory was developed to describe reflection from general, non-optically flat surfaces. 
// It models the surface as consisting of small facets that are optically flat (mirrors) and 
// are oriented in various directions. Only those that are oriented correctly to reflect toward 
// the viewer can contribute.
//
// Parameters are the position of a fragment and the surface normal in the view space.
//
vec3 microfacetModel(vec3 position, vec3 n, Light light, Material material) 
{  
    vec3 diffuseBrdf = material.color;

    vec3 lightI = light.L;
    vec3 lightPositionInView = (V * vec4(light.position, 1.0f)).xyz;

    vec3 l = lightPositionInView - position;
    float dist = length(l);
    l = normalize(l);
    lightI *= 100 / (dist * dist); // Intensity is normalized, so scale up by 100 first

    vec3 v = normalize(-position);
    vec3 h = normalize(v + l);
    float nDotH = dot(n, h);
    float lDotH = dot(l, h);
    float nDotL = max(dot(n, l), 0.0f);
    float nDotV = dot(n, v);
    vec3 specBrdf = 0.25f * ggxDistribution(nDotH) * schlickFresnel(lDotH) 
                            * geomSmith(nDotL) * geomSmith(nDotV);

    return (diffuseBrdf + PI * specBrdf) * lightI * nDotL;
}

vec3 microfacetModelCartoon(vec3 position, vec3 n, Light light, Material material) 
{  
    vec3 diffuseBrdf = material.color;

    vec3 lightI = light.L;
    vec3 lightPositionInView = (V * vec4(light.position, 1.0f)).xyz;

    vec3 l = lightPositionInView - position;
    float dist = length(l);
    l = normalize(l);
    lightI *= 100 / (dist * dist); // Intensity is normalized, so scale up by 100 first

    vec3 v = normalize(-position);
    vec3 h = normalize(v + l);
    float nDotH = dot(n, h);
    float lDotH = dot(l, h);
    float nDotL = max(dot(n, l), 0.0f);
    float nDotV = dot(n, v);
    vec3 specBrdf = 0.f * schlickFresnel(lDotH);

    return (diffuseBrdf + PI * specBrdf) * nDotL;
}


float cartoon(float value)
{
    const int levels = CARTOON_LEVELS;
    const float scaleFactor = 1.0f / levels;
    return floor(value * levels) * scaleFactor;
}

vec3 pbrCartoon(vec3 position, vec3 n, Light light, Material material) 
{  

    // Call the microfacetModel function to calculate the lighting without the cartoon effect
    vec3 pbrColor = microfacetModelCartoon(position, n, light, material);

    // Apply cartoon effect to the result
    float cartoonR = cartoon(pbrColor.r);
    float cartoonG = cartoon(pbrColor.g);
    float cartoonB = cartoon(pbrColor.b);

    // Return the cartoonized color
    return vec3(cartoonR, cartoonG, cartoonB);
}

layout(binding=0) uniform samplerCube CubeMapTex;
// Pass 0
void pass0() 
{
   color = texture(CubeMapTex, Vec).rgb;
   color = pow(color, vec3(1.0f/2.2f)); // Gamma correction
   FragColor = vec4(color, 1.0f);
}

// Pass 1
void pass1() 
{
   color = vec3(0.0);
   float dist = length(ViewPosition);
   float fogFactor = clamp((dist - FOG_MINDIST) / (FOG_MAXDIST - FOG_MINDIST), 0.0f, 1.0f);

    switch (int(material.effect)) {
        case 0: // No effect
            color = microfacetModel(ViewPosition, normalize(Normal), light[0], material);
            break;

        case 1: // Discard
            vec2 scaledTexCoord = TexCoord.xy * float(DISCARD_SCALE);
            ivec2 checkIndex = ivec2(floor(scaledTexCoord));
            bool discardFragment = mod(checkIndex.x + checkIndex.y, 2) == 0;
            
            if (discardFragment) discard;
            color = microfacetModel(ViewPosition, normalize(Normal), light[0], material);
            break;

        case 2: // Cartoon
            color = pbrCartoon(ViewPosition, normalize(Normal), light[0], material);
            break;

        case 3: // Checkerboard texture
            vec3 normal = normalize(Normal);
            vec3 lightDir = normalize(light[0].position - ViewPosition);
            vec3 diffuse = microfacetModel(ViewPosition, normal, light[0], material);
            
            // Calculate checkerboard pattern
            float checkerWidth = 1.0 / float(CHECKERBOARD_SIZE);
            vec2 checkerCoord = vec2(floor(TexCoord.x / checkerWidth), floor(TexCoord.y / checkerWidth));
            float checker = mod(float(int(checkerCoord.x) + int(checkerCoord.y)), 2.0);
            vec3 checkerColor = checker > 0.5 ? vec3(1.0) : vec3(0.0);
            
            // Apply checkerboard pattern to diffuse lighting
            color = mix(diffuse, checkerColor, CHECKERBOARD_MIXLEVEL);

            break;

        default:
            break;
    }

    color = pow(color, vec3(1.0f/2.2f)); // Gamma correction
    FragColor = vec4(mix(color, FOG_COLOR, fogFactor), 1.0f);
}


void main()
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
}
)"