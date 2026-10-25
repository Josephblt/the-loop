shader_type canvas_item;

group_uniforms Dissolve;

uniform vec4 color_1 : source_color = vec4(0.09411765, 0.043137256, 0.16078432, 1.0);
uniform vec4 color_2 : source_color = vec4(0.45882353, 0.32156864, 0.61960787, 1.0);
uniform float amount : hint_range(0.0, 1.0) = 0.25;
uniform float width : hint_range(0.0, 0.3) = 0.25;
uniform float softness : hint_range(0.001, 0.2) = 0.2;
uniform float noise_scale : hint_range(5.0, 100.0) = 45.0;
uniform float lateral_speed : hint_range(-5.0, 5.0) = 0.5;
uniform float morph_speed : hint_range(0.0, 3.0) = 2.5;
uniform float distortion : hint_range(0.0, 5.0) = 2.5;
uniform float swirl_strength : hint_range(0.0, 5.0) = 3.0;

group_uniforms Outline;

uniform vec4 color_3 : source_color = vec4(0.88235295, 0.8, 1.0, 1.0);
uniform float detection_threshold : hint_range(0.0, 1.0) = 0.5;

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

void fragment() {
	vec4 texture_sample = texture(TEXTURE, UV);

	float source_luminance = dot(
		COLOR.rgb,
		vec3(0.299, 0.587, 0.114)
	);

	float border_mask = 1.0 - step(
		detection_threshold,
		source_luminance
	);

	float time = TIME * morph_speed;

	vec2 position = FRAGCOORD.xy / noise_scale;

	position.x -= TIME * lateral_speed;

	
	vec2 fluid_field = vec2(
		fbm(
			position * 0.55
			+ vec2(
				time * 0.13,
				time * 0.09
			)
		),
		fbm(
			position * 0.55
			+ vec2(
				6.8 - time * 0.11,
				3.4 + time * 0.15
			)
		)
	);

	fluid_field = fluid_field * 2.0 - 1.0;

	vec2 swirl = vec2(
		-fluid_field.y,
		fluid_field.x
	);

	vec2 warped_position =
		position
		+ fluid_field * distortion
		+ swirl * swirl_strength;

	vec2 secondary_field = vec2(
		fbm(
			warped_position
			+ vec2(
				1.7 + time * 0.08,
				9.2 - time * 0.06
			)
		),
		fbm(
			warped_position
			+ vec2(
				8.3 - time * 0.07,
				2.8 + time * 0.10
			)
		)
	);

	float pattern = fbm(
		warped_position
		+ (secondary_field - 0.5) * distortion
	);

	float visibility = smoothstep(
		amount - softness,
		amount + softness,
		pattern
	);

	float region = smoothstep(
		amount,
		amount + softness,
		pattern
	);

	region *= 1.0 - smoothstep(
		amount + width,
		amount + width + softness,
		pattern
	);

	vec3 center_color = mix(
		color_1.rgb,
		color_2.rgb,
		region * color_2.a
	);

	vec3 final_color = mix(
		center_color,
		color_3.rgb,
		border_mask
	);

	float center_alpha =
		visibility * color_1.a;

	float final_alpha = mix(
		center_alpha,
		color_3.a,
		border_mask
	);

	final_alpha *= texture_sample.a * COLOR.a;

	COLOR = vec4(final_color, final_alpha);
}
