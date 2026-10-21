shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 font_outline : source_color =
	vec4(0.914, 0.871, 1.0, 1.0);

varying vec2 portal_position;

void vertex() {
	portal_position = VERTEX.xy;

	float horizontal_vibration = sin(
		TIME * 13.0
		+ VERTEX.y * 7.0
		+ VERTEX.x * 3.0
	);

	float vertical_vibration = sin(
		TIME * 19.0
		- VERTEX.y * 4.0
		+ VERTEX.x * 9.0
	);

	VERTEX.xy += vec2(horizontal_vibration, vertical_vibration) * 0.012;
}

void fragment() {
	float pulse = 0.5 + 0.5 * sin(
		TIME * 6.0
		+ portal_position.y * 3.0
		+ portal_position.x * 1.7
	);

	ALBEDO = font_outline.rgb;
	EMISSION = font_outline.rgb * mix(1.5, 3.5, pulse);
	ALPHA = font_outline.a * mix(0.45, 1.0, pulse);
}
