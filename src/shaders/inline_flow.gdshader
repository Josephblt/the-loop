shader_type canvas_item;

uniform vec4 rim_color : source_color = vec4(0.92, 0.82, 1.0, 1.0);
uniform sampler2D visibility_texture : filter_nearest;
uniform float rim_width : hint_range(0.01, 1.5) = 0.24;
uniform float rim_blur : hint_range(0.0, 1.0) = 0.12;

const float LOCAL_PIXEL_ENCODING_SCALE = 8.0;
const float GOLDEN_ANGLE = 2.39996323;


float mask_value(vec3 mask_color) {
	return step(0.9, mask_color.r) * step(mask_color.g, 0.8) * step(0.9, mask_color.b);
}

float hard_rim(sampler2D mask_texture, vec2 pixel_size, vec2 uv, float radius) {
	float center = mask_value(texture(mask_texture, uv).rgb);
	float interior = 1.0;

	for (int index = 0; index < 8; index++) {
		float angle = float(index) * TAU / 8.0;
		vec2 direction = vec2(cos(angle), sin(angle));
		vec3 sample_color = texture(mask_texture, uv + direction * pixel_size * radius).rgb;
		interior = min(interior, mask_value(sample_color));
	}

	return max(center - interior, 0.0);
}

float blurred_rim(sampler2D mask_texture, vec2 pixel_size, vec2 uv, float rim_radius, float blur_radius) {
	float weighted_rim = hard_rim(mask_texture, pixel_size, uv, rim_radius);
	float total_weight = 1.0;

	for (int index = 0; index < 8; index++) {
		float sample_fraction = (float(index) + 0.5) / 8.0;
		float sample_radius = sqrt(sample_fraction) * blur_radius;
		float angle = float(index) * GOLDEN_ANGLE;
		vec2 direction = vec2(cos(angle), sin(angle));
		vec2 offset = direction * pixel_size * sample_radius;
		float weight = exp(-2.5 * sample_fraction);
		weighted_rim += hard_rim(mask_texture, pixel_size, uv + offset, rim_radius) * weight;
		weighted_rim += hard_rim(mask_texture, pixel_size, uv - offset, rim_radius) * weight;
		total_weight += weight * 2.0;
	}

	return weighted_rim / total_weight;
}

void fragment() {
	vec3 center_color = texture(TEXTURE, UV).rgb;
	vec3 visibility_color = texture(visibility_texture, UV).rgb;
	float visibility = mask_value(visibility_color);
	float local_pixel_size = max(center_color.g / LOCAL_PIXEL_ENCODING_SCALE, 0.0001);
	float rim_radius = rim_width / local_pixel_size;
	float blur_radius = rim_blur / local_pixel_size;
	float rim = 0.0;

	if (visibility > 0.0) {
		rim = blurred_rim(TEXTURE, TEXTURE_PIXEL_SIZE, UV, rim_radius, blur_radius);
	}

	COLOR = vec4(rim_color.rgb, rim);
}
