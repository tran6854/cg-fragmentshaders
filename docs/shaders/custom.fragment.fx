#version 300 es
precision mediump float;

// Input
in vec2 model_uv;

// Uniforms
uniform sampler2D image;


// Output
out vec4 FragColor;

void main() {
    // Heat map
    const int resolution = 4;
    vec4 t = texture(image, model_uv);
    float resolutionF = float(resolution);
    vec4 final = round(resolutionF*t)/resolutionF;
    float blur[] = float[](0.0, 0.25, 0.5, 0.75, 1.0);
    float col[] = float[](final.r, final.g, final.b);
    vec4 temp[] = vec4[](vec4(0.0, 0.0, 1.0, 1.0), //blue
                        vec4(0.0, 1.0, 0.0, 1.0), //green
                        vec4(1.0, 0.98, 0.0, 1.0), //yellow
                        vec4(1.0, 0.0, 0.0, 1.0), //red
                        vec4(1.0, 1.0, 1.0, 1.0)); //white

    for(int i; i<5; i++){
        for(int j; j<3; j++){
            if(col[j] == blur[i]){
                final = temp[i];
                break;
            }
        }
    }
    // Color
    FragColor = final;
}
