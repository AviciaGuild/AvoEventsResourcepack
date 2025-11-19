#define PI 3.14159265359
#define TAU (PI * 2)

const vec2[] corners = vec2[4](vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0));

vec4 getVertexColor(sampler2D Sampler, int vertexID, vec2 coords) {
	ivec2 texSize = textureSize(Sampler, 0);
	vec2 offset = vec2(0.0);

	float pixelX = (1.0 / texSize.x) / 2.0;
	float pixelY = (1.0 / texSize.y) / 2.0;

	vertexID = vertexID % 4;
	switch(vertexID) {
		case 1:
			offset = vec2(-pixelX, pixelY);
			break;
		case 2:
			offset = vec2(pixelX, pixelY);
			break;
		case 3:
			offset = vec2(pixelX, -pixelY);
			break;
		case 0:
			offset = vec2(-pixelX, -pixelY);
			break;
		default:
			offset = vec2(0.0);
			break;
	}

	return texture(Sampler, coords - offset);
}

bool alpha(float textureAlpha, float targetAlpha) {
	float targetLess = targetAlpha - 0.01;
	float targetMore = targetAlpha + 0.01;
	return (textureAlpha > targetLess && textureAlpha < targetMore);
}

ivec4 getVertex(sampler2D Sampler0, int x, int y) {
	return ivec4(round(texelFetch(Sampler0, ivec2(x, y), 0) * 255));
}

int getGuiScale(mat4 ProjMat, vec2 ScreenSize) {
	return int(round(ScreenSize.x * ProjMat[0][0] / 2));
}

int toInt(ivec3 v) {
	return v.x << 16 | v.y << 8 | v.z;
}

bool isTooltip(mat4 ProjMat, vec3 Position) {
	return ProjMat[2][3] == 0 && Position.z > 300 && Position.z < 500;
}

uint colorId(vec3 col) {
	uint r = uint(round(col.r * 255.0));
	uint g = uint(round(col.g * 255.0));
	uint b = uint(round(col.b * 255.0));
	return ((uint(r) << 24) | (uint(g) << 16) | (uint(b) << 8) | 255u);
}

vec3 rgb(int r, int g, int b) {
	return vec3(r / 255.0, g / 255.0, b / 255.0);
}

vec3 hsvToRgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

int hash(int x) {
	x += (x << 10);
	x ^= (x >> 6);
	x += (x << 3);
	x ^= (x >> 11);
	x += (x << 15);
	return x;
}

float noise(vec2 uv, float t1, float t2) {
	return fract(sin(uv.x * t1 + uv.y * t2) * 56789);
}