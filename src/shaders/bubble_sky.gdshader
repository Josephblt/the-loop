shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never, shadows_disabled;


group_uniforms SoapFilm;
uniform vec3 film_blue : source_color = vec3(0.784, 0.925, 1.0);
uniform vec3 film_orange : source_color = vec3(1.0, 0.839, 0.639);
uniform vec3 film_purple : source_color = vec3(0.882, 0.8, 1.0);
uniform float film_opacity : hint_range(0.0, 1.0) = 0.12;
uniform float pattern_scale : hint_range(0.1, 10.0) = 1.25;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.08;
uniform float distortion : hint_range(0.0, 4.0) = 0.55;
uniform float interference_cycles : hint_range(0.1, 8.0) = 1.75;
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.16;


varying vec3 sphere_direction;


float random(vec3 position) {
	return fract(sin(dot(position, vec3(127.1, 311.7, 74.7))) * 43758.5453);
}


float value_noise(vec3 position) {
	vec3 cell = floor(position);
	vec3 offset = fract(position);
	vec3 blend = offset * offset * (3.0 - 2.0 * offset);

	float bottom_back = mix(random(cell), random(cell + vec3(1.0, 0.0, 0.0)), blend.x);
	float top_back = mix(random(cell + vec3(0.0, 1.0, 0.0)), random(cell + vec3(1.0, 1.0, 0.0)), blend.x);
	float bottom_front = mix(random(cell + vec3(0.0, 0.0, 1.0)), random(cell + vec3(1.0, 0.0, 1.0)), blend.x);
	float top_front = mix(random(cell + vec3(0.0, 1.0, 1.0)), random(cell + vec3(1.0, 1.0, 1.0)), blend.x);

	float back = mix(bottom_back, top_back, blend.y);
	float front = mix(bottom_front, top_front, blend.y);
	return mix(back, front, blend.z);
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


vec3 interference_color(float thickness) {
	float phase = thickness * interference_cycles * TAU;
	vec3 weights = 0.5 + 0.5 * cos(phase + vec3(0.0, TAU / 3.0, TAU * 2.0 / 3.0));
	float weight_sum = weights.x + weights.y + weights.z;
	return (film_blue * weights.x + film_orange * weights.y + film_purple * weights.z) / weight_sum;
}


void vertex() {
	sphere_direction = normalize(VERTEX);
}


void fragment() {
	vec3 direction = normalize(sphere_direction);
	float time = TIME * flow_speed;
	vec3 position = direction * pattern_scale;

	vec3 flow = vec3(
		fbm(position * 0.5 + vec3(time * 0.31, 0.0, -time * 0.12)),
		fbm(position * 0.5 + vec3(7.3, time * 0.23, 2.1)),
		fbm(position * 0.5 + vec3(-time * 0.15, 3.7, time * 0.27))
	);
	flow = flow * 2.0 - 1.0;

	vec3 warped_position = position + flow * distortion;
	float broad_flow = fbm(warped_position * 0.7 + vec3(time * 0.09, -time * 0.07, time * 0.05));
	float soft_detail = fbm(warped_position * 1.25 - vec3(time * 0.05, time * 0.03, -time * 0.04));
	float thickness = mix(broad_flow, soft_detail, 0.2);

	vec3 highlight_direction = normalize(vec3(-0.45, 0.7, -0.55));
	float highlight = pow(max(dot(direction, highlight_direction), 0.0), 5.0);
	float soft_opacity = smoothstep(0.15, 0.85, thickness);

	ALBEDO = mix(interference_color(thickness), vec3(1.0), highlight * highlight_strength);
	ALPHA = film_opacity * mix(0.45, 1.0, soft_opacity);
	ALPHA += highlight * highlight_strength;
}
