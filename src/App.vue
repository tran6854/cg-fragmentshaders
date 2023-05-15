<script>
import { Engine } from '@babylonjs/core/Engines/engine';
import { Scene } from '@babylonjs/core/scene';
import { UniversalCamera } from '@babylonjs/core/Cameras/universalCamera';
import { Vector3 } from '@babylonjs/core/Maths/math.vector';
import { Mesh } from '@babylonjs/core/Meshes/mesh';
import { VertexData } from '@babylonjs/core/Meshes/mesh.vertexData';
import { ShaderMaterial } from '@babylonjs/core/Materials/shaderMaterial';
import { VideoTexture } from '@babylonjs/core/Materials/Textures/videoTexture';

import '@babylonjs/core/Engines/Extensions/engine.externalTexture';

const BASE_URL = import.meta.env.BASE_URL || '/';

export default {
    data() {
        return {
            gl: null,
            scene: null,
            filter_button: null,
            filter: 'standard',
            materials: {},
            selected_texture: 'video',
            textures: {video: null, webcam: null},
            start_stop: 'Stop',
        }
    },
    methods: {
        createShaderMaterial(shader, scene) {
            let material = new ShaderMaterial(shader, scene, BASE_URL + 'shaders/' + shader, {
                attributes: ['position', 'uv'],
                uniforms: ['worldViewProjection'],
                samplers: ['image']
            });
            material.backFaceCulling = false;
            return material;
        },

        selectFilter(event) {
            this.filter = event.target.id;
            this.filter_button.setAttribute('selected', 'false');
            let new_filter_button = document.getElementById(event.target.id + '_button');
            new_filter_button.setAttribute('selected', 'true');
            this.filter_button = new_filter_button;
        },

        toggleImageInput(event) {
            if (this.selected_texture === 'video') {
                this.selected_texture = 'webcam';
                this.textures.video.video.pause();
                if (this.textures.webcam === null && this.start_stop === 'Stop') {
                    VideoTexture.CreateFromWebCam(this.scene, (texture) => {
                        this.textures.webcam = texture;
                    }, {width: {ideal: 1280}, height: {ideal: 720}}, false, false);
                }
            }
            else {
                this.selected_texture = 'video';
                if (this.textures.webcam !== null) {
                    let webcam_stream = this.textures.webcam.video.srcObject;
                    webcam_stream.getTracks().forEach((track) => {
                        track.stop();
                    });
                    this.textures.webcam.dispose();
                    this.textures.webcam = null;
                }
                if (this.start_stop === 'Stop') {
                    this.textures.video.video.play();
                }
            }
        },

        startStop(event) {
            let start_stop_button = document.getElementById('start_stop');
            if (this.start_stop === 'Start') {
                this.start_stop = 'Stop';
                start_stop_button.style.backgroundColor = '#D85A58';
                if (this.selected_texture === 'video') {
                    this.textures.video.video.play();
                }
                else {
                    VideoTexture.CreateFromWebCam(this.scene, (texture) => {
                        console.log('here', texture);
                        this.textures.webcam = texture;
                    }, {width: {ideal: 1280}, height: {ideal: 720}}, false, false);
                }
            }
            else {
                this.start_stop = 'Start';
                start_stop_button.style.backgroundColor = '#48C45B';
                if (this.selected_texture === 'video') {
                    this.textures.video.video.pause();
                }
                else {
                    let webcam_stream = this.textures.webcam.video.srcObject;
                    webcam_stream.getTracks().forEach((track) => {
                        track.stop();
                    });
                    this.textures.webcam.dispose();
                    this.textures.webcam = null;
                }
            }
        }
    },
    mounted() {
        // Get the canvas element from the DOM
        const canvas = document.getElementById('renderCanvas');
        canvas.width = 800;
        canvas.height = 450;

        // Register callbacks for selecting filters
        let filters = document.getElementsByClassName('filter_button');
        for(let i = 0; i < filters.length; i++) {
            filters[i].addEventListener('click', this.selectFilter, false);
        }
        this.filter_button = document.getElementById('standard_button');

        // Create a WebGL 2 rendering context
        this.gl = canvas.getContext('webgl2');
        if (!this.gl) {
            alert('Error: Browser does not support WebGL2 Canvas');
            return;
        }

        // Associate a Babylon Render Engine to it.
        const engine = new Engine(this.gl);

        // Create our first scene.
        this.scene = new Scene(engine);
        this.scene.useRightHandedSystem = true;
        this.scene.skipFrustumClipping = true;

        // Add a camera to the scene
        let camera = new UniversalCamera('camera', new Vector3(0.0, 0.0, 0.0), this.scene);
        camera.detachControl();

        // Create materials
        this.materials.standard = this.createShaderMaterial('standard', this.scene);
        this.materials.blackwhite = this.createShaderMaterial('blackwhite', this.scene);
        this.materials.fisheye = this.createShaderMaterial('fisheye', this.scene);
        this.materials.ripple = this.createShaderMaterial('ripple', this.scene);
        this.materials.toon = this.createShaderMaterial('toon', this.scene);
        this.materials.custom = this.createShaderMaterial('custom', this.scene);

        // Create video textures
        this.textures.video = new VideoTexture('video', BASE_URL + 'videos/dm_vector.mp4', this.scene, false,
                                               false, VideoTexture.BILINEAR_SAMPLINGMODE, 
                                               {autoUpdateTexture: true, autoPlay: true, loop: true, muted: true});

        this.materials.standard.setTexture('image', this.textures.video);
        this.materials.blackwhite.setTexture('image', this.textures.video);
        this.materials.fisheye.setTexture('image', this.textures.video);
        this.materials.ripple.setTexture('image', this.textures.video);
        this.materials.toon.setTexture('image', this.textures.video);
        this.materials.custom.setTexture('image', this.textures.video);

        // Create simple rectangle model
        let rect = new Mesh('rect', this.scene);
        let vertex_positions = [
            -1.0, -1.0,  0.0, // vertex 0 (x,y,z)
             1.0, -1.0,  0.0, // vertex 1 (x,y,z)
             1.0,  1.0,  0.0, // vertex 2 (x,y,z)
            -1.0,  1.0,  0.0  // vertex 3 (x,y,z)
        ];
        let vertex_texcoords = [
            0.0, 0.0, // vertex 0 (u,v)
            1.0, 0.0, // vertex 1 (u,v)
            1.0, 1.0, // vertex 2 (u,v)
            0.0, 1.0  // vertex 3 (u,v)
        ]
        let triangle_indices = [
            0, 1, 2,              // connect vertices 0,1,2 to make a triangle
            0, 2, 3               // connect vertices 0,2,3 to make a triangle
        ];
        let vertex_data = new VertexData();
        vertex_data.positions = vertex_positions;
        vertex_data.uvs = vertex_texcoords;
        vertex_data.indices = triangle_indices;
        vertex_data.applyToMesh(rect);

        // Assign triangle a material
        rect.material = this.materials.standard;

        // Animation function - called before each frame gets rendered
        let time = 0.0;
        this.scene.onBeforeRenderObservable.add(() => {
            let delta_time = (1.0 / 60.0) * this.scene.getAnimationRatio();
            time += delta_time;
            if (this.filter !== rect.material.name) {
                rect.material = this.materials[this.filter];
            }

            if (this.textures[this.selected_texture] !== null) {
                this.materials[this.filter].setTexture('image', this.textures[this.selected_texture]);
                this.materials[this.filter].setFloat('time', time);
                // console.log(time);
            }
        });

        // Render every frame
        engine.runRenderLoop(() => {
            this.scene.render();
        });
    }
}
</script>

<template>
    <h1>WebGL Fragment Shader Fun!</h1>
    <canvas id="renderCanvas" touch-action="none"></canvas>
    <br/>
    <div class="spacer"></div>
    <div id="gui">
        <div id="standard_button" class="filter_button" selected="true">
            <p id="standard">Standard</p>
        </div>
        <div id="blackwhite_button" class="filter_button">
            <p id="blackwhite">Black & White</p>
        </div>
        <div id="fisheye_button" class="filter_button">
            <p id="fisheye">Fish Eye</p>
        </div>
        <div id="ripple_button" class="filter_button">
            <p id="ripple">Ripple</p>
        </div>
        <div id="toon_button" class="filter_button">
            <p id="toon">Toonify</p>
        </div>
        <div id="custom_button" class="filter_button">
            <p id="custom">Custom</p>
        </div>
    </div>
    <div class="spacer"></div>
    <div>
        <div id="image_toggle">
            <div style="display: inline-block;">
                <label class="toggle_label">Video</label>
            </div>
            <div style="display: inline-block;">
                <label class="switch" style="margin-top: 0.25rem;">
                    <input id="image_input" type="checkbox" @change="toggleImageInput">
                    <span class="slider round"></span>
                </label>
            </div>
            <div style="display: inline-block;">
                <label class="toggle_label">WebCam</label>
            </div>
        </div>
        <div id="start_stop_button">
            <p id="start_stop" @click="startStop">{{ start_stop }}</p>
        </div>
    </div>
</template>

<style scoped>
h1 {
    font-size: 1.5rem;
    font-weight: bold;
    font-style: normal;
}

p, label {
    font-size: 0.875rem;
}

input {
    margin: 0.2rem;
}

#start_stop_button {
    display: inline-block;
    vertical-align: top;
    background-color: #D85A58;
    width: 8rem;
    height: 2.5rem;
    margin: 0.5rem;
    cursor: pointer;
}

#start_stop_button p {
    height: 2.5rem;
    line-height: 2.5rem;
    color: #000000;
}

#image_toggle {
    display: inline-block;
    vertical-align: top;
    width: 20rem;
    height: 3rem;
    margin: 0.5rem;
}

.toggle_label {
    display: inline-block;
    margin: 0.75rem 1rem 0 1rem;
}

.filter_button {
    display: inline-block;
    background-color: #6A6A6A;
    width: 8rem;
    height: 2.5rem;
    margin: 0.5rem;
    cursor: pointer;
}

.filter_button[selected="true"] {
    background-color: #2A3A8A;
}

.filter_button p {
    height: 2.5rem;
    line-height: 2.5rem;
    color: #FFFFFF;
}

.spacer {
    height: 1rem;
}

.switch {
    position: relative;
    display: inline-block;
    width: 3.5rem;
    height: 1.5rem;
}
  
.switch input { 
    opacity: 0;
    width: 0;
    height: 0;
}

.slider {
    position: absolute;
    cursor: pointer;
    top: -0.3rem;
    left: 0;
    right: 0;
    bottom: 0.3rem;
    background-color: #CCCCCC;
    -webkit-transition: .4s;
    transition: .4s;
}
  
.slider:before {
    position: absolute;
    content: "";
    height: 1.1rem;
    width: 1.1rem;
    left: 0.2rem;
    bottom: 0.2rem;
    background-color: #FFFFFF;
    -webkit-transition: 0.4s;
    transition: 0.4s;
}
  
input:checked + .slider {
    background-color: #2196F3;
}
  
input:focus + .slider {
    box-shadow: 0 0 1px #2196F3;
}
  
input:checked + .slider:before {
    -webkit-transform: translateX(2rem);
    -ms-transform: translateX(2rem);
    transform: translateX(2rem);
}
  
/* Rounded sliders */
.slider.round {
    border-radius: 1.1rem;
}
  
.slider.round:before {
    border-radius: 50%;
}
</style>
