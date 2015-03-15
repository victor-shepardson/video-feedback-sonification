uniform sampler2DRect image1;
uniform sampler2DRect image2;
uniform float mix_val;
varying vec2 texcoordM;

void main() {
    // get the homogeneous 2d position
    gl_Position = ftransform();

    // transform texcoord
    vec2 texcoord = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);

    // get sample positions
    texcoordM = texcoord;
}
