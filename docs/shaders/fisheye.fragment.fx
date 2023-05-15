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
    vec2 uvNew = (model_uv * 2.0) - 1.0;
    float theta = atan(uvNew.y, uvNew.x);
    float magnitude = length(uvNew);
    float r = pow(magnitude, 1.5);
    vec2 fisheye = vec2(r * cos(theta), r * sin(theta));
    vec2 final = 0.5 * (fisheye + 1.0);
    FragColor = texture(image, final);
}
