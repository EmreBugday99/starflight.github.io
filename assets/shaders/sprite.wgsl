struct SpriteData {
    world_position: vec2<f32>,
    size: vec2<f32>,
    color: vec4<f32>,
    uv_rect: vec4<f32>,
}

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) color: vec4<f32>,
    @location(1) uv: vec2<f32>,
}

@group(0) @binding(0) var<uniform> camera: mat4x4<f32>;
@group(0) @binding(1) var<storage, read> sprites: array<SpriteData>;
@group(0) @binding(2) var atlas_texture: texture_2d<f32>;
@group(0) @binding(3) var atlas_sampler: sampler;

@vertex fn vs_main(@builtin(vertex_index) vertexId: u32, @builtin(instance_index) instanceId: u32) -> VertexOutput {
    let sprite = sprites[instanceId];

    let positions = array<vec2<f32>, 6>(
        vec2<f32>(-0.5, -0.5), vec2<f32>(0.5, -0.5), vec2<f32>(-0.5, 0.5),
        vec2<f32>(0.5, -0.5), vec2<f32>(0.5, 0.5), vec2<f32>(-0.5, 0.5)
    );

    // Y is flipped: world +Y is up, UV V=0 is top of texture.
    let uvs = array<vec2<f32>, 6>(
        vec2<f32>(0.0, 1.0), vec2<f32>(1.0, 1.0), vec2<f32>(0.0, 0.0),
        vec2<f32>(1.0, 1.0), vec2<f32>(1.0, 0.0), vec2<f32>(0.0, 0.0)
    );

    let localPos = positions[vertexId] * sprite.size;
    let worldPos = vec4<f32>(sprite.world_position + localPos, 0.0, 1.0);

    let local_uv = uvs[vertexId];
    let u = mix(sprite.uv_rect.x, sprite.uv_rect.z, local_uv.x);
    let v = mix(sprite.uv_rect.y, sprite.uv_rect.w, local_uv.y);

    var output: VertexOutput;
    output.position = camera * worldPos;
    output.color = sprite.color;
    output.uv = vec2<f32>(u, v);
    return output;
}

@fragment fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    let sampled = textureSample(atlas_texture, atlas_sampler, input.uv);
    return sampled * input.color;
}
