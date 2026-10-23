shader_type canvas_item;

uniform float rim_blur : hint_range(0.0, 4.0) = 2.0;

const int MAX_BLUR_RADIUS = 8;


float gaussian_weight(float offset, float sigma) {
	return exp(-(offset * offset) / (2.0 * sigma * sigma));
}

void fragment() {
	float blurred_alpha = texture(TEXTURE, UV).a;

	if (rim_blur > 0.001) {
		float weighted_alpha = blurred_alpha;
		float total_weight = 1.0;
		float sigma = max(rim_blur, 0.35);

		for (int offset = 1; offset <= MAX_BLUR_RADIUS; offset++) {
			float weight = gaussian_weight(float(offset), sigma);
			vec2 sample_offset = vec2(TEXTURE_PIXEL_SIZE.x * float(offset), 0.0);
			weighted_alpha += texture(TEXTURE, UV - sample_offset).a * weight;
			weighted_alpha += texture(TEXTURE, UV + sample_offset).a * weight;
			total_weight += weight * 2.0;
		}

		blurred_alpha = weighted_alpha / total_weight;
	}

	COLOR = vec4(vec3(1.0), blurred_alpha);
}
