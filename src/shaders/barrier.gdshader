shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Color;

uniform vec4 font_color : source_color =
	vec4(0.129, 0.094, 0.184, 1.0);

uniform vec4 font_outline : source_color =
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

varying vec2 local_position;
varying vec2 portal_position;
varying float rim_surface;

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
	portal_position = VERTEX.xy;
	rim_surface = 1.0 - smoothstep(0.1, 0.9, abs(NORMAL.z));

	vec2 outward = NORMAL.xy / max(length(NORMAL.xy), 0.0001);
	float first_vibration = sin(TIME * 13.0 + VERTEX.y * 7.0 + VERTEX.x * 3.0);
	float second_vibration = sin(TIME * 19.0 - VERTEX.y * 4.0 + VERTEX.x * 9.0);
	float vibration = (first_vibration + second_vibration) * 0.006;
	VERTEX.xy += outward * vibration * rim_surface;
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
		font_color.rgb,
		dissolve_color.rgb,
		dissolve_region * dissolve_color.a
	);

	float pulse = 0.5 + 0.5 * sin(
		TIME * 6.0
		+ portal_position.y * 3.0
		+ portal_position.x * 1.7
	);

	float moving_energy = 0.5 + 0.5 * sin(
		TIME * 9.0
		- portal_position.y * 2.3
		+ portal_position.x * 4.1
	);

	float rim_energy = rim_surface * mix(0.5, 1.0, pulse) * mix(0.7, 1.0, moving_energy);

	ALBEDO = mix(center_color, font_outline.rgb, rim_surface);
	EMISSION = font_outline.rgb * rim_energy * 3.0;
	ALPHA = mix(visibility * font_color.a, font_outline.a * mix(0.6, 1.0, pulse), rim_surface);
}
