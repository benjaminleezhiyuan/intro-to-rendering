/*!*****************************************************************************
\file unittests_functions.h
\author Vadim Surov (vsurov\@digipen.edu)
\co-author Benjamin Lee (benjaminzhiyuan.lee\@digipen.edu)
\par Course: CSD2151/CSD2150/CS250
\par Assignment: 5.1 (Environment Mapping)
\date 11/02/2024 (MM/DD/YYYY)
\brief This file has declarations of functions for unit tests.

This code is intended to be completed and submitted by a student,
so any changes in this file will be used in the evaluation on the VPL server.
You should not change functions' name and parameter types in provided code.
*******************************************************************************/
#ifndef FUNCTIONS_H
#define FUNCTIONS_H

#include "unittests_data.h"

/*
    Read specs for Assignment 5.1
*/
vec4 checkerboardTexture(vec2 uv, float size);

/*
    Read specs for Assignment 5.1
*/
vec2 vec2uv(vec3 v);

#endif