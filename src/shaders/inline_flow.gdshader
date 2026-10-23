shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(0.92, 0.82, 1.0, 1.0);
uniform sampler2D visibility_texture : filter_nearest;
uniform float rim_width : hint_range(0.01, 1.5) = 0.24;

const float LOCAL_PIXEL_ENCODING_SCALE = 8.0;


float mask_value(vec3 mask_color) {
	return step(0.9, mask_color.r) * step(mask_color.g, 0.8) * step(0.9, mask_color.b);
}

void fragment() {
	vec3 center_color = texture(TEXTURE, UV).rgb;
	vec3 visibility_color = texture(visibility_texture, UV).rgb;
	float center = mask_value(center_color);
	float visibility = mask_value(visibility_color);
	float local_pixel_size = max(center_color.g / LOCAL_PIXEL_ENCODING_SCALE, 0.0001);
	float rim_radius = rim_width / local_pixel_size;
	float interior = 1.0;

	for (int index = 0; index < 16; index++) {
		float angle = float(index) * 0.3926991;
		vec2 direction = vec2(cos(angle), sin(angle));
		vec3 sample_color = texture(TEXTURE, UV + direction * TEXTURE_PIXEL_SIZE * rim_radius).rgb;
		interior = min(interior, mask_value(sample_color));
	}

	float rim = max(center - interior, 0.0) * visibility;
	COLOR = vec4(rim_color.rgb, rim);
}
