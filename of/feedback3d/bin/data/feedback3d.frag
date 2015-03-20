uniform sampler2DRect image1;
uniform sampler2DRect image2;
uniform float fb;
uniform float gen;
uniform float tblur;
uniform float sblur;
uniform float warp;
uniform float perm;
uniform float frame;
uniform int bound;
uniform ivec2 size;
uniform vec2 slice;

varying vec2 texcoordM;

#define PI 3.1415926535897932384626433832795

vec2 invslice = 1./slice;
vec3 size3 = floor(vec3(size*invslice, slice.x*slice.y));
vec3 invsize3 = 1./size3;
vec2 invsize = 1./vec2(size);

//hsv conversion from lolengine.net: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-1;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec2 pol2car(vec2 pol){
	return pol.x*vec2(cos(pol.y), sin(pol.y));
}

float fastmod(float a, float b, float invb){
	return fract(a*invb)*b;
}
vec2 fastmod(vec2 a, vec2 b, vec2 invb){
	return fract(a*invb)*b;
}

//convert between 2D texture coordinates and 3D volumetric coordinates, preserving xy spatial distance
vec2 cell(vec2 p){
	return floor(p*invsize*slice);
}
vec2 cell(vec3 p){
	return floor(vec2(fastmod(p.z, slice.x, invslice.x), p.z*invslice.x));
}
vec2 flatten(vec3 p){
	vec2 c = cell(p);
	return c*size3.xy+p.xy;
}
vec3 raise(vec2 p){
	vec2 c = cell(p);
	vec2 xy = fastmod(p, size3.xy, invsize3.xy);
	float z = c.x+c.y*slice.x;
	return vec3(xy, z);
}

//convert between bipolar [-1, 1] and unipolar [0, 1]
vec3 u2b(vec3 u){
	return 2.*u-1.;
}
vec3 b2u(vec3 b){
	return .5*b+.5;
}

void main() {
	//sample last frame
	vec3 color_in = texture2DRect(image2, texcoordM).rgb;
	vec3 p = raise(texcoordM.xy);

	//warp
	vec3 hsv = rgb2hsv(color_in);
	//vec2 disp = pol2car(vec2(hsv.y*warp, 2*PI*hsv.x));
	vec3 color_center;
	if(slice.x*slice.y>1){
		vec3 displaced = clamp(u2b(color_in)*warp + raise(texcoordM), vec3(0), vec3(size3));
		color_center = texture2DRect(image2, flatten(displaced)).rgb;
	}
	else{
		vec2 displaced = texcoordM + pol2car(vec2(hsv.y*warp, 2*PI*hsv.x));
		color_center = texture2DRect(image2, displaced).rgb;
	}


	vec3 color = color_center;//mix(color_center, .25*(color_left+color_right+color_up+color_down), sblur);

	//to bipolar
	color = u2b(color);

	//color permutation
	color = (perm>0.) ?  mix(color.rgb, color.gbr, perm) : mix(color.rgb, color.brg, -perm);

	//generators + feedback
	//vec3 color_gen = texture2DRect(image1, texcoordM).rgb;

	vec3 color_gen;
	if(slice.x*slice.y>1){
		//vec3 color_gen = vec3(sin(frame+p.x*.005), sin(frame+p.y*.0055), cos(frame+p.z*-.00555));
		color_gen = sin(PI*(p.xyz*invsize3.xyz*5*vec3(.1,.11,.111)+frame*vec3(.01111, .011111, .0111111)));
	}
	else{
		color_gen = sin(PI*(texcoordM.xyx*invsize.xyx*5*vec3(.1,.11,.111)+frame*vec3(.01111, -.011111, -.0111111)));
	}
	color = gen * color_gen + fb *color ;

	//bounding function
	if(bound==1){
		color = vec3(-1.)+2.*fract(.5*color+.5);
	}
	if(bound==2){
		color = sin(.5*PI*color);
	}

	//to unipolar
	color = b2u(color);

	if(bound==3){
		hsv = rgb2hsv(color);
		float v = 2*hsv.z-1;
		v = .5*sin(.5*PI*v)+.5;
		color = hsv2rgb(vec3(hsv.rg, v));
	}

	//temporal blur
	color = mix(color, color_in, tblur);

	//color = vec3(texcoordM.xy/size,0);
	//color = vec3(cell(texcoordM.xy)*invslice,0);
	//color = p*invsize3;
	//color = vec3(flatten(raise(texcoordM.xy))*invsize.xy,0);


    gl_FragColor = vec4(color, 1.);
}

//to do:
// - feedforward mode parameter (pre warp, pre convolution, etc)
// - warp modes
// - separate convolution stage, edge aware blur
// - spatial wrap mode (must be done explicitly if using rectangular textures)
// - volumetric 3D mode
// - modulation by external inputs
// - rich function generators
// - modulation by internal features: edges, flow
// - read from and render to images