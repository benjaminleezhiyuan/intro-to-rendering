/*!
@file main.cpp
@author Vadim Surov (vsurov@digipen.edu)
@co-author Benjamin Lee Zhi Yuan (benjaminzhiyuan.lee@digipen.edu)
@course CSD2151
@section A
@assignent 5
@date 11/2/2024
@brief Implementation of assignment 5
*/
#include <iostream>

#include "common/debug.h"
#include "common/cg.h"

#include <GLFW/glfw3.h>

cg::Scene* pScene = nullptr;
glm::vec2 screen{ WIDTH, HEIGHT };
bool lbutton_down = false;
bool mode_alt = false;
float reflectFactor = 0.9f, refractFactor = 0.9f;

struct Material
{
    glm::vec4 color;
    float reflectionFactor; // The light reflection factor
    float eta;              // The ratio of indices of refraction
};

/*
   This function serves as the callback parameter for 
      glfwSetKeyCallback function used in the main function

   Esc - close the app
*/
void keyCallback(GLFWwindow* pWindow, int key, int scancode, int action, int mods)
{
    if (action == GLFW_PRESS)
    {
        if (key == GLFW_KEY_ESCAPE)
            glfwSetWindowShouldClose(pWindow, GL_TRUE);

        if (mode_alt)
        {
            // Set refractFactor between 0.5 and 2.5
            if (key >= GLFW_KEY_0 && key <= GLFW_KEY_9)
            {
                // Calculate refractFactor based on the pressed key
                float factor = static_cast<float>(key - GLFW_KEY_0) * 0.25f + 0.5f; // Scaling and shifting to map to range [0.5, 2.5]
                refractFactor = std::min(std::max(factor, 0.5f), 2.5f); // Ensure refractFactor is within range [0.5, 2.5]
            }
        }

        else if (key >= GLFW_KEY_0 && key <= GLFW_KEY_9)
        {
            // Calculate reflectFactor based on the pressed key
            float factor = static_cast<float>(key - GLFW_KEY_0) * 0.1111f + 0.1f; // Scaling and shifting to map to range [0.1, 1.0]
            reflectFactor = std::min(std::max(factor, 0.1f), 1.0f); // Ensure reflectFactor is within range [0.1, 1.0]
        }
        
    }

    // Check if Alt key is held down
    mode_alt = (mods == GLFW_MOD_ALT);

}

/*
   This function serves as the callback parameter for
      glfwSetMouseButtonCallback function used in the main function
*/
void mouseButtonCallback(GLFWwindow* pWindow, int button, int action, int mods)
{
    if (button == GLFW_MOUSE_BUTTON_LEFT)
    {
        if (GLFW_PRESS == action)
            lbutton_down = true;
        else if (GLFW_RELEASE == action)
            lbutton_down = false;
    }
}

/*
   This function serves as the callback parameter for
      glfwSetCursorPosCallback function used in the main function
*/
void cursorPosCallback(GLFWwindow* pWindow, double xpos, double ypos)
{
    if (!lbutton_down)
        return;
    else
    {
        static double oldxpos = xpos;
        static double oldypos = ypos;

        pScene->camerasOnCursor(xpos - oldxpos, ypos - oldypos, &pScene->shader);

        oldxpos = xpos;
        oldypos = ypos;
    }
}
    

/*
   This function serves as the callback parameter for
      glfwSetScrollCallback function used in the main function
*/
void scrollCallback(GLFWwindow* pWindow, double xoffset, double yoffset)
{
    pScene->camerasOnScroll(xoffset, yoffset, &pScene->shader);
}

/*
   This function serves as the callback parameter for
      glfwSetWindowSizeCallback function used in the main function
*/
void sizeCallback(GLFWwindow* pWindow, int width, int height)
{
    screen = { width, height };
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
                #include "EnvironmentMap.vert.glsl"
            },

            // Fragment shader
            {
                #include "EnvironmentMap.frag.glsl"
            },

            // Passes
            {
                // Pass 0 (to render background)
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
                        {
                           SKYBOX
                        }
                    },

            // The camera
            {
                { { 3.0f, 0.0f, 0.0f } }
            },

            // Lights
            {

            },

            // Textures
            {
                
            },

            // Setup uniforms in the shader
            NULL
        },

            // Pass 1 (to render the object)
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
                    {
                        SPHERE,
                        MATERIAL_REFLECT_REFRACT
                    },
                    {
                        CUBE,
                        MATERIAL_REFLECT_REFRACT,
                        glm::translate(glm::mat4(1.0f), {0.0f, 0.0f, 4.0f})
                    },
                    {
                        TORUS,
                        MATERIAL_REFLECT_REFRACT,
                        glm::translate(glm::mat4(1.0f), {0.0f, 0.0f, -4.0f})
                    }
                },

            // The camera
            {
                { { 3.0f, 0.0f, 0.0f } }
            },

            // Lights
            {

            },

            // Textures
            {
              
            },

            // Setup uniforms in the shader
            [](cg::Program& shader)
            {
                shader.setUniform("factor", reflectFactor);
                shader.setUniform("refraction", refractFactor);
            }
        }
    }
        };

        pScene = &scene;

        while (!glfwWindowShouldClose(pWindow))
        {
            checkForOpenGLError(__FILE__, __LINE__);
            scene.resize((int)screen.x, (int)screen.y);
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