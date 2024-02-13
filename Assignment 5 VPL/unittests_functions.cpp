/*!*****************************************************************************
\file unittests_functions.cpp
\author Vadim Surov (vsurov\@digipen.edu)
\co-author Benjamin Lee (benjaminzhiyuan.lee\@digipen.edu)
\par Course: CSD2151/CSD2150/CS250
\par Assignment: 5.1 (Environment Mapping)
\date 11/02/2024 (MM/DD/YYYY)
\brief This file has definitions of functions for unit tests.

This code is intended to be completed and submitted by a student,
so any changes in this file will be used in the evaluation on the VPL server.
You should not change functions' name and parameter types in provided code.
*******************************************************************************/

#include "unittests_functions.h"


template<typename T>
T floor(T a) { return glm::floor(a); }

template<typename T>
T mod(T a, T b) { return glm::mod(a, b); }

#define UNUSED(x) (void)x;

/*
    Read specs for Assignment 5.1
*/
vec4 checkerboardTexture(vec2 uv, float size)
{
    // Calculate the position within the checkerboard texture
    vec2 uvScaled = uv * size;

    // Determine which square the UV coordinates are in
    int x = int(floor(uvScaled.x)) % 2;
    int y = int(floor(uvScaled.y)) % 2;

    // If both x and y are either both even or both odd, it's black; otherwise, it's white
    if ((x == 0 && y == 0) || (x == 1 && y == 1))
    {
        return vec4(0.0f, 0.0f, 0.0f, 1.0f); // Black
    }
    else
    {
        return vec4(1.0f, 1.0f, 1.0f, 1.0f); // White
    }
}


/*
    Read specs for Assignment 5.1
*/
vec2 vec2uv(vec3 v) {
    // Take the absolute value of v
    vec3 absolute_v = abs(v);
    vec2 uv;

    // Determine which face of the cube v lies on
    if (v.x >= absolute_v.y && v.x >= absolute_v.z) {
        // Right face
        uv = vec2(-v.z, -v.y) / v.x / 2.0f + 0.5f;
        uv.x = uv.x - 1.f;
        uv.y = 1.0f - uv.y;
    }
    else if (absolute_v.x > absolute_v.y && absolute_v.x > absolute_v.z) {
        // Left face
        uv = vec2(v.z, -v.y) / absolute_v.x / 2.0f + 0.5f;
        uv.x = 1.0f - uv.x;
        uv.y = 1.0f - uv.y;
    }
    else if (absolute_v.y > absolute_v.z) {
        // Top / Bottom face, which we're not handling, returning (0, 0)
        return vec2(0.0f, 0.0f);
    }
    else {
        // Front / Back face
        uv = vec2(v.x, -v.y) / absolute_v.z / 2.0f + 0.5f;
        if (v.z > 0) uv.x = 1.0f - uv.x;
        uv.y = 1.0f - uv.y;
    }

    // Clamp uv within the range of [0, 1]
    uv = clamp(uv, 0.0f, 1.0f);
    return uv;
}


