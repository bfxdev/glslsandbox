// Water simulation based on discretized wave equation by bfxdev

// Features:
//  - Simulation of the wave equation (l is the level at a given position): d²l/dx² + d²l/dy² = c²d²l/dt²
//  - Computation on a pseudo-infinite medium (borders wrapped around)
//  - Levels encoded in blue channel (t-1) and alpha channel (t-2)
//  - Lighting effect based on gradient of level and mouse position
//  - Central object with different medium celerity

#ifdef GL_ES
precision mediump float;
#endif



// Global variables set by Sandbox
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backbuffer;

// Returns the color from backbuffer relative to the current position plus offset
vec4 prevColor(vec2 offset)
{
	return texture2D(backbuffer,(mod(gl_FragCoord.xy+offset, resolution))/resolution);
}

// Gets previous level at the current position plus offset (ox,oy) and modulo on coordinates for
//  pseudo infinite medium (wrap around), at time t+ot (1 or 2). The level is given in range [-1,1]
float lev(int ox, int oy, int ot)
{
	// Gets color from backbuffer
	vec4 c = prevColor(vec2(ox,oy));

	// Returns color component blue or alpha transformed back to range [-1,1]
	return (ot==1?c.b:c.a) * 2.0 - 1.0;
}

// Encodes levels in range [-1,1] into 2 last color channels (blue and alpha) 
vec4 encodeLevels(float now, float past)
{
	return vec4(0.0, 0.0, (now+1.0)/2.0, (past+1.0)/2.0);
}


// Global constants
const float celerity = 0.4;   // Medium celerity
const float attenuation = 0.995;   // Medium attenuation

void main( void ) 
{
	// Inverts celerity in central form
	float c = celerity*(distance(gl_FragCoord.xy/resolution,vec2(0.5))<0.15?0.3:1.0); 
	
	// Resulting level computed using discretized wave equation
	float level = c*c*(lev(1,0,1)+lev(-1,0,1)+lev(0,1,1)+lev(0,-1,1)-4.0*lev(0,0,1)) - lev(0,0,2) + 2.0*lev(0,0,1);
	
	// Clears the screen periodically
	if(mod(time, 200.0) < 0.1)
		level = 0.0;

	// Puts a pulsating level at mouse position to disturb medium
	if(distance(gl_FragCoord.xy, mouse*resolution)<5.0)
		level = 0.9*sin(time*8.0);
	
	// Set current level to screen as blue color, and puts level at t+1 into alpha channel to use it as t+2 next time
	gl_FragColor = encodeLevels(level*attenuation, lev(0,0,1));
	//gl_FragColor = encodeLevels(sin(gl_FragCoord.x/10.0)*sin(gl_FragCoord.y/10.0), lev(0,0,1));
	
	
	// Adds mouse-centered light reflections on R and G components
	vec2 gra = vec2(lev(1,0,1)-lev(-1,0,1), lev(0,1,1)-lev(0,-1,1));// Gradient at current position
	vec2 v = mouse-gl_FragCoord.xy/resolution; 			// Vector from pos to mouse
	float f = -dot(gra,v/length(v));				// Resulting factor 
	gl_FragColor.rg = vec2(log(1.0+f)/(0.7+0.7*length(v)));			// Uses factor in RG channels after transformation
}
