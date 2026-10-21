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
	float moving_noise = fbm(vec2(UV.y * 14.0 - TIME * edge_flow_speed, TIME * 0.45));
	float detail_noise = fbm(vec2(UV.y * 42.0 + TIME * edge_flow_speed * 0.6, TIME * 0.8));
	float inner_boundary = clamp(edge_size + (moving_noise - 0.5) * 0.3, 0.2, 0.96);
	float frame = 1.0 - smoothstep(inner_boundary - edge_softness, inner_boundary + edge_softness, UV.x);
	float outer_fade = smoothstep(0.0, edge_softness * 2.0, UV.x);
	float highlight_distance = abs(UV.x - inner_boundary);
	float highlight = 1.0 - smoothstep(edge_softness, edge_softness * 4.0, highlight_distance);
	float pulse = 0.78 + 0.22 * sin(TIME * edge_pulse_speed + UV.y * 12.0);
	float flow = 0.5 + 0.5 * sin(UV.y * 54.0 - TIME * edge_flow_speed * 8.0 + detail_noise * 7.0);
	vec3 frame_color = barrier_outline.rgb * mix(0.32, 0.58, moving_noise);
	vec3 highlight_color = barrier_outline.rgb * mix(1.15, 1.8, flow);
	vec3 color = mix(frame_color, highlight_color, highlight);
	ALBEDO = color;
	EMISSION = color * edge_intensity * pulse * mix(0.7, 1.25, highlight);
	ALPHA = frame * outer_fade * barrier_outline.a * pulse;
}
