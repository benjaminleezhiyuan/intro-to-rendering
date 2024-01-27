/*!
@file 
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 3.2
@date 27/1/2024
@brief Implementation of assignment 3.2
*/

R"(
#version 330 core

/*
   2D Pass-Through Vertex Shader 
*/

layout(location=0) in vec3 VertexPosition;
layout(location=1) in vec3 VertexNormal;
layout(location=2) in vec3 VertexTexCoord;

out vec3 TexCoord;

void main() 
{
    TexCoord = VertexTexCoord;
    gl_Position = vec4(VertexPosition.x, VertexPosition.y, 0.0f, 1.0f);
}
)"