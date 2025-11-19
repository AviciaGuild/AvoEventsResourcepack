#version 150
#define VERTEX_SHADER
#define RENDERTYPE_TEXT
#define RENDERTYPE_TEXT_SEE_THROUGH

#moj_import <fog.glsl>
#moj_import <util.glsl>
#moj_import <text.glsl>
#moj_import <effect.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;
uniform float GameTime;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

out float depth;
out float shadow;

flat out int transition;
flat out int vertexId;
out vec2 topRight;
out vec2 bottomLeft;
out vec2 screen;

vec4 fetchAtlas(ivec2 coords) {
	return texelFetch(Sampler0, coords, 0) * 255.0;
}

void main() {
	transform.color = Color;
	transform.textureColor = getVertexColor(Sampler0, gl_VertexID, UV0) * 255;
	transform.textureUV = UV0;
	transform.texture = round(texture(Sampler0, transform.textureUV) * 255);
	transform.screenSize = ScreenSize;
	transform.position = Position;
	transform.screenOffset = vec4(0);
	transform.initScreen = ProjMat * ModelViewMat * vec4(Position, 1.0);
	transform.gameTime = GameTime;
	transform.textDepth = Position.z;

	topRight = bottomLeft = vec2(0);
	vertexId = gl_VertexID % 4;
	transform.screen = corners[vertexId];

	if(vertexId == 0)
		topRight = transform.textureUV * 256;
	if(vertexId == 2)
		bottomLeft = transform.textureUV * 256;
	transform.transition = 0;

	shadow = fract(transform.position.z) < 0.01 ? 1.0 : 0.0;
	transform.isShadow = shadow > 0.5;

	hideScoreboardNumbers(vec3(0.94, -0.35, 2000), vec3(255, 85, 85), 4);
	anchorZ(1.0, 2200.03, -2200.03);

	applyEffects();
	verticalSlide(vec4(43, 255, 0, 1), Color.a);
	screenAnchor(fetchAtlas(ivec2(6, 8)), 50, vec2(0, 0), 0);
	screenAnchor(fetchAtlas(ivec2(0, 0)), 45, vec2(0, 0), 0);
	screenAnchor(fetchAtlas(ivec2(6, 0)), 44, vec2(8, 2), 1);
	screenAnchor(fetchAtlas(ivec2(6, 8)), 49, vec2(0, 0), 2);
	screenAnchor(fetchAtlas(ivec2(6, 8)), 48, vec2(0, 0), 3);
	screenAnchor(fetchAtlas(ivec2(0, 0)), 46, vec2(0, 0), 4);
	screenAnchor(fetchAtlas(ivec2(6, 8)), 47, vec2(0, 0), 4);
	offset(3, vec2(0, 0), vec2(0, 1), true);

	gl_Position = (ProjMat * ModelViewMat * vec4(transform.position, 1.0)) + transform.screenOffset;

	// initTransitions();
	transition = transform.transition;
	screen = transform.screen;
	depth = Position.z;
	texCoord0 = transform.textureUV;
	vertexDistance = fog_distance(transform.position, FogShape);

	#if defined(MC_1_21_2)

	#if defined(RENDER_WORLD)
	vertexColor = transform.color;
	#elif defined(RENDER_SCREEN)
	vertexColor = transform.color * texelFetch(Sampler2, UV2 / 16, 0);
	#endif

	#else
	vertexColor = transform.color;
	#endif

}