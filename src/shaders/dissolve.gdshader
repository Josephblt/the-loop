shader_type canvas_item;


/*
 * COLOR
 *
 * The Label's source font color must be white.
 * The Label's source outline color must be black.
 *
 * The shader replaces those source colors with these colors.
 */
group_uniforms Color;

uniform vec4 font_color : source_color =
	vec4(0.129, 0.094, 0.184, 1.0);

uniform vec4 font_outline : source_color =
	vec4(0.914, 0.871, 1.0, 1.0);

uniform vec4 dissolve_color : source_color =
	vec4(0.663, 0.545, 1.0, 1.0);


/*
 * DISSOLVE
 */
group_uniforms Dissolve;

uniform float dissolve_amount : hint_range(0.0, 1.0) = 0.50;
uniform float dissolve_width : hint_range(0.0, 0.3) = 0.12;
uniform float softness : hint_range(0.001, 0.2) = 0.045;

uniform float noise_scale : hint_range(5.0, 100.0) = 24.0;
uniform float lateral_speed : hint_range(-5.0, 5.0) = 0.45;
uniform float morph_speed : hint_range(0.0, 3.0) = 0.30;
uniform float distortion : hint_range(0.0, 5.0) = 2.0;
uniform float swirl_strength : hint_range(0.0, 5.0) = 1.2;


/*
 * OUTLINE
 */
group_uniforms Outline;

uniform float outline_detection_threshold :
	hint_range(0.0, 1.0) = 0.5;


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

	/*
	 * The source Label uses:
	 *
	 * White = font center
	 * Black = font outline
	 */
	float source_luminance = dot(
		COLOR.rgb,
		vec3(0.299, 0.587, 0.114)
	);

	float is_outline = 1.0 - step(
		outline_detection_threshold,
		source_luminance
	);

	float time = TIME * morph_speed;

	vec2 position = FRAGCOORD.xy / noise_scale;

	// Constant lateral movement.
	position.x -= TIME * lateral_speed;

	/*
	 * First fluid field.
	 *
	 * Both axes evolve independently and continuously.
	 */
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

	/*
	 * Rotate part of the fluid field perpendicular to itself.
	 * This creates curling and swirling rather than plain noise drift.
	 */
	vec2 swirl = vec2(
		-fluid_field.y,
		fluid_field.x
	);

	vec2 warped_position =
		position
		+ fluid_field * distortion
		+ swirl * swirl_strength;

	/*
	 * A second evolving field prevents the motion from looking like
	 * a texture simply sliding across the Label.
	 */
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

	/*
	 * The threshold remains fixed.
	 *
	 * The moving fluid field causes some areas to disappear while
	 * approximately the same amount regenerates elsewhere.
	 */
	float visibility = smoothstep(
		dissolve_amount - softness,
		dissolve_amount + softness,
		pattern
	);

	/*
	 * Soft colored region along the fluid boundary.
	 */
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

	/*
	 * The font center receives the dissolve.
	 * The font outline remains complete and unaffected.
	 */
	vec3 final_color = mix(
		center_color,
		font_outline.rgb,
		is_outline
	);

	float center_alpha =
		visibility * font_color.a;

	float final_alpha = mix(
		center_alpha,
		font_outline.a,
		is_outline
	);

	final_alpha *= texture_sample.a * COLOR.a;

	COLOR = vec4(final_color, final_alpha);
}
