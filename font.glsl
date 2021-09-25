// Text scroll revival
// By bfxdev, December 2012

// GLSL magick
#ifdef GL_ES
precision mediump float;
#endif

// Global input variables
uniform float time;
uniform vec2  mouse;
uniform vec2  resolution;

// Definition of displayed message, value assigned in init() function
const int messageSize = 10;
int message[messageSize];

// Definition of the character font, value assigned in init() function
const int fontWidth  = 8;
const int fontHeight = 8;
const int fontSize = 128;
struct FontChar
{
	int lines[fontWidth];
} font[fontSize];


#define DEFARRAY(t,o,a,b,c,d,e,f,g,h) t[o]=a;t[1+o]=b;t[2+o]=c;t[3+o]=d;t[4+o]=e;t[5+o]=f;t[6+o]=g;t[7+o]=h;
void init()
{
	// Initialization of message
	DEFARRAY(message, 0, 0, 0, 0, 0, 0, 0, 0, 0);
	message[8]=0;message[9]=0;

	DEFARRAY(font[0].lines, 0, 0x18, 0x24, 0x42, 0x42, 0x42, 0x42, 0x24, 0x18);
}


bool inMessage(vec2 pos, vec2 apos, vec2 asize)
{
	// Checks if the current position is in the string area
	if(any(lessThan(pos, apos)) || any(greaterThan(pos, apos+asize)))
		return false;
	
	// Determines pixel coordinates within string
	vec2 rpos = (apos-pos)/asize*vec2(float(messageSize),1.0); // Relative position in string area
	int letterIndex = int(rpos.x);
	int columnIndex = int(fract(rpos.x)*float(fontWidth));
	int rowIndex = int(fract(rpos.y)*float(fontHeight));

	int letter;
	for(int i=0; i<messageSize; i++)
		if(i==letterIndex)
			letter = message[i];

	int bitmapLine;
	for(int i=0; i<fontSize; i++)
		if(i==letter)
			for(int j=0; j<fontHeight; j++)
				if(j==rowIndex)
					bitmapLine = font[i].lines[j];
	
	return fract(floor(float(bitmapLine)/pow(2.0,
					  float(columnIndex)))/2.0)==0.0;
			
	//return mod(float(letterIndex), 2.0) < 1.0;
	
	//return mod(float(letterIndex), 2.0) < 1.0;
	
	return true;
}

// Main function
void main(void)
{
	// Init structures
	init();

	// Call procedural string enveloppe function
	if(inMessage(gl_FragCoord.xy, vec2(resolution.x*0.8*sin(time/1.0), resolution.y*0.2),
				      vec2(resolution.y*0.3*float(messageSize), resolution.y*0.6)))
	{
		// Standard GLSL Sandbox effect
		vec2 position = ( gl_FragCoord.xy / resolution.xy ) + mouse / 4.0;
		float color = 0.0;
		color += sin( position.x * cos( time / 15.0 ) * 80.0 ) + cos( position.y * cos( time / 15.0 ) * 10.0 );
		color += sin( position.y * sin( time / 10.0 ) * 40.0 ) + cos( position.x * sin( time / 25.0 ) * 40.0 );
		color += sin( position.x * sin( time / 5.0 ) * 10.0 ) + sin( position.y * sin( time / 35.0 ) * 80.0 );
		color *= sin( time / 10.0 ) * 0.5;
		gl_FragColor = vec4( vec3( color, color * 0.5, sin( color + time / 3.0 ) * 0.75 ), 1.0 );
	}
	else
		gl_FragColor = vec4(0.0);

}
