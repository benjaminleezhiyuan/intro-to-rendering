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

uniform int Pass;       // Pass number

// Pass 0

in vec3 Position;
in vec3 Normal;
in vec3 LightDir;
in vec3 ViewDir;

in vec2 TexCoord;

uniform Light light[1];
uniform Material material;

uniform mat4 V;         // View transform matrix

layout(location=0) out vec4 FragColor;

//layout(location=1) out vec3 PositionData;
layout(location=1) out vec3 LightData;
layout(location=2) out vec3 ViewData;
layout(location=3) out vec2 TexData;

layout(binding=3) uniform sampler2D ColorTex;
layout(binding=4) uniform sampler2D NormalMapTex;

void pass0()
{
    // Store position and normal in textures
    LightData = normalize(LightDir);
    ViewData = normalize(ViewDir);
    TexData = TexCoord;
}

// For pass 1
layout(binding=0) uniform sampler2D LightTex;
layout(binding=1) uniform sampler2D ViewTex;
layout(binding=2) uniform sampler2D P0Tex;

vec3 blinnPhong(vec3 normal, vec3 color, vec3 lightDir, vec3 viewDir)
{
    vec3 finalcolor = vec3(0.21191f);
    if (any(notEqual(lightDir, vec3(0.0f, 0.0f, 0.0f)) || notEqual(viewDir, vec3(0.0f, 0.0f, 0.0f))))
    {
        vec3 ambient = material.Ka * light[0].La * color;

        vec3 diffuse = material.Kd * light[0].Ld * color * max(dot(lightDir, normal), 0.0f);
        if (max(dot(lightDir, normal), 0.0f) == 0.0f) diffuse = vec3(0.0f);

        // Calculate the view direction (from the fragment position to the camera)
       
        float viewDistance = length(viewDir);
        viewDir = (viewDistance > 0.0f) ? viewDir / viewDistance : vec3(0.0f);

        vec3 halfwayVec = normalize(lightDir + viewDir);

        vec3 specular = material.Ks * light[0].Ls * pow(max(0.0f,dot(halfwayVec, normal)), material.shininess);

        if(diffuse == 0.0f) specular = vec3(0.0f);

        finalcolor = ambient + diffuse + specular;
    }

    return finalcolor;
}

void pass1() 
{
    // Retrieve position and normal information from textures
    //vec3 position = vec3(texture(PositionTex, TexCoord));
    vec2 p1tex = vec2(texture(P0Tex, TexCoord));
    vec3 normal = vec3(texture(NormalMapTex, p1tex));
    normal.xy = 2.0f * normal.xy - 1.0f;

    // Calculate the illumination
    vec3 color = blinnPhong(normal, 
                            vec3(texture(ColorTex, p1tex)), 
                            vec3(texture(LightTex, TexCoord)), 
                            vec3(texture(ViewTex, TexCoord)) );

    // Set with the gamma correction
    FragColor = vec4(pow(color, vec3(1.0f/2.2f)), 1.0f);
}


void main()
{
    if      (Pass==0) pass0();
    else if (Pass==1) pass1();
}

)"