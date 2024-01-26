/*!*****************************************************************************
\file unittests_functions.cpp
\author Vadim Surov (vsurov\@digipen.edu)
\co-author Benjamin Lee (benjaminzhiyuan.lee\@digipen.edu)
\par Course: CSD2151
\par Assignment: 3.1 (RayTracing)
\date 26/01/2024
\brief This file has definitions of functions for unit tests.

This code is intended to be completed and submitted by a student,
so any changes in this file will be used in the evaluation on the VPL server.
You should not change functions' name and parameter types in provided code.
*******************************************************************************/

#include "unittests_functions.h"

#include <glm/gtx/extended_min_max.hpp>

#define UNUSED(x) (void)x;

template<typename T>
    T min(T a, T b) { return glm::min(a, b); }

template<typename T>
    T max(T a, T b) { return glm::max(a, b); }

template<typename T>
    T abs(T a) { return glm::abs(a); }

#include "unittests_data.h"

// Return the shortest non-negative time of intersection the ray and the sphere.
// Return 0.0f when there is no intersection
float time_intersect_ray_sphere(Ray ray, Sphere sphere)
{
    UNUSED(ray)
    UNUSED(sphere)
    // Ray origin
    vec3 O = ray.origin;

    // Ray direction
    vec3 D = ray.direction;

    // Sphere center
    vec3 C = sphere.center;

    // Sphere radius squared
    float rSquared = sphere.radius * sphere.radius;

    // Coefficients for the quadratic equation: At^2 + Bt + C = 0
    float A = glm::dot(D, D); // Dot product of direction with itself
    float B = 2.0f * glm::dot(D, O - C);
    float C_term = glm::dot(O - C, O - C) - rSquared;

    // Calculate the discriminant
    float discriminant = B * B - 4 * A * C_term;

    if (discriminant < 0.0f)
    {
        // No intersection
        return 0.0f;
    }
    else if (discriminant == 0.0f)
    {
        // One intersection (ray grazes the sphere)
        float t = -B / (2 * A);
        return (t >= 0.0f) ? t : 0.0f;
    }
    else
    {
        // Two intersections
        float sqrtDiscriminant = sqrt(discriminant);
        float t1 = (-B - sqrtDiscriminant) / (2 * A);
        float t2 = (-B + sqrtDiscriminant) / (2 * A);

        // Choose the smallest non-negative solution
        float t = glm::min(t1, t2);

        return (t >= 0.0f) ? t : 0.0f;
    }

    return 0.0f;
}

// Calculate the shade value and use it to set the traced color.
// Return vec3(0.0f, 0.0f, 0.0f), when the ray hits the background.
// Otherwise, calculate the shade value based on the normal and the light source
// position using Lambert's Cosine Law. Set up the value as R, G, and B components 
// of the return value. 
// To apply an ambient light contribution set 0.1f as the smallest value of the shade 
vec3 rayTracing(Ray ray, Sphere sphere, Light light)
{
    UNUSED(ray)
    UNUSED(sphere)
    UNUSED(light)

    // Calculate the intersection time
    float t = time_intersect_ray_sphere(ray, sphere);

    if (t <= 0.0f)
    {
        // No intersection with the sphere, return background color
        return vec3(0.0f, 0.0f, 0.0f);
    }

    // Calculate the intersection point I0
    vec3 I0 = ray.origin + t * ray.direction;

    // Calculate the normal vector N
    vec3 N = glm::normalize(I0 - sphere.center);

    // Ambient light contribution
    vec3 ambient = vec3(0.1f, 0.1f, 0.1f);

    // Diffuse light contribution using Lambert's Cosine Law
    vec3 L = glm::normalize(light.position - I0); // Direction from intersection point to light source
    float cosTheta = glm::max(0.0f, glm::dot(N, L)); // Lambert's Cosine Law

    // Calculate the shade value
    vec3 shade = max(ambient , cosTheta);

    // Ensure shade values are in the valid range [0, 1]
    shade = glm::clamp(shade, 0.0f, 1.0f);

    return shade;

    return vec3(0.0f);
}