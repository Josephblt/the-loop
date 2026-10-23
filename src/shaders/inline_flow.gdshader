shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(0.92, 0.82, 1.0, 1.0);
uniform sampler2D visibility_texture : filter_nearest;
uniform float rim_width : hint_range(0.01, 1.5) = 0.24;
uniform float rim_blur : hint_range(0.0, 4.0) = 2.0;

const int MAX_BLUR_RADIUS = 8;


float mask_value(vec3 mask_color) {
	return step(0.9, mask_color.r) * step(mask_color.g, 0.8) * step(0.9, mask_color.b);
}

float gaussian_weight(float offset, float sigma) {
	return exp(-(offset * offset) / (2.0 * sigma * sigma));
}

void fragment() {
	float visibility = mask_value(texture(visibility_texture, UV).rgb);
	float rim = texture(TEXTURE, UV).a;

	if (rim_blur > 0.001) {
		float weighted_alpha = rim;
		float total_weight = 1.0;
		float sigma = max(rim_blur, 0.35);

		for (int offset = 1; offset <= MAX_BLUR_RADIUS; offset++) {
			float weight = gaussian_weight(float(offset), sigma);
			vec2 sample_offset = vec2(0.0, TEXTURE_PIXEL_SIZE.y * float(offset));
			weighted_alpha += texture(TEXTURE, UV - sample_offset).a * weight;
			weighted_alpha += texture(TEXTURE, UV + sample_offset).a * weight;
			total_weight += weight * 2.0;
		}

		rim = weighted_alpha / total_weight;
	}

	rim *= visibility * step(0.001, rim_width);
	COLOR = vec4(rim_color.rgb, rim);
}
