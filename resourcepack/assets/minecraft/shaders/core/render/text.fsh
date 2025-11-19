#version 150
#define FRAGMENT_SHADER
#define RENDERTYPE_TEXT
#define RENDERTYPE_TEXT_SEE_THROUGH

#moj_import <fog.glsl>
#moj_import <util.glsl>
#moj_import <text.glsl>
#moj_import <effect.glsl>
#moj_import <version.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;
uniform vec2 ScreenSize;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

in float depth;
in float shadow;

flat in int transition;
flat in int vertexId;
in vec2 topRight;
in vec2 bottomLeft;
in vec2 screen;

out vec4 fragColor;

void main() {
    transform.vertexColor = vertexColor;
    transform.colorMod = ColorModulator;
    transform.texColor = texture(Sampler0, texCoord0);
    transform.color = transform.texColor * transform.vertexColor * transform.colorMod;
    transform.gameTime = GameTime;
    transform.screenSize = ScreenSize;
    transform.centerUV = gl_FragCoord.xy / transform.screenSize - 0.5;
    transform.aspectRatio = transform.screenSize.y / transform.screenSize.x;
    transform.textDepth = depth;
    transform.isShadow = shadow > 0.5;

    transform.transition = transition;
    transform.vertexId = vertexId;
    transform.topRight = topRight;
    transform.bottomLeft = bottomLeft;
    transform.screen = screen;

    // applyTransitions();
    disableShadow(2200);

	#if defined(MC_1_21_2)
    disableShadow(1200);
    disableShadow(-1000);

    #if defined(RENDER_WORLD)
    fragColor = transform.color * ColorModulator;
    #elif defined(RENDER_SCREEN)
    fragColor = linear_fog(transform.color, vertexDistance, FogStart, FogEnd, FogColor);
    #endif

    #else
    fragColor = linear_fog(transform.color, vertexDistance, FogStart, FogEnd, FogColor);
    #endif
}