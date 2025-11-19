#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL)

#ifdef VERTEX_SHADER

#define EFFECT(r, g, b) break; case ((uint(r/4) << 16) | (uint(g/4) << 8) | (uint(b/4))):

void overrideShadow(float factor) {
    #ifdef RENDERTYPE_TEXT
    if(transform.isShadow) {
        transform.color.rgb *= factor;
    }
    #endif
}

void overrideColor(vec3 color) {
    transform.color.rgb = color;
    overrideShadow(0.25);
}

void effectRainbow() {
    transform.color.rgb = hsvToRgb(vec3(0.005 * (transform.position.x + transform.position.y) - transform.gameTime * 300.0, 0.7, 1.0));
    overrideShadow(0.25);
}

void effectGradient(vec3 color1, vec3 color2) {
    float rot = 0.08 * (transform.position.x + transform.position.y) - transform.gameTime * 600.0 * PI;
    float t = (sin(rot) + 1.0) * 0.5;

    transform.color.rgb = mix(color1, color2, t);
    overrideShadow(0.25);
}

void effectPulse(vec3 color1, vec3 color2) {
    transform.color.rgb = mix(color1, color2, sin(transform.gameTime * 800.0 * TAU) * 0.5 + 0.5);
    overrideShadow(0.25);
}

void effectFade(float speed) {
    transform.color.a = mix(transform.color.a, 0.0, sin(transform.gameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void effectBlink(float speed) {
    if(sin(transform.gameTime * 6400 * speed * PI) < 0.0) {
        transform.color.a = 0.0;
    }
}

void applyEffects() {
    uint vertexColorId = colorId(floor(round(transform.color.rgb * 255.0) / 4.0) / 255.0);
    #ifdef RENDERTYPE_TEXT
    if(transform.isShadow) {
        vertexColorId = colorId(transform.color.rgb);
    }
    #endif

    switch(vertexColorId >> 8) {
        case 0xFFFFFFFFu:
            #moj_import <config/effect.glsl>
    }
}
#endif

#ifdef FRAGMENT_SHADER

#endif
#endif