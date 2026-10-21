shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Color;

uniform vec4 barrier_color : source_color = vec4(0.094, 0.043, 0.161, 0.58);
uniform vec4 dissolve_color : source_color = vec4(0.459, 0.322, 0.620, 0.9);
uniform vec4 edge_color : source_color = vec4(0.882, 0.8, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 8.0) = 2.5;

group_uniforms Dissolve;

uniform float formation_amount : hint_range(0.0, 1.0) = 1.0;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.5;
uniform float dissolve_width : hint_range(0.0, 0.3) = 0.12;
uniform float softness : hint_range(0.001, 0.2) = 0.045;
uniform float noise_scale : hint_range(1.0, 30.0) = 8.0;
uniform float lateral_speed : hint_range(-2.0, 2.0) = 0.12;
uniform float vertical_speed : hint_range(-2.0, 2.0) = 0.08;
uniform float morph_speed : hint_range(0.0, 3.0) = 0.3;
uniform float distortion : hint_range(0.0, 2.0) = 0.4;
uniform float swirl_strength : hint_range(0.0, 2.0) = 0.3;

float random(vec2 position) {
	return fract(sin(dot(position, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 offset = fract(position);
	vec2 blend = offset * offset * (3.0 - 2.0 * offset);

	float bottom_left = random(cell);
	float bottom_right = random(cell + vec2(1.0, 0.0));
	float top_left = random(cell + vec2(0.0, 1.0));
	float top_right = random(cell + vec2(1.0, 1.0));

	return mix(mix(bottom_left, bottom_right, blend.x), mix(top_left, top_right, blend.x), blend.y);
}

float fbm(vec2 position) {
	float result = 0.0;
	float amplitude = 0.5;

	for (int octave = 0; octave < 5; octave++) {
		result += value_noise(position) * amplitude;
		position = position * 2.03 + vec2(17.1, 9.2);
		amplitude *= 0.5;
	}

	return result / 0.96875;
}

void fragment() {
	float time = TIME * morph_speed;
	vec2 position = UV * noise_scale;
	position += vec2(-TIME * lateral_speed, TIME * vertical_speed);

	vec2 fluid_field = vec2(
		fbm(position * 0.55 + vec2(time * 0.13, time * 0.09)),
		fbm(position * 0.55 + vec2(6.8 - time * 0.11, 3.4 + time * 0.15))
	);
	fluid_field = fluid_field * 2.0 - 1.0;

	vec2 swirl = vec2(-fluid_field.y, fluid_field.x);
	vec2 warped_position = position + fluid_field * distortion + swirl * swirl_strength;

	vec2 secondary_field = vec2(
		fbm(warped_position + vec2(1.7 + time * 0.08, 9.2 - time * 0.06)),
		fbm(warped_position + vec2(8.3 - time * 0.07, 2.8 + time * 0.10))
	);

	float pattern = fbm(warped_position + (secondary_field - 0.5) * distortion);
	float dense_region = smoothstep(dissolve_amount - softness, dissolve_amount + softness, pattern);

	float dissolve_edge = smoothstep(dissolve_amount, dissolve_amount + softness, pattern);
	dissolve_edge *= 1.0 - smoothstep(
		dissolve_amount + dissolve_width,
		dissolve_amount + dissolve_width + softness,
		pattern
	);

	float formation_threshold = mix(1.1, -0.1, formation_amount);
	float formation_position = UV.y + (pattern - 0.5) * 0.16;
	float formed = smoothstep(
		formation_threshold - softness,
		formation_threshold + softness,
		formation_position
	);

	float formation_edge = smoothstep(formation_threshold, formation_threshold + softness, formation_position);
	formation_edge *= 1.0 - smoothstep(
		formation_threshold + dissolve_width,
		formation_threshold + dissolve_width + softness,
		formation_position
	);

	vec3 surface_color = mix(barrier_color.rgb, dissolve_color.rgb, dense_region);
	float luminous_edge = max(dissolve_edge, formation_edge);
	surface_color = mix(surface_color, edge_color.rgb, luminous_edge);

	float surface_alpha = mix(barrier_color.a * 0.3, barrier_color.a, dense_region);
	surface_alpha = max(surface_alpha, dissolve_color.a * dissolve_edge);
	surface_alpha = max(surface_alpha, edge_color.a * formation_edge);

	ALBEDO = surface_color;
	EMISSION = mix(dissolve_color.rgb, edge_color.rgb, formation_edge) * luminous_edge * emission_strength;
	ALPHA = surface_alpha * formed;
}
