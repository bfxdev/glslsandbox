// Fixed Mandelbrot set with visible sequence of points in complex plane (starting at mouse position)
// By bfxdev
#ifdef GL_ES
precision highp float;
#endif

// Global uniform variables set by sandbox
uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;

// Max iterations
const int maxIter = 40;

// Divergence radius
const float maxRadius = 2.0;

// Translation applied to device coords;
vec2 translation = vec2(-0.68, -0.5);

// Scale factor vector
vec2 scale = vec2(3.0, 2.0);

void main ()
{
	// By default returns black
	gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	
	// Determines first position
	vec2 pos = (gl_FragCoord.xy/resolution+translation)*scale;
	
	// Initialization of temporary variables
    	vec2 z = vec2(0.0);

	// Main Mandelbrot loop
	for(int i=0; i<maxIter; i++)
	{
		// Mandelbrot formula
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + pos;

		// Break condition
		if(length(z)>maxRadius)
		{
			// Sets Mandelbrot color gray       
		        gl_FragColor.rgb += vec3(float(i)/float(maxIter))/3.0;
			break;
		}
	}
	
	// Second Mandelbrot loop at mouse position (same result for all points)
	vec2 posm = (mouse+translation)*scale;
    	z = posm; // Starts at mouse position
	for(int i=0; i<maxIter; i++)
	{
		vec2 oz = z;
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + posm;
		if(length(z)>maxRadius) break;
		
		// Traces orbit
		if(distance(oz,pos)<0.04 || dot(z-pos, oz-pos)/length(z-pos)/length(oz-pos)<-0.999)
			gl_FragColor.rgb += vec3(0.2, 0.2, 0.4);
	}
	
	// Julia loop, same as Mandelbrot with z0 depending on current pos,
	//    c equal to mouse position
	vec2 julScale = vec2(3.0);
	vec2 julTrans = vec2(-0.5);
	pos = (pos/scale-translation+julTrans)*julScale;
	z = pos;
	for(int i=0; i<maxIter; i++)
	{
		vec2 oz = z;
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + posm;
		if(length(z)>maxRadius)
		{
		        gl_FragColor.r += float(i)/float(maxIter);
			break;
		}
		
	}
	
	
	
	// Traces circle max radius
	if(length(pos)>maxRadius)
		gl_FragColor.g += 0.04;
	
	
}
