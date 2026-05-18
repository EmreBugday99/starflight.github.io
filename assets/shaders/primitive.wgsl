struct PrimitiveData {
    world_position: vec2<f32>,
    size: vec2<f32>,
    color: vec4<f32>,
    params: vec4<u32>, // x: shape_type
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) @interpolate(flat) shape_type: u32,
    @location(2) local_pos: vec2<f32>,
}

@group(0) @binding(0) var<uniform> camera: mat4x4<f32>;
@group(0) @binding(1) var<storage, read> primitives: array<PrimitiveData>;

@vertex fn vs_main(@builtin(vertex_index) vertexId: u32, @builtin(instance_index) instanceId: u32) -> VertexOutput {
    let prim = primitives[instanceId];

    let positions = array<vec2<f32>, 6>(
        vec2<f32>(-0.5, -0.5), vec2<f32>(0.5, -0.5), vec2<f32>(-0.5, 0.5),
        vec2<f32>(0.5, -0.5), vec2<f32>(0.5, 0.5), vec2<f32>(-0.5, 0.5)
    );

    let uvs = array<vec2<f32>, 6>(
        vec2<f32>(0.0, 1.0), vec2<f32>(1.0, 1.0), vec2<f32>(0.0, 0.0),
        vec2<f32>(1.0, 1.0), vec2<f32>(1.0, 0.0), vec2<f32>(0.0, 0.0)
    );

    let localPos = positions[vertexId] * prim.size;
    let worldPos = vec4<f32>(prim.world_position + localPos, 0.0, 1.0);

    var output: VertexOutput;
    output.position = camera * worldPos;
    output.color = prim.color;
    output.shape_type = prim.params.x;
    output.local_pos = uvs[vertexId];
    return output;
}

@fragment fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    if (input.shape_type == 1u) {
        // Circle (shape_type == 1)
        let dist = distance(input.local_pos, vec2<f32>(0.5, 0.5));
        if (dist > 0.5) {
            discard;
        }
    }
    // Line and Rectangle just render the solid block
    return input.color;
}
