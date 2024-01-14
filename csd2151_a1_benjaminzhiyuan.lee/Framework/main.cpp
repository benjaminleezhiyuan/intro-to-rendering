/*!
@file main.cpp
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 1
@date 1/7/2024
@brief Implementation of assignment 1 
*/
#include <iostream>

#include "common/debug.h"
#include "common/cg.h"

#include <GLFW/glfw3.h>

cg::Scene* pScene = nullptr;

/*
   This function serves as the callback parameter for 
      glfwSetKeyCallback function used in the main function

   Esc - close the app
*/
void keyCallback(GLFWwindow* pWindow, int key, int scancode, int action, int mods)
{
    if (action == GLFW_PRESS)
        if (key == GLFW_KEY_ESCAPE)
            glfwSetWindowShouldClose(pWindow, GL_TRUE);
}

/*
   This function serves as the callback parameter for
      glfwSetMouseButtonCallback function used in the main function
*/
void mouseButtonCallback(GLFWwindow* pWindow, int button, int action, int mods)
{

}

#define ALPHA 0.f
float r = 0.f, g = 0.f, b = 0.f;

/*
   This function serves as the callback parameter for
      glfwSetCursorPosCallback function used in the main function
*/
void cursorPosCallback(GLFWwindow* pWindow, double xpos, double ypos)
{
    int width, height;
    glfwGetWindowSize(pWindow, &width, &height);
    r = (float)(xpos / (double)width);
    g = (float)(ypos / (double)height);
}

#define SCROLL_RATE 0.1
/*
   This function serves as the callback parameter for
      glfwSetScrollCallback function used in the main function
*/
void scrollCallback(GLFWwindow* pWindow, double xoffset, double yoffset)
{
    b += (float)(SCROLL_RATE * yoffset);
    b = std::max(0.f, std::min(1.f, b));
}

/*
   This function serves as the callback parameter for
      glfwSetWindowSizeCallback function used in the main function
*/
void sizeCallback(GLFWwindow* pWindow, int width, int height)
{

}

/*
    The main function
*/
int main(int argc, char** argv)
{
    if (!glfwInit())
        exit(EXIT_FAILURE);

#if defined( _DEBUG )
    glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, GL_TRUE);
#endif
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 6);
    glfwWindowHint(GLFW_RESIZABLE, GL_TRUE);

    GLFWwindow* pWindow = glfwCreateWindow(WIDTH, HEIGHT, "Framework", NULL, NULL);
    if (!pWindow)
    {
        std::cerr << "Unable to create OpenGL context." << std::endl;
        glfwTerminate();
        exit(EXIT_FAILURE);
    }
    glfwMakeContextCurrent(pWindow);

    // Load the OpenGL functions.
    glewExperimental = GL_TRUE; // Needed for core profile
    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
        std::cerr << "Error: " << glewGetErrorString(err) << std::endl;

        // Close pWindow and terminate GLFW
        glfwTerminate();

        // Exit program
        std::exit(EXIT_FAILURE);
    }

#if defined( _DEBUG )
    dumpGLInfo();
#endif

    std::cout << std::endl;
    std::cout << "A computer graphics framework." << std::endl;
    std::cout << std::endl;

#if defined( _DEBUG )
    glDebugMessageCallback(debugCallback, nullptr);
    glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, NULL, GL_TRUE);
    glDebugMessageInsert(GL_DEBUG_SOURCE_APPLICATION, GL_DEBUG_TYPE_MARKER, 0,
        GL_DEBUG_SEVERITY_NOTIFICATION, -1, "Start debugging");
#endif

    glfwSetKeyCallback(pWindow, keyCallback);
    glfwSetMouseButtonCallback(pWindow, mouseButtonCallback);
    glfwSetCursorPosCallback(pWindow, cursorPosCallback);
    glfwSetScrollCallback(pWindow, scrollCallback);
    glfwSetWindowSizeCallback(pWindow, sizeCallback);

    try
    {
        cg::Scene scene =
        {
            // Vertex shader
            {
                #include "Framework.vert.glsl"
            },

            // Fragment shader
            {
                #include "Framework.frag.glsl"
            },

            // Passes
            {
                // Pass 0
                {
                    // Rendering target
                    DEFAULT,

                    // Viewport
                    { 0, 0, WIDTH, HEIGHT },

                    // Color to clear buffers
                    { },

                    // Depth test
                    ENABLE,

                    // Objects
                    {

                    },

                    // The camera
                    {
                        DEFAULT
                    },

                    // Lights
                    {
                        DEFAULT
                    },

                    // Textures
                    {

                    },

                    // Setup uniforms in the shader
                    [](cg::Program& shader)
                    {

                    }
                }
            }
        };

        pScene = &scene;

        while (!glfwWindowShouldClose(pWindow))
        {
            checkForOpenGLError(__FILE__, __LINE__);

            // Update clear color before render.
            pScene->passes[0].clearColor = { r, g, b, ALPHA };
            scene.render();

            glfwSwapBuffers(pWindow);
            glfwPollEvents();
        }

    }
    catch (std::exception const& e)
    {
        std::cerr << "Error: " << e.what() << std::endl;

        // Close pWindow and terminate GLFW
        glfwTerminate();

        // Exit program
        std::exit(EXIT_FAILURE);
    }

#if defined( _DEBUG )
    glDebugMessageInsert(GL_DEBUG_SOURCE_APPLICATION, GL_DEBUG_TYPE_MARKER, 1,
        GL_DEBUG_SEVERITY_NOTIFICATION, -1, "End debug");
#endif

    // Close pWindow and terminate GLFW
    glfwTerminate();

    // Exit program
    return EXIT_SUCCESS;
}