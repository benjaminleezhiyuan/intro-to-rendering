/*!*****************************************************************************
\file unittests_functions.cpp
\author Vadim Surov (vsurov\@digipen.edu)
\co-author Benjamin Lee (benjaminzhiyuan.lee\@digipen.edu)
\par Course: CSD2151/CSD2150/CS250
\par Assignment: 4.1 (BlinnPhong)
\date 03/02/2024
\brief This file has definitions of functions for unit tests.

This code is intended to be completed and submitted by a student,
so any changes in this file will be used in the evaluation on the VPL server.
You should not change functions' name and parameter types in provided code.
*******************************************************************************/

#include "unittests_functions.h"
#include <iostream>

#include <glm/gtx/extended_min_max.hpp>

const float EPSILON = 0.001f;


template<typename T>
T min(T a, T b) { return glm::min(a, b); }

template<typename T>
T max(T a, T b) { return glm::max(a, b); }

template<typename T>
T abs(T a) { return glm::abs(a); }

template<typename T>
float length(T a) { return glm::length(a); }

template<typename T>
float dot(T a, T b) { return glm::dot(a, b); }

template<typename T>
T pow(T a, T b) { return glm::pow(a, b); }

#define UNUSED(x) (void)x;

/*
    Function implements the Blinn-Phong shading method of shading
    Parameters:
        position - coordinates of a fragment in the view space,
        normal - the normal vector of the fragment,
        light - the light info,
        material - the material info,
        view - the view transform matrix to transfom the light position to view space.
    Returns:
        - color components of the fragment based on the fragment position and normal vector,
          the light position and properties, and the material properties  
        - vec3(0.0f) if the light position in the view space and position are the same points.
    Assume:
        - the camera and the fragment positions are never the same points.
*/
vec3 BlinnPhong(vec3 position, vec3 normal, Light light, Material material, mat4 view)
{
    if (dot(normal, normal) == 0.0f) {
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

