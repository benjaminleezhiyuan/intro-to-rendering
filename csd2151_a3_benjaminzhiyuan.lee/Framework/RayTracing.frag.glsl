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

in vec3 TexCoord;

uniform vec2 iResolution;   // Viewport resolution (in pixels)
uniform int renderMode;     // Which render mode to use

layout(location=0) out vec4 FragColor;

struct Light
{
    vec3 position;
};

struct Ray
{
    vec3 origin;
    vec3 direction; // Normilized
};

struct Sphere
{
    vec3 center;
    float radius;
};

float time_intersect_ray_sphere(Ray ray, Sphere sphere)
{
    // Ray origin
    vec3 O = ray.origin;

    // Ray direction
    vec3 D = ray.direction;

    // Sphere center
    vec3 C = sphere.center;

    // Sphere radius squared
    float rSquared = sphere.radius * sphere.radius;

    // Coefficients for the quadratic equation: At^2 + Bt + C = 0
    float A = dot(D, D); // Dot product of direction with itself
    float B = 2.0f * dot(D, O - C);
    float C_term = dot(O - C, O - C) - rSquared;

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
        float t = min(t1, t2);

        return (t >= 0.0f) ? t : 0.0f;
    }

    return 0.0f;
}

//For mode 1
vec3 rayTracing(Ray ray, Sphere sphere)
{
    float t = time_intersect_ray_sphere(ray, sphere);

    vec3 finalColor = vec3(0.0f);

    if (t>0.0f)
    {
        vec3 hitpos = ray.origin + t * ray.direction;
        vec3 n = normalize(hitpos - sphere.center);

        finalColor = abs(vec3(n.z,n.z,n.z));       
    }

    return finalColor;
}

//For mode 2
vec3 rayTracing(Ray ray, Sphere sphere, Light light)
{
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
    vec3 N = normalize(I0 - sphere.center);

    // Ambient light contribution
    vec3 ambient = vec3(0.1f, 0.1f, 0.1f);

    // Diffuse light contribution using Lambert's Cosine Law
    vec3 L = normalize(light.position - I0); // Direction from intersection point to light source
    float cosTheta = max(0.0f, dot(N, L));   // Lambert's Cosine Law

    // Calculate the shade value
    vec3 shade = max(ambient, cosTheta);

    // Ensure shade values are in the valid range [0, 1]
    shade = clamp(shade, 0.0f, 1.0f);

    return shade;
}

void main()
{
    vec2 uv = (gl_FragCoord.xy * 2.0f - iResolution.xy) / iResolution.y;
    vec3 xyz = vec3(uv, -1.0f);
    vec3 direction = normalize(xyz); 
    Ray ray = Ray(vec3(0.0f), direction);
    Sphere sphere = Sphere(vec3(0.0f, 0.0f, -2.5f), 1.0f);
    Light light = Light(vec3(10.0f, 10.0f, 10.0f));

    if(renderMode == 1)
    FragColor = vec4(rayTracing(ray, sphere), 1.0f);

    if(renderMode == 2)
    FragColor = vec4(rayTracing(ray, sphere, light), 1.0f);
}
)"