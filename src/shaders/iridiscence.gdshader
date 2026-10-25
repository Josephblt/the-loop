shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, shadows_disabled;

uniform vec3 color_1 : source_color = vec3(0.09411765, 0.043137256, 0.16078432);
uniform vec3 color_2 : source_color = vec3(0.45882353, 0.32156864, 0.61960787);
uniform vec3 color_3 : source_color = vec3(0.88235295, 0.8, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.05;
uniform float pattern_scale : hint_range(0.1, 10.0) = 5.0;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.25;
uniform float distortion : hint_range(0.0, 4.0) = 2.0;
uniform float band_count : hint_range(1.0, 20.0) = 5.0;

varying vec3 sphere_direction;

float random(vec3 position) {
	return fract(sin(dot(position, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}

float value_noise(vec3 position) {
	vec3 cell = floor(position);
	vec3 offset = fract(position);
	
	float bottom_back = mix(random(cell), random(cell + vec3(1.0, 0.0, 0.0)), offset.x);
	float top_back = mix(random(cell + vec3(0.0, 1.0, 0.0)), random(cell + vec3(1.0, 1.0, 0.0)), offset.x);
	float bottom_front = mix(random(cell + vec3(0.0, 0.0, 1.0)), random(cell + vec3(1.0, 0.0, 1.0)), offset.x);
	float top_front = mix(random(cell + vec3(0.0, 1.0, 1.0)), random(cell + vec3(1.0, 1.0, 1.0)), offset.x);

	float back = mix(bottom_back, top_back, offset.y);
	float front = mix(bottom_front, top_front, offset.y);
	return mix(back, front, offset.z);
}

float fbm(vec3 position) {
	float result = 0.0;
	float amplitude = 0.5;

	for (int octave = 0; octave < 4; octave++) {
		result += value_noise(position) * amplitude;
		position = position * 2.03 + vec3(17.1, 9.2, 13.7);
		amplitude *= 0.5;
	}

	return result / 0.9375;
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
	float time = TIME * flow_speed;
	vec3 position = direction * pattern_scale;

	vec3 first_warp = vec3(
		fbm(position * 0.65 + vec3(time, 0.0, -time * 0.37)),
		fbm(position * 0.65 + vec3(7.3, time * 0.73, 2.1)),
		fbm(position * 0.65 + vec3(-time * 0.41, 3.7, time * 0.59))
	);
	first_warp = first_warp * 2.0 - 1.0;

	vec3 warped_position = position + first_warp * distortion;
	float thickness = fbm(warped_position + vec3(time * 0.19, -time * 0.13, time * 0.17));
	float detail = fbm(warped_position * 1.7 - vec3(time * 0.11, time * 0.07, -time * 0.09));
	thickness = mix(thickness, detail, 0.3);

	float bands = thickness * band_count + time * 0.35;
	float liquid_pattern = 0.5 + 0.5 * sin(bands * TAU);

	ALBEDO = iridescence_color(bands);
	ALPHA = opacity * mix(0.12, 1.0, liquid_pattern);
}
