#version 150

#moj_import <fog.glsl>
#moj_import <glint.glsl>
#moj_import <version.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform float GlintAlpha;

uniform mat4 TextureMat;

in float vertexDistance;
in vec2 texCoord0;

in vec2 edgeUV;

out vec4 fragColor;

void main() {
    vec2 texCoord0 = scale(texCoord0, vec2(4, 2));
    texCoord0 = (TextureMat * vec4(texCoord0, 0, 1)).xy;
    vec4 color = texture(Sampler0, texCoord0) * ColorModulator;

    float edge = edge(edgeUV);
    color /= edge;

    float fade = linear_fog_fade(vertexDistance, FogStart, FogEnd) * GlintAlpha;
    fragColor = vec4(color.rgb * fade, color.a);
}
