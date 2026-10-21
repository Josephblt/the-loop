shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_never, shadows_disabled;

group_uniforms Color;

uniform vec4 barrier_outline : source_color =
	vec4(0.914, 0.871, 1.0, 1.0);

group_uniforms Edge;

uniform float edge_size : hint_range(0.0, 1.0, 0.01) = 0.82;
uniform float edge_softness : hint_range(0.001, 0.2, 0.001) = 0.035;
uniform float edge_intensity : hint_range(0.0, 8.0, 0.1) = 2.0;
uniform float edge_pulse_speed : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float edge_flow_speed : hint_range(0.0, 10.0, 0.1) = 0.8;
uniform float edge_vibration : hint_range(0.0, 0.1, 0.001) = 0.018;

float random(vec2 position) {
	return fract(sin(dot(position, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 offset = fract(position);
	vec2 blend = offset * offset * (3.0 - 2.0 * offset);
	float bottom = mix(random(cell), random(cell + vec2(1.0, 0.0)), blend.x);
	float top = mix(random(cell + vec2(0.0, 1.0)), random(cell + vec2(1.0)), blend.x);
	return mix(bottom, top, blend.y);
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

void vertex() {
	float movement = fbm(vec2(UV.y * 16.0 - TIME * edge_flow_speed, TIME * 0.35)) * 2.0 - 1.0;
	float vibration = sin(UV.y * 90.0 + TIME * edge_flow_speed * 10.0);
	vec2 outward = UV2 * 2.0 - 1.0;
	VERTEX.xy += outward * (movement + vibration * 0.4) * edge_vibration;
}

void fragment() {
	float time = TIME * edge_flow_speed;
	vec2 flowing_uv = vec2(UV.y * 12.0 - time * 0.35, UV.x * 3.0 + time * 0.18);
	float moving_noise = fbm(flowing_uv);
	float detail_noise = fbm(flowing_uv * 2.7 + vec2(time * 0.24, -time * 0.31));
	float inner_boundary = clamp(edge_size + (moving_noise - 0.5) * 0.34 + (detail_noise - 0.5) * 0.12, 0.28, 0.98);
	float frame = 1.0 - smoothstep(inner_boundary - edge_softness, inner_boundary + edge_softness, UV.x);
	float outer_fade = smoothstep(0.0, edge_softness * 3.0, UV.x);
	float turbulent_energy = fbm(vec2(UV.y * 30.0 + time * 0.4, UV.x * 7.0 - time));
	float pulse = 0.86 + 0.14 * sin(TIME * edge_pulse_speed + UV.y * 10.0);
	float frame_gradient = smoothstep(0.0, inner_boundary, UV.x);
	frame_gradient *= mix(0.82, 1.0, turbulent_energy) * pulse;
	vec3 frame_color = pow(barrier_outline.rgb, vec3(3.0)) * 0.55;
	vec3 highlight_color = pow(barrier_outline.rgb, vec3(1.5)) * 0.9;
	vec3 color = mix(frame_color, highlight_color, frame_gradient);
	ALBEDO = color;
	EMISSION = color * edge_intensity * mix(0.1, 0.32, frame_gradient);
	ALPHA = frame * outer_fade * barrier_outline.a;
}
