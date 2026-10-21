shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Color;

uniform vec4 barrier_color : source_color = vec4(0.094, 0.043, 0.161, 0.58);
uniform vec4 dissolve_color : source_color = vec4(0.459, 0.322, 0.620, 0.9);
uniform vec4 edge_color : source_color = vec4(0.882, 0.8, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 8.0) = 2.5;
uniform float edge_width : hint_range(0.001, 0.5) = 0.08;
uniform float edge_pulse_speed : hint_range(0.0, 20.0) = 7.0;
uniform float edge_pulse_frequency : hint_range(0.0, 10.0) = 3.0;
uniform float edge_vibration_speed : hint_range(0.0, 10.0) = 2.5;
uniform float edge_vibration_strength : hint_range(0.0, 0.2) = 0.045;

group_uniforms Dissolve;

uniform float formation_amount : hint_range(0.0, 1.0) = 1.0;
uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.50;
uniform float dissolve_width : hint_range(0.0, 0.3) = 0.12;
uniform float softness : hint_range(0.001, 0.2) = 0.045;
uniform float noise_scale : hint_range(5.0, 100.0) = 24.0;
uniform float lateral_speed : hint_range(-5.0, 5.0) = 0.45;
uniform float morph_speed : hint_range(0.0, 3.0) = 0.30;
uniform float distortion : hint_range(0.0, 5.0) = 2.0;
uniform float swirl_strength : hint_range(0.0, 5.0) = 1.2;

varying vec2 local_position;

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

float segment_distance(vec2 position, vec2 start, vec2 end) {
	vec2 segment = end - start;
	float weight = clamp(dot(position - start, segment) / dot(segment, segment), 0.0, 1.0);
	return distance(position, start + segment * weight);
}

float gate_edge_distance(vec2 position) {
	vec2 point_0 = vec2(-1.5, 0.0);
	vec2 point_1 = vec2(-1.5, 0.8);
	vec2 point_2 = vec2(-1.9, 2.0);
	vec2 point_3 = vec2(-1.9, 4.5);
	vec2 point_4 = vec2(-0.8, 5.9);
	vec2 point_5 = vec2(0.8, 5.9);
	vec2 point_6 = vec2(1.9, 4.5);
	vec2 point_7 = vec2(1.9, 2.0);
	vec2 point_8 = vec2(1.5, 0.8);
	vec2 point_9 = vec2(1.5, 0.0);

	float result = segment_distance(position, point_0, point_1);
	result = min(result, segment_distance(position, point_1, point_2));
	result = min(result, segment_distance(position, point_2, point_3));
	result = min(result, segment_distance(position, point_3, point_4));
	result = min(result, segment_distance(position, point_4, point_5));
	result = min(result, segment_distance(position, point_5, point_6));
	result = min(result, segment_distance(position, point_6, point_7));
	result = min(result, segment_distance(position, point_7, point_8));
	result = min(result, segment_distance(position, point_8, point_9));
	return min(result, segment_distance(position, point_9, point_0));
}

void vertex() {
	local_position = VERTEX.xy;
}

void fragment() {
	float time = TIME * morph_speed;
	vec2 position = FRAGCOORD.xy / noise_scale;
	position.x -= TIME * lateral_speed;

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
	float visibility = smoothstep(
		dissolve_amount - softness,
		dissolve_amount + softness,
		pattern
	);

	float dissolve_region = smoothstep(dissolve_amount, dissolve_amount + softness, pattern);
	dissolve_region *= 1.0 - smoothstep(
		dissolve_amount + dissolve_width,
		dissolve_amount + dissolve_width + softness,
		pattern
	);

	vec2 gate_uv = vec2((local_position.x + 1.9) / 3.8, 1.0 - local_position.y / 5.9);
	float formation_threshold = mix(1.1, -0.1, formation_amount);
	float formation_position = gate_uv.y + (pattern - 0.5) * 0.16;
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
	formation_edge *= 1.0 - smoothstep(0.92, 1.0, formation_amount);

	vec2 vibration_position = local_position * vec2(2.8, 1.9);
	vibration_position += vec2(TIME * edge_vibration_speed, -TIME * edge_vibration_speed * 0.73);
	float vibration = (fbm(vibration_position) - 0.5) * edge_vibration_strength;
	float perimeter_distance = gate_edge_distance(local_position) + vibration;
	float perimeter_edge = 1.0 - smoothstep(edge_width, edge_width + softness, perimeter_distance);
	perimeter_edge *= formed;

	float edge_pulse = 0.5 + 0.5 * sin(
		TIME * edge_pulse_speed
		+ local_position.y * edge_pulse_frequency
		+ pattern * TAU
	);
	float edge_energy = mix(0.45, 1.0, edge_pulse);

	vec3 center_color = mix(barrier_color.rgb, dissolve_color.rgb, dissolve_region * dissolve_color.a);
	float boundary = max(formation_edge, perimeter_edge);
	vec3 final_color = mix(center_color, edge_color.rgb, boundary);
	float center_alpha = visibility * barrier_color.a;
	float final_alpha = max(center_alpha, edge_color.a * boundary);

	ALBEDO = final_color;
	EMISSION = edge_color.rgb * perimeter_edge * edge_energy * emission_strength;
	EMISSION += dissolve_color.rgb * formation_edge * emission_strength;
	ALPHA = final_alpha * formed;
}
