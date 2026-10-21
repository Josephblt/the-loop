shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Color;

uniform vec4 barrier_outline : source_color =
	vec4(0.914, 0.871, 1.0, 1.0);

group_uniforms Edge;

uniform float edge_size : hint_range(0.0, 1.0, 0.01) = 0.65;
uniform float edge_softness : hint_range(0.001, 0.2, 0.001) = 0.04;
uniform float edge_intensity : hint_range(0.0, 8.0, 0.1) = 3.0;
uniform float edge_pulse_speed : hint_range(0.0, 10.0, 0.1) = 3.0;
uniform float edge_flow_speed : hint_range(0.0, 10.0, 0.1) = 2.0;
uniform float edge_vibration : hint_range(0.0, 0.1, 0.001) = 0.025;

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
	float movement = fbm(vec2(UV.y * 24.0 - TIME * edge_flow_speed, TIME * 0.4)) * 2.0 - 1.0;
	float vibration = sin(UV.y * 120.0 + TIME * edge_flow_speed * 8.0);
	VERTEX.xy += NORMAL.xy * (movement + vibration * 0.35) * edge_vibration * (1.0 - UV.x);
}

void fragment() {
	float moving_noise = fbm(vec2(UV.y * 28.0 - TIME * edge_flow_speed, TIME * 0.5));
	float animated_size = clamp(edge_size + (moving_noise - 0.5) * 0.25, 0.0, 1.0);
	float frame = 1.0 - smoothstep(animated_size - edge_softness, animated_size + edge_softness, UV.x);
	float pulse = 0.7 + 0.3 * sin(TIME * edge_pulse_speed + UV.y * 18.0);
	float flow = 0.65 + 0.35 * sin(UV.y * 80.0 - TIME * edge_flow_speed * 6.0 + moving_noise * 8.0);
	vec3 color = barrier_outline.rgb * mix(0.75, 1.25, flow);
	ALBEDO = color;
	EMISSION = color * edge_intensity * pulse;
	ALPHA = frame * barrier_outline.a * pulse;
}
