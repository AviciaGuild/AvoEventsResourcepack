#version 150
#define VERTEX_SHADER
#define RENDERTYPE_GUI
#define POSITION_COLOR

#moj_import <util.glsl>
#moj_import <gui.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

void main() {
    transform.color = Color;
    transform.position = Position;
    transform.projMat = ProjMat;

    gl_Position = ProjMat * ModelViewMat * vec4(transform.position, 1.0);

    disableBadges(2);
    disableTooltips();
    vertexColor = transform.color;
}