#version 150
#if defined(RENDERTYPE_ENTITY_TRANSLUCENT_CULL)

#ifdef VERTEX_SHADER

struct Transform {
    vec3 position;
    vec4 color;
    float gameTime;
} transform;

void anchorZ(float depth, float target) {
    if(transform.position.z != depth) {
        return;
    }

    transform.position.z = target;
}
#endif

#ifdef FRAGMENT_SHADER

struct Transform {
    vec4 vertColor;
    vec4 overlayColor;
    vec4 shadeColor;
    vec4 lightColor;
    vec4 texColor;
    vec4 color;
    vec4 colorMod;
    float vertexDistance;
    float alpha;
    float emissive;
    float depth;
} transform;

void emissiveModel() {
    transform.emissive = sign(abs(transform.texColor.a - 254.0 / 255.0));
    transform.texColor.a = mix(1, transform.texColor.a, transform.emissive);
    transform.color = transform.texColor * mix(transform.shadeColor, transform.vertColor, transform.emissive) * transform.colorMod;
    transform.color.rgb = mix(transform.overlayColor.rgb, transform.color.rgb, transform.overlayColor.a);
    transform.color *= mix(vec4(1), transform.lightColor, transform.emissive);
}

void perspectiveModel(float worldAlpha, float interfaceAlpha, float depth) {
    if(alpha(transform.alpha, worldAlpha) && transform.vertexDistance < 800)
        discard;

    if(transform.vertexDistance >= 800) {
        if(alpha(transform.alpha, worldAlpha) && transform.depth < depth)
            discard;
        else if(alpha(transform.alpha, interfaceAlpha) && transform.depth >= depth)
            discard;
    }
}
#endif

#endif