// Another Mandelbrot viewer by blogoben, visit http://blogoben.wordpress.com

// Mouse horizontal: color palette
// Mouse vertical:   zoom speed and amplitude

// If the mouse pointer is near the top of the screen, when the zoom is maximum,
//    the rendering is pixelized due to the limited precision of floats

// Now with "orbit trap" coloring 

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;

const int MAXITER = 150;

// Returns a color depending on a float
vec4 getColor(in float f)
{
	// Factor used to set to zero the returned colors around 1.0
	float p = min(1.0,log(10.0*abs(f-1.0)));

	// Color depends on mouse X position and oscillations in RBG
	float x = 2.0*f*(mouse.x+0.4);
	return p*vec4(abs(sin(x*2.0)), abs(sin(x*3.0)), abs(sin(x*5.0)), 0.0);
}


void main( void )
{
	// Coordinates transformed to square ([-1,1],[-1,1]) with extra space on sides
	vec2 p = (2.0*gl_FragCoord.xy/resolution-vec2(1.0))*vec2(resolution.x/resolution.y, 1.0);

	// Zoom factor is exponential with sine of time, with strong influence of mouse Y position
	float zoom = exp(11.0*(0.5+sin(time/10.0)*(1.0-mouse.y)));
	
	// Center of rendering is turning around a fix point, the excentricity depends on zoom factor
	vec2 translation = vec2(0.451001, 0.40004)+0.5*vec2(sin(time/21.0), cos(time/17.0))/zoom;
	
	// Classical rotation of the whole rendered space, 
	mat2 rotation = mat2(sin(time/5.0), cos(time/5.0), -cos(time/5.0), sin(time/5.0));
	
	// Transformations on p
	p = p*rotation/zoom+translation;
	 
	
	// Main loop
	vec2 z = vec2(0.0);			// Temporary complex variable set to 0 at first
	int count = MAXITER;			// Counter of iterations
	float dist = 2.0;			// Temporary distance for orbit trap
	for(int i=0; i<=MAXITER; i++)
	{
		// Standard Mandelbrot set, for z and p complex: z(n+1) = z(n)^2 + p
		z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + p;
		
		// Exits if |z| > 2
		if (length(z)>=2.0)
		{
			count = i;
			break;
		}
		
		// Keeps minimum distance between z and some point or form (orbit trap)
		dist = min(dist, distance(z, mouse));	
	}
	
	// Final color assignment
	gl_FragColor = 0.7*getColor(float(count)/float(MAXITER))+0.3*getColor(dist/2.0);
}
