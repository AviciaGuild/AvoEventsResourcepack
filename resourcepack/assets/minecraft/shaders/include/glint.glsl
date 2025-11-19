#define pi (3.1415926538)
#define brightness (0.1)

const vec2 uvs[4] = vec2[](vec2(0, 0), vec2(0, 1), vec2(1, 1), vec2(1, 0));

float edge(vec2 uv) {
    return (1 - brightness) + sin(pi * uv.x) * sin(pi * uv.y);
}

vec2 scale(vec2 pos, vec2 size) {
    pos *= floor(size);
    return pos;
}
