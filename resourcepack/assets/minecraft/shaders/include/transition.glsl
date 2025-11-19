#version 150
#if defined(RENDERTYPE_TEXT)

#ifdef VERTEX_SHADER

void offsetTransition(float marker) {
    if(int(transform.texture.b) == marker) {
        gl_Position.z = -0.26;
    }
}

void initTransitions() {
    if(transform.position.z == 2400.12 || transform.position.z == 2400.06 || transform.position.z == 1000.03) {
        if(transform.texture.a == 253) {
            transform.transition = int(transform.texture.b);

            if(transform.transition != 0) {
                transform.textureUV = vec2(transform.textureUV - transform.screen * 56 / 256);
                gl_Position.xy = vec2(transform.screen * 2 - 1) * vec2(1, -1);
                gl_Position.zw = vec2(-1, 1);

                offsetTransition(7);
                offsetTransition(16);
            }

            if(transform.isShadow) {
                transform.textureColor = vec4(0);
            }
        }
    }
}

#endif

#ifdef FRAGMENT_SHADER

#define UV (transform.centerUV / vec2(transform.aspectRatio, 1))
#define PROGRESS (cos(transform.vertexColor.a * PI / 2))

vec2 screen1 = round(transform.topRight / (transform.vertexId == 0 ? 1 - transform.screen.x : 1 - transform.screen.y));
vec2 screen2 = round(transform.bottomLeft / (transform.vertexId == 0 ? transform.screen.y : transform.screen.x));

ivec2 resolution = ivec2(abs(screen1 - screen2));
ivec2 offset = ivec2(min(screen1, screen2));

void resetColor() {
    transform.color = vec4(0);
}

void transitionIris() {
    transform.color = vec4(transform.vertexColor.rgb, (length((gl_FragCoord.xy / transform.screenSize - 0.5) / vec2(transform.screenSize.y / transform.screenSize.x, 1)) + 0.1 - PROGRESS * 1.5) * (1 - PROGRESS) * 100);
}

void transitionBlink() {
    transform.color = vec4(transform.vertexColor.rgb, clamp(length(transform.centerUV * vec2(1, 0.5 / (1 - transform.vertexColor.a))) - 1, 0, 1));
}

void transitionSpeed(float speed, float radius, float count, float blur) {
    resetColor();
    float angle = (atan(transform.centerUV.y, transform.centerUV.x) / PI / 2 + 0.5) * count;
    float time = transform.gameTime * speed + hash(int(angle)) % 100 * 64.2343;
    float s = (abs(fract(angle) - 0.5) * 20 / count - 0.2) * length(transform.centerUV) + radius + (1 - transform.vertexColor.a) * 0.05 + abs(fract(time) - 0.5) * 0.25;

    if(s < 0) {
        transform.color = vec4(transform.vertexColor.rgb, clamp(-s * blur, 0, 1));
    }
}

void transitionDiamond() {
    vec2 grid = (ivec2(gl_FragCoord.xy / 64) * 64);
    vec2 inGrid = gl_FragCoord.xy - grid - 32;
    float size = grid.y / transform.screenSize.y;
    size = (size - transform.vertexColor.a * 2 + 1) * 64;

    transform.color = (abs(inGrid.x) + abs(inGrid.y) > size) ? vec4(transform.vertexColor.rgb, 1) : vec4(0);
}

void transitionNoise() {
    ivec2 grid = ivec2(gl_FragCoord.xy / 64) * 64;

    transform.color = abs(hash(grid.x ^ hash(grid.y)) % 0x100) < int(transform.vertexColor.a * (length(grid / transform.screenSize.xy - 0.5) * 2 + 1) * 0x100) ? vec4(transform.vertexColor.rgb, 1) : vec4(0);
}

void transitionLoad(float speed) {
    resetColor();
    float radius = length(UV);

    if(radius >= 0.07 && radius < 0.1 && transform.vertexColor.a >= 0.99) {
        float angle = fract(-atan(UV.y, UV.x) / TAU - transform.gameTime * speed);
        transform.color = vec4(transform.vertexColor.rgb, angle);
    }
}

void transitionVignette(float intensity) {
    vec2 coord = UV * (resolution.x / resolution.y);
    coord.x *= coord.x / 2.5;
    float rf = sqrt(dot(coord, coord)) * transform.aspectRatio * intensity;
    float rf2_1 = rf * rf;
    float vignette = rf2_1 * rf2_1;

    transform.color = vec4(transform.vertexColor.rgb, vignette) * (1 - PROGRESS);
}

void transitionClose(float direction) {
    float s = 2 - abs(direction / (1 - PROGRESS) - 1);

    transform.color = vec4(transform.vertexColor.rgb, smoothstep(0, 0, s));
}

void transitionFade() {
    transform.color = vec4(transform.vertexColor.rgb, mix(0, 1, (1 - PROGRESS)));
}

void transitionLetterbox() {
    resetColor();
    float top = 2 - abs((transform.centerUV.y - 0.5) / (1 - PROGRESS));
    float bottom = 2 - abs((transform.centerUV.y + 0.5) / (1 - PROGRESS));

    if(UV.y > 1 - (1.2 * 0.5))
        transform.color = vec4(transform.vertexColor.rgb, smoothstep(0, 0, top));
    if(UV.y < (-0.8 * 0.5))
        transform.color = vec4(transform.vertexColor.rgb, smoothstep(0, 0, bottom));
}

void transitionWheel() {
    float circPos = atan(UV.y, UV.x) + PROGRESS * 2;
    float signed = sign(PROGRESS - mod(circPos, 3.14 / 4));

    transform.color = vec4(transform.vertexColor.rgb, step(signed, 0.5));
}

void transitionAngular(float startingAngle) {
    float os = startingAngle * PI / 180.0;
    float angle = atan(UV.y, UV.x) + os;
    float normal = (angle + PI) / (2.0 * PI);
    normal = normal - floor(normal);

    transform.color = vec4(transform.vertexColor.rgb, step(normal, (1 - PROGRESS)));
}

void transitionStatic() {
    float time = transform.gameTime * 2000;
    float t1 = time * 0.654321;
    float t2 = time * (t1 * 0.123456);

    vec3 st = vec3(noise(UV, t1, t2));

    transform.color = vec4(transform.vertexColor.rgb, st * (1 - PROGRESS));
}

void applyTransitions() {
    if(transform.transition != 0) {
        switch(transform.transition) {
            case 1:
                transitionIris();
                break;
            case 2:
                transitionBlink();
                break;
            case 3:
                transitionSpeed(2000, 0.07, 30, 200);
                break;
            case 4:
                transitionDiamond();
                break;
            case 5:
                transitionNoise();
                break;
            case 6:
                transitionLoad(1000);
                break;
            case 7:
                transitionVignette(3);
                break;
            case 8:
                transitionClose(transform.centerUV.y - 0.5);
                break;
            case 9:
                transitionClose(transform.centerUV.y + 0.5);
                break;
            case 10:
                transitionClose(transform.centerUV.x - 0.5);
                break;
            case 11:
                transitionClose(transform.centerUV.x + 0.5);
                break;
            case 12:
                transitionFade();
                break;
            case 13:
                transitionLetterbox();
                break;
            case 14:
                transitionWheel();
                break;
            case 15:
                transitionAngular(90);
                break;
            case 16:
                transitionStatic();
                break;
        }
    }
}

#endif
#endif