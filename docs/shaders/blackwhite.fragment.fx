#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;

// Output
out vec4 FragColor;

void main() {
    // Color
    vec4 t = texture(image, model_uv);
    float L = 0.299 * t.r + 0.587 * t.g + 0.114 * t.b;
    // FragColor = texture(image, model_uv) * L;
    FragColor = vec4(L, L, L, 1.0);
}
