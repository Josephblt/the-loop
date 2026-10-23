shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(0.92, 0.82, 1.0, 1.0);
uniform sampler2D visibility_texture : filter_nearest;
uniform float rim_width : hint_range(0.01, 1.5) = 0.24;
uniform float rim_roundness : hint_range(0.05, 2.0) = 0.75;

const float LOCAL_PIXEL_ENCODING_SCALE = 8.0;


float mask_value(vec3 mask_color) {
	return step(0.9, mask_color.r) * step(mask_color.g, 0.8) * step(0.9, mask_color.b);
}

float rounded_coverage(sampler2D mask_texture, vec2 pixel_size, vec2 uv, float radius) {
	float coverage = mask_value(texture(mask_texture, uv).rgb) * 8.0;

	for (int index = 0; index < 12; index++) {
		float angle = float(index) * TAU / 12.0;
		vec2 direction = vec2(cos(angle), sin(angle));
		coverage += mask_value(texture(mask_texture, uv + direction * pixel_size * radius * 0.33).rgb) * 3.0;
		coverage += mask_value(texture(mask_texture, uv + direction * pixel_size * radius * 0.66).rgb) * 2.0;
		coverage += mask_value(texture(mask_texture, uv + direction * pixel_size * radius).rgb);
	}

	return coverage / 80.0;
}

void fragment() {
	vec3 center_color = texture(TEXTURE, UV).rgb;
	vec3 visibility_color = texture(visibility_texture, UV).rgb;
	float center = mask_value(center_color);
	float visibility = mask_value(visibility_color);
	float local_pixel_size = max(center_color.g / LOCAL_PIXEL_ENCODING_SCALE, 0.0001);
	float roundness_radius = rim_roundness / local_pixel_size;
	float coverage = rounded_coverage(TEXTURE, TEXTURE_PIXEL_SIZE, UV, roundness_radius);
	float contour_level = 0.62;
	float field_width = clamp(rim_width / rim_roundness * 0.35, 0.015, 0.3);
	float feather = min(0.035, field_width * 0.4);
	float outer_edge = smoothstep(contour_level - feather, contour_level + feather, coverage);
	float inner_edge = smoothstep(contour_level + field_width - feather, contour_level + field_width + feather, coverage);
	float rim = max(outer_edge - inner_edge, 0.0) * center * visibility;
	COLOR = vec4(rim_color.rgb, rim);
}
