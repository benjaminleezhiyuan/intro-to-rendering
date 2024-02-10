/*!*****************************************************************************
\file unittests_functions.cpp
\author Vadim Surov (vsurov\@digipen.edu)
\co-author YOUR NAME (DIGIPEN ID)
\par Course: CSD2151/CSD2150/CS250
\par Assignment: 5.1 (Environment Mapping)
\date 02/06/2022 (MM/DD/YYYY)
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
    UNUSED(uv)
    UNUSED(size)


    return vec4(0.0f);
}

/*
    Read specs for Assignment 5.1
*/
vec2 vec2uv(vec3 v)
{
    UNUSED(v)


    return vec2(0.0f);
}