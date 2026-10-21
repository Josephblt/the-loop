shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Color;

uniform vec4 barrier_color : source_color =
	vec4(0.129, 0.094, 0.184, 1.0);

uniform vec4 barrier_outline : source_color =
	vec4(0.914, 0.871, 1.0, 1.0);

uniform vec4 dissolve_color : source_color =
	vec4(0.663, 0.545, 1.0, 1.0);

group_uniforms Dissolve;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.50;
uniform float dissolve_width : hint_range(0.0, 0.3) = 0.12;
uniform float softness : hint_range(0.001, 0.2) = 0.045;

uniform float noise_scale : hint_range(5.0, 100.0) = 24.0;
uniform float lateral_speed : hint_range(-5.0, 5.0) = 0.45;
uniform float morph_speed : hint_range(0.0, 3.0) = 0.30;
uniform float distortion : hint_range(0.0, 5.0) = 2.0;
uniform float swirl_strength : hint_range(0.0, 5.0) = 1.2;

group_uniforms Edge;

uniform sampler2D edge_shape : filter_linear, repeat_disable;
uniform float edge_width : hint_range(0.001, 0.08, 0.001) = 0.02;
uniform float edge_intensity : hint_range(0.0, 8.0, 0.1) = 3.0;
uniform float edge_pulse_speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float edge_flow_speed : hint_range(0.0, 10.0, 0.1) = 4.0;
uniform float edge_vibration : hint_range(0.0, 1.0, 0.01) = 0.35;

varying vec2 local_position;

const vec2 BARRIER_MINIMUM = vec2(-2.5, -0.4);
const vec2 BARRIER_MAXIMUM = vec2(2.8, 5.5);
const float EDGE_SHAPE_PADDING = 0.0625;

float random(vec2 position) {
	return fract(
		sin(dot(position, vec2(127.1, 311.7)))
		* 43758.5453
	);
}

float value_noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 offset = fract(position);

	vec2 blend = offset * offset * (3.0 - 2.0 * offset);

	float bottom_left = random(cell);
	float bottom_right = random(cell + vec2(1.0, 0.0));
	float top_left = random(cell + vec2(0.0, 1.0));
	float top_right = random(cell + vec2(1.0, 1.0));

	return mix(
		mix(bottom_left, bottom_right, blend.x),
		mix(top_left, top_right, blend.x),
		blend.y
	);
}

float fbm(vec2 position) {
	float result = 0.0;
	float amplitude = 0.5;

	for (int octave = 0; octave < 5; octave++) {
		result += value_noise(position) * amplitude;

		position = position * 2.03
			+ vec2(17.1, 9.2);

		amplitude *= 0.5;
	}

	return result / 0.96875;
}

void vertex() {
	local_position = VERTEX.xy;
}

void fragment() {
	float time = TIME * morph_speed;

	vec2 position = local_position * (100.0 / noise_scale);

	position.x -= TIME * lateral_speed;

	vec2 fluid_field = vec2(
		fbm(position * 0.55 + vec2(time * 0.13, time * 0.09)),
		fbm(position * 0.55 + vec2(6.8 - time * 0.11, 3.4 + time * 0.15))
	);

	fluid_field = fluid_field * 2.0 - 1.0;

	vec2 swirl = vec2(-fluid_field.y, fluid_field.x);

	vec2 warped_position =
		position
		+ fluid_field * distortion
		+ swirl * swirl_strength;

	vec2 secondary_field = vec2(
		fbm(warped_position + vec2(1.7 + time * 0.08, 9.2 - time * 0.06)),
		fbm(warped_position + vec2(8.3 - time * 0.07, 2.8 + time * 0.10))
	);

	float pattern = fbm(
		warped_position
		+ (secondary_field - 0.5) * distortion
	);

	float visibility = smoothstep(
		dissolve_amount - softness,
		dissolve_amount + softness,
		pattern
	);

	float dissolve_region = smoothstep(
		dissolve_amount,
		dissolve_amount + softness,
		pattern
	);

	dissolve_region *= 1.0 - smoothstep(
		dissolve_amount + dissolve_width,
		dissolve_amount + dissolve_width + softness,
		pattern
	);

	vec3 center_color = mix(
		barrier_color.rgb,
		dissolve_color.rgb,
		dissolve_region * dissolve_color.a
	);

	vec2 normalized_position = (
		local_position - BARRIER_MINIMUM
	) / (
		BARRIER_MAXIMUM - BARRIER_MINIMUM
	);

	vec2 edge_uv = mix(
		vec2(EDGE_SHAPE_PADDING, 1.0 - EDGE_SHAPE_PADDING),
		vec2(1.0 - EDGE_SHAPE_PADDING, EDGE_SHAPE_PADDING),
		normalized_position
	);

	float vibration = sin(
		TIME * 13.0
		+ local_position.y * 8.0
		+ sin(local_position.x * 11.0 - TIME * 7.0)
	);

	float animated_width = edge_width * (
		1.0 + vibration * edge_vibration
	);

	vec2 horizontal = vec2(animated_width, 0.0);
	vec2 vertical = vec2(0.0, animated_width);
	vec2 diagonal = vec2(animated_width);
	float nearest_shape = min(
		min(texture(edge_shape, edge_uv + horizontal).r, texture(edge_shape, edge_uv - horizontal).r),
		min(texture(edge_shape, edge_uv + vertical).r, texture(edge_shape, edge_uv - vertical).r)
	);

	nearest_shape = min(
		nearest_shape,
		min(
			min(texture(edge_shape, edge_uv + diagonal).r, texture(edge_shape, edge_uv - diagonal).r),
			min(
				texture(edge_shape, edge_uv + vec2(animated_width, -animated_width)).r,
				texture(edge_shape, edge_uv + vec2(-animated_width, animated_width)).r
			)
		)
	);

	float edge = texture(edge_shape, edge_uv).r * (1.0 - nearest_shape);
	float pulse = 0.5 + 0.5 * sin(
		TIME * edge_pulse_speed
		+ local_position.y * 3.0
		+ local_position.x * 1.7
	);

	float moving_energy = 0.5 + 0.5 * sin(
		TIME * edge_flow_speed
		- local_position.y * 2.3
		+ local_position.x * 4.1
	);

	float edge_energy = edge * edge_intensity * mix(0.5, 1.0, pulse) * mix(0.7, 1.0, moving_energy);

	ALBEDO = mix(center_color, barrier_outline.rgb, edge);
	EMISSION = barrier_outline.rgb * edge_energy;
	ALPHA = max(visibility * barrier_color.a, edge * barrier_outline.a * mix(0.6, 1.0, pulse));
}
