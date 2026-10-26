shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, shadows_disabled;

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec3 color_1 : source_color = vec3(0.09411765, 0.043137256, 0.16078432);
uniform vec3 color_2 : source_color = vec3(0.45882353, 0.32156864, 0.61960787);
uniform vec3 color_3 : source_color = vec3(0.88235295, 0.8, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.05;
uniform float pattern_scale : hint_range(0.1, 10.0) = 5.0;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.25;
uniform float distortion : hint_range(0.0, 4.0) = 2.0;
uniform float band_count : hint_range(1.0, 20.0) = 5.0;

varying vec3 sphere_direction;

float sample_noise(vec3 position, vec3 projection_weights) {
	float x_projection = texture(noise, position.yz * 0.05).r;
	float y_projection = texture(noise, position.xz * 0.05 + vec2(0.37, 0.17)).r;
	float z_projection = texture(noise, position.xy * 0.05 + vec2(0.73, 0.53)).r;
	return dot(vec3(x_projection, y_projection, z_projection), projection_weights);
}

vec3 iridescence_color(float position) {
	float wrapped_position = fract(position);

	if (wrapped_position < 0.333333) {
		return mix(color_1, color_2, wrapped_position * 3.0);
	}

	if (wrapped_position < 0.666667) {
		return mix(color_2, color_3, (wrapped_position - 0.333333) * 3.0);
	}

	return mix(color_3, color_1, (wrapped_position - 0.666667) * 3.0);
}

void vertex() {
	sphere_direction = normalize(VERTEX);
}

void fragment() {
	vec3 direction = normalize(sphere_direction);
	vec3 projection_weights = abs(direction);
	projection_weights *= projection_weights;
	projection_weights *= projection_weights;
	projection_weights /= dot(projection_weights, vec3(1.0));

	float time = TIME * flow_speed;
	vec3 position = direction * pattern_scale;

	vec3 first_warp = vec3(
		sample_noise(position * 0.65 + vec3(time, 0.0, -time * 0.37), projection_weights),
		sample_noise(position * 0.65 + vec3(7.3, time * 0.73, 2.1), projection_weights),
		sample_noise(position * 0.65 + vec3(-time * 0.41, 3.7, time * 0.59), projection_weights)
	);
	first_warp = first_warp * 2.0 - 1.0;

	vec3 warped_position = position + first_warp * distortion;
	float thickness = sample_noise(warped_position + vec3(time * 0.19, -time * 0.13, time * 0.17), projection_weights);
	float detail = sample_noise(warped_position * 1.7 - vec3(time * 0.11, time * 0.07, -time * 0.09), projection_weights);
	thickness = mix(thickness, detail, 0.3);

	float bands = thickness * band_count + time * 0.35;
	float liquid_pattern = 0.5 + 0.5 * sin(bands * TAU);

	ALBEDO = iridescence_color(bands);
	ALPHA = opacity * mix(0.12, 1.0, liquid_pattern);
}
