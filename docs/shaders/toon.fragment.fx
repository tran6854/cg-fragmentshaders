#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;

// Output
out vec4 FragColor;

void main() {
    vec4 t = texture(image, model_uv);
    vec4 final = round(4.0*t)/4.0;
    // Color
    FragColor = final;
}
