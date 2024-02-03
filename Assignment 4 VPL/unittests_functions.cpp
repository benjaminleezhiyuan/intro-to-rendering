/*!*****************************************************************************
\file unittests_functions.cpp
\author Vadim Surov (vsurov\@digipen.edu)
\co-author YOUR NAME (SIT/DIGIPEN ID/EMAIL)
\par Course: CSD2151/CSD2150/CS250
\par Assignment: 4.1 (BlinnPhong)
\date 27/11/2023
\brief This file has definitions of functions for unit tests.

This code is intended to be completed and submitted by a student,
so any changes in this file will be used in the evaluation on the VPL server.
You should not change functions' name and parameter types in provided code.
*******************************************************************************/

#include "unittests_functions.h"

#include <glm/gtx/extended_min_max.hpp>

template<typename T>
T min(T a, T b) { return glm::min(a, b); };

template<typename T>
T max(T a, T b) { return glm::max(a, b); };

template<typename T>
T abs(T a) { return glm::abs(a); };

template<typename T>
float length(T a) { return glm::length(a); };

template<typename T>
float dot(T a, T b) { return glm::dot(a, b); };

template<typename T>
T pow(T a, T b) { return glm::pow(a, b); };

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
    UNUSED(position)
    UNUSED(normal)
    UNUSED(light)
    UNUSED(material)
    UNUSED(view)
    
    
    return vec3(0.0f);
}