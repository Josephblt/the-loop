shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(0.92, 0.82, 1.0, 1.0);
uniform vec4 halo_color : source_color = vec4(0.48, 0.18, 1.0, 0.55);
uniform float core_width : hint_range(1.0, 8.0) = 2.0;
uniform float halo_width : hint_range(2.0, 24.0) = 10.0;
uniform float pulse_speed : hint_range(0.0, 8.0) = 2.2;
uniform float pulse_strength : hint_range(0.0, 1.0) = 0.22;

void fragment() {
	float center = texture(TEXTURE, UV).a;
	float core_mask = 0.0;
	float halo_mask = 0.0;

	for (int index = 0; index < 16; index++) {
		float angle = float(index) * 0.3926991;
		vec2 direction = vec2(cos(angle), sin(angle));
		core_mask = max(core_mask, texture(TEXTURE, UV + direction * TEXTURE_PIXEL_SIZE * core_width).a);
		halo_mask = max(halo_mask, texture(TEXTURE, UV + direction * TEXTURE_PIXEL_SIZE * halo_width).a);
	}

	core_mask = max(core_mask - center, 0.0);
	halo_mask = max(halo_mask - center, 0.0) * (1.0 - core_mask);

	float pulse = 1.0 - pulse_strength;
	pulse += pulse_strength * (0.5 + 0.5 * sin(TIME * pulse_speed + UV.y * 19.0));
	float alpha = core_mask * core_color.a + halo_mask * halo_color.a * pulse;
	vec3 color = mix(halo_color.rgb, core_color.rgb, core_mask);

	COLOR = vec4(color, alpha);
}
