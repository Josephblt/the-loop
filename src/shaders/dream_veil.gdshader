shader_type canvas_item;
render_mode unshaded;


uniform sampler2D screen_texture :
	hint_screen_texture,
	repeat_disable,
	filter_linear_mipmap;

uniform float intensity : hint_range(0.0, 1.0) = 1.0;

group_uniforms Dream;
uniform float pattern_scale : hint_range(0.1, 10.0) = 8.0;
uniform float flow_speed : hint_range(0.0, 2.0) = 2.0;
uniform float morph_speed : hint_range(0.0, 2.0) = 2.0;
uniform float distortion_pixels : hint_range(0.0, 16.0) = 16.0;
uniform float blur_lod : hint_range(0.0, 5.0) = 5.0;
uniform float center_calm : hint_range(0.0, 1.0) = 1.0;

group_uniforms Grade;
uniform float dim : hint_range(0.0, 1.0) = 0.0;
uniform float desaturation : hint_range(0.0, 1.0) = 0.2;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.25;


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

	return mix(
		mix(
			random(cell),
			random(cell + vec2(1.0, 0.0)),
			blend.x
		),
		mix(
			random(cell + vec2(0.0, 1.0)),
			random(cell + vec2(1.0, 1.0)),
			blend.x
		),
		blend.y
	);
}


float fbm(vec2 position) {
	float result = 0.0;
	float amplitude = 0.5;

	for (int octave = 0; octave < 4; octave++) {
		result += value_noise(position) * amplitude;
		position = position * 2.03 + vec2(17.1, 9.2);
		amplitude *= 0.5;
	}

	return result / 0.9375;
}


void fragment() {
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	float aspect_ratio = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;

	vec2 position = centered_uv;
	position.x *= aspect_ratio;
	position *= pattern_scale;

	float flow_time = TIME * flow_speed;
	float morph_time = TIME * morph_speed;

	vec2 first_warp = vec2(
		fbm(position * 0.55 + vec2(flow_time, morph_time * 0.73)),
		fbm(position * 0.55 + vec2(5.2 - morph_time * 0.61, flow_time * 0.47))
	);

	first_warp = first_warp * 2.0 - 1.0;

	vec2 curl = vec2(-first_warp.y, first_warp.x);
	vec2 warped_position = position + first_warp * 1.35 + curl * 0.8;

	vec2 second_warp = vec2(
		fbm(warped_position + vec2(1.7 + morph_time * 0.19, 9.2)),
		fbm(warped_position + vec2(8.3, 2.8 - morph_time * 0.17))
	);

	vec2 flow = (second_warp * 2.0 - 1.0) + curl * 0.35;
	float fluid_pattern = fbm(warped_position + second_warp * 1.4);

	float distance_from_center = length(centered_uv);
	float peripheral_weight = smoothstep(0.0, 0.85, distance_from_center);
	float calm_weight = mix(1.0, peripheral_weight, center_calm);

	vec2 distorted_uv = SCREEN_UV;
	distorted_uv += flow
		* SCREEN_PIXEL_SIZE
		* distortion_pixels
		* calm_weight
		* intensity;
	distorted_uv = clamp(distorted_uv, vec2(0.0), vec2(1.0));

	float local_blur = blur_lod
		* mix(0.35, 1.0, fluid_pattern)
		* calm_weight
		* intensity;

	vec4 screen = textureLod(
		screen_texture,
		distorted_uv,
		local_blur
	);

	float luminance = dot(screen.rgb, vec3(0.299, 0.587, 0.114));
	screen.rgb = mix(
		screen.rgb,
		vec3(luminance),
		desaturation * intensity
	);

	screen.rgb *= 1.0 - dim * intensity;

	float vignette = smoothstep(0.1, 1.25, distance_from_center);
	screen.rgb *= 1.0
		- vignette
		* vignette_strength
		* intensity;

	COLOR = screen;
}
