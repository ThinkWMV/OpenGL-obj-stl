attribute vec4 position;
smooth attribute vec4 color;

smooth varying vec4 fColor;

uniform mat4 projectionMatrix;
uniform mat4 cameraMatrix;
uniform mat4 modelMatrix;

void main(void) {
    fColor = color;
    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
    gl_Position = mvp * position;
}
