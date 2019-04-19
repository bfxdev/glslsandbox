#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform sampler2D backbuffer;
uniform vec2 surfaceSize;

varying vec2 surfacePosition;

// Function taken from sandbox code 3410.2. Returns the pixel color of the previously computed picture
//  at offset (ox,oy) with respect to current position.
vec4 prev(int ox,int oy)
{
	return texture2D(backbuffer,mod(gl_FragCoord.xy+vec2(ox,oy),resolution)/resolution.xy)-0.5;
}

void main( void ) 
{
	// Clears the screen periodically
	if(sin(time/10.0)>= 0.99)
	{
		gl_FragColor = vec4(0.0);//0.95*prev(0,0);
		return;
	}
	
	// Temporary resulting color
	vec4 res;
	
	// Stores level of previous step into alpha component

	// Computes level
	float l = prev(1,0).b + prev(-1,0).b + prev(0,1).b + prev(0,-1).b - 2.0*prev(0,0).b - prev(0,0).a;

	res = 0.3*vec4(vec3(l+0.5), prev(0,0).b+0.5);
	
	if(distance(gl_FragCoord.xy, mouse*resolution)<10.0)
	{
		res = vec4(vec3(0.2), 0.0);
	}
	
	gl_FragColor = res;
}