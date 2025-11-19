#version 150
#if defined(RENDERTYPE_TEXT)

#ifdef VERTEX_SHADER

struct Transform {
    vec4 color;
    vec4 textureColor;
    vec2 textureUV;
    vec4 texture;
    vec2 screenSize;
    vec3 position;
    vec4 screenOffset;
    vec4 initScreen;
    float gameTime;
    float textDepth;
    int transition;
    vec2 screen;
    bool isShadow;
} transform;

void hideScoreboardNumbers(vec3 position, vec3 numberColor, int vertex) {
    if(transform.position.z != position.z || gl_VertexID % vertex > 0)
        return;
    if(transform.initScreen.x < position.x || transform.initScreen.y < position.y)
        return;
    if(transform.color.r != numberColor.r / 255.0 || transform.color.g != numberColor.g / 255.0 || transform.color.b != numberColor.b / 255.0)
        return;

    transform.position.x += transform.screenSize.x + 100;
}

void offset(float alpha, vec2 gui, vec2 screen, bool align) {
    if(transform.textureColor.a != alpha) {
        return;
    }

    if(align && mod(round(transform.screenSize.x), 2) != 0) {
        transform.position.x += 1;
    }

    transform.position.x += gui.x;
    transform.position.y += gui.y;
    transform.screenOffset.x += screen.x;
    transform.screenOffset.y += screen.y;
}

void screenAnchor(vec4 atlas, int marker, vec2 offset, int anchor) {
    if(atlas != vec4(marker, 255, 0, 1)) {
        return;
    }

    vec2 screen;
    switch(anchor) {
        case 0:
            screen = vec2(-1, 2);
            break;
        case 1:
            screen = vec2(1, 2);
            break;
        case 2:
            screen = vec2(0, 2);
            break;
        case 3:
            screen = vec2(-1, 1);
            break;
        case 4:
            screen = vec2(1, 1);
            break;
        default:
            return;
    }

    transform.position.x += offset.x;
    transform.position.y += offset.y;
    transform.screenOffset.x += screen.x;
    transform.screenOffset.y += screen.y;
}

void anchorZ(float alpha, float depth, float target) {
    if(transform.textureColor.a != alpha) {
        return;
    }
    if(transform.textDepth != depth) {
        return;
    }
    transform.position.z = target;
}

void verticalSlide(vec4 color, float time) {
    if(transform.textureColor != color) {
        return;
    }

    transform.position.y += (time * 15) - 10;
}

#endif

#ifdef FRAGMENT_SHADER

struct Transform {
    vec4 texColor;
    vec4 color;
    vec4 colorMod;
    vec4 vertexColor;
    float gameTime;
    float textDepth;
    bool isShadow;

    vec2 screenSize;
    vec2 centerUV;
    float aspectRatio;

    int transition;
    int vertexId;
    vec2 topRight;
    vec2 bottomLeft;
    vec2 screen;
} transform;

void disableShadow(float depth) {
    if(transform.color.a <= 1 / 255.0 && transform.texColor.rgb != vec3(255)) {
        discard;
    }

    if(transform.texColor.a < 1.0) {
        if(transform.textDepth == depth || transform.textDepth == 0) {
            discard;
        }

        if(transform.texColor.a == 254.0 / 255.0) {
            transform.color = vec4(transform.texColor.rgb, 1.0) * transform.vertexColor * transform.colorMod;
        }
    }
}
#endif

#endif