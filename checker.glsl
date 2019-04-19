// Mini raytracer from scratch by blogoben, work in progress
// 3004.0: plane with glowing checker texture and camera rotations
// 3004.1: changed order of rotations and factors for camera control
// 3004.2: extensive re-factoring, addition of flat-rendered spheres

#ifdef GL_ES
precision highp float;
#endif 

// Uniform variables set by sandbox:
uniform vec2  resolution; // Size in pixels of rendered rectangle
uniform float time;       // Time (in seconds?) since reload/modification of page
uniform vec2  mouse;      // Virtual position of mouse pointer inside rendered rectangle i.e. 0<x<1, 0<y<1

// Constants
#define PI 3.1416
#define EPSILON 0.0000001
#define MAX_ITERRATIONS 5

// Objects defined as macros (simple but ugly)
#define BALL vec3(0.0,0.0,0.0), 0.4
#define LIGHT vec3(0.7,-0.7,0.0), 0.2
#define PLANE vec3(0.0,2.0,0.0), vec3(0.0,1.0,0.0)


// Computes the distance between the given eye point and a plane (defined by a point and a normal)
//  in the direction of the given ray
float planeIntersectionDistance(vec3 eye, vec3 ray, vec3 point, vec3 normal)
{
	// Computes indicator of parallelism between ray and the plane
	float d = dot(normal, ray);
	
	// Exits if ray and plane are nearly parallel
	if(abs(d)<EPSILON)
		return -1.0;
	
	// Computes distance
	return dot(normal, point - eye)/d;
}

// Computes the distance between the given eye point and a sphere defined by its center and a radius
//  in the direction of the given ray
float sphereIntersectionDistance(vec3 eye, vec3 ray, vec3 centre, float radius)
{
	// Computes factors of the ax^2+bx+c=0 equation giving both intersections with sphere,
	//  see http://www.csee.umbc.edu/~olano/435f02/ray-sphere.html
	float a = dot(ray, ray);
	float b = 2.0*dot(ray, eye-centre);
	float c = dot(eye-centre, eye-centre) - radius*radius;
	
	// Computes discriminant
	float disc = b*b-4.0*a*c;
	
	// Returns -1 if there is no intersection at all
	if(disc<EPSILON)
		return -1.0;
	
	// Computes both intersections
	float d1 = (-b+sqrt(disc))/(2.0*a);
	float d2 = (-b-sqrt(disc))/(2.0*a);
	
	// Checks if bothe intersection points are behind eye or on sphere
	if(d1<EPSILON && d2<EPSILON)
		return -1.0;
	
	// Check if eye is inside sphere, i.e. one intersection point is behind eye
	if(d1*d2<EPSILON)
		return max(d1,d2);
	
	// Normal case if both intersection points are visible
	return min(d1,d2);
}

// Computes pixel color for smooth, pulsating checker texture, using texture coordinates (u,v)
//  Distance to origin is used to hide aliasing effects
vec3 smoothCheckerTextureColor(float u, float v)
{
	// Computes factor used in the dynamic texture of the plane, sin(x)*cos(y) to give a smooth checker
	float ft = exp(sin(u*6.0)*cos(v*6.0)+sin(time)/4.0+0.5)/2.1;
	
	// Final texture computed by blending the color to black to hide aliasing towards infinity
	return mix(vec3(ft, ft, ft), vec3(0.0,0.0,0.0), clamp(log(length(vec2(u,v)))/3.0,0.0,1.0));
}

// Main recursive function
vec3 raycastColor(vec3 eye, vec3 ray, int iter)
{
	// Check if we reached limit of iterrations
	if(iter==0) return vec3(0.0,0.0,0.0);
	else iter--;
	
	// Prepares variables to find minimum distance to intersected object
	float mindist=1e20;
	int type;
	
	// Central ball
	float distBall = sphereIntersectionDistance(eye, ray, BALL);
	if(distBall>0.0)
	{
		mindist = distBall;
		type = 1;
	}
	
	// Light
	float distLight = sphereIntersectionDistance(eye, ray, LIGHT);
	if(distLight>0.0 && distLight<mindist)
	{
		mindist = distLight;
		type=2;
	}

	// Plane
	float distPlane = planeIntersectionDistance(eye, ray, PLANE);
	if(distPlane>0.0 && distPlane<mindist)
	{
		mindist = distPlane;
		type=3;
	}
	
	// Case 1: ball outside
	if(type==1)
		return vec3(0.0,0.0,1.0);
	
	// Case 2: light
	if(type==2)
		return vec3(1.0,1.0,1.0);
	
	// Case 3: Plane
	if(type==3)
	{
		// Computes intersection and texture
		vec3 i = eye + distPlane*ray;
		return smoothCheckerTextureColor(i.x, i.z);
	}
	
	// Otherwise returns black
	return vec3(0.0,0.0,0.0);
}

void main(void)
{	
	// Computes aspect of rendered rectangle
	float aspect = resolution.x / resolution.y;
	
	// Computes virtual position of rendered point inside a 2x2 square
	vec2 p = vec2( ( 2.0*gl_FragCoord.x/resolution.x - 1.0 ) * aspect,
			 2.0*gl_FragCoord.y/resolution.y - 1.0 );

	// Computes angles for changing viewpoint by moving the mouse and time
	float rotx =3.55-mouse.y*1.5;
	float roty = -mouse.x*4.0+time/20.0;
	
	// Computes rotations matrix around Y then X axes (see blogoben.wordpress.com)
	mat3 rotations = mat3( cos(roty), 0.0, sin(roty),
			       0.0,       1.0,       0.0,
			      -sin(roty), 0.0, cos(roty));
	rotations *=     mat3(1.0,       0.0,        0.0,
			      0.0, cos(rotx), -sin(rotx),
			      0.0, sin(rotx),  cos(rotx));

	// Defines constant viewpoint at (0,0.0,4)
	vec3 eye = vec3(0.0, 0.0, 4.0);

	// Defines normalized ray to intersect with scene, from eye to rendered point at z=2
	vec3 ray = normalize(vec3(p.xy, 2.0)- eye);
	
	// Rotates eye and ray, i.e. moves observer of the scene according to mouse position
	eye *= rotations;
	ray *= rotations;

	// Calls main rendering function and returns color
   	gl_FragColor = vec4(raycastColor(eye, ray, MAX_ITERRATIONS),1.0);
}
