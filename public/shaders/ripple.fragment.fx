#version 300 es
precision mediump float;

// Input
in vec2 model_uv;
// Uniforms
uniform sampler2D image;

// Output
out vec4 FragColor;
uniform float time;


void main() {

    vec2 uvNew = (model_uv * 2.0) - 1.0;
    float r = length(uvNew);
    //ASK MARRINAN HOW TO UPLOAD TIME
    vec2 offset = model_uv*sin((r*30.0) - (time*5.0))+0.5/60.0;
    vec2 final = uvNew + offset;
    // Color
    FragColor = texture(image, final);
}
