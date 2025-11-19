#version 150
#define FRAGMENT_SHADER
#define POSITION_TEX
#define POSITION_TEX_COLOR

#moj_import <util.glsl>
#moj_import <texture.glsl>
#moj_import <version.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;

in vec2 texCoord0;
in vec4 vertexColor;

out vec4 fragColor;

void main() {
    transform.textureUV = texCoord0;
    transform.colorMod = ColorModulator;
	#if defined(MC_1_21_2)
    transform.color = texture(Sampler0, texCoord0) * vertexColor;
	#else
    transform.color = texture(Sampler0, texCoord0);
	#endif

    removePixel(Sampler0, ivec2(0, 0), ivec4(255, 0, 0, 255));
    removePixel(Sampler0, ivec2(0, 1), ivec4(255, 0, 0, 255));

    if(transform.color.a == 0.0 || transform.color.a == 1.0 / 255.0)
        discard;

    fragColor = transform.color * transform.colorMod;
}