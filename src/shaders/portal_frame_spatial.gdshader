shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Shape;

uniform sampler2D portal_shape_sdf : filter_linear, repeat_disable;
uniform float edge_min_width : hint_range(0.0, 0.5, 0.005) = 0.025;
uniform float edge_max_width : hint_range(0.0, 0.5, 0.005) = 0.075;
uniform float edge_pulse_speed : hint_range(0.0, 4.0, 0.05) = 1.0;
uniform float edge_blur : hint_range(0.001, 0.25, 0.001) = 0.01;

group_uniforms Highlight;

uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform float highlight_width : hint_range(0.0, 0.5, 0.005) = 0.16;
uniform float highlight_noise : hint_range(0.0, 0.25, 0.005) = 0.08;
uniform float highlight_softness : hint_range(0.001, 0.1, 0.001) = 0.01;

group_uniforms Color;

uniform vec4 portal_frame_color : source_color = vec4(0.094, 0.043, 0.161, 1.0);
uniform vec4 portal_highlight_color : source_color = vec4(0.459, 0.322, 0.620, 1.0);

instance uniform float activation = 0.0;

vec2 rotate_uv(vec2 uv, float angle) {
	float sine = sin(angle);
	float cosine = cos(angle);
	mat2 rotation = mat2(vec2(cosine, -sine), vec2(sine, cosine));
	return rotation * (uv - vec2(0.5)) + vec2(0.5);
}

void fragment() {
	float shape_distance = texture(portal_shape_sdf, UV).r;

	vec2 noise_uv = rotate_uv(UV, TIME * 0.45);
	noise_uv += vec2(TIME * 0.1, -TIME * 0.1);
	float noise_value = texture(noise_texture, noise_uv).r;

	float edge_pulse = sin(TIME * edge_pulse_speed * 6.28318530718) * 0.5 + 0.5;
	float pulsed_edge_width = mix(edge_min_width, max(edge_min_width, edge_max_width), edge_pulse);
	float frame_end = 0.5 + pulsed_edge_width;
	float frame_mask = 1.0 - smoothstep(frame_end - edge_blur, frame_end + edge_blur, shape_distance);
	float noisy_highlight_width = highlight_width + noise_value * highlight_noise;
	float highlight_end = frame_end + noisy_highlight_width;
	float highlight_mask = 1.0 - smoothstep(highlight_end - highlight_softness, highlight_end + highlight_softness, shape_distance);
	highlight_mask *= 1.0 - frame_mask;

	float frame_alpha = frame_mask * portal_frame_color.a;
	float highlight_alpha = highlight_mask * portal_highlight_color.a;
	float overlay_alpha = max(frame_alpha, highlight_alpha) * activation;
	vec3 overlay_color = mix(portal_highlight_color.rgb, portal_frame_color.rgb, frame_mask);

	ALBEDO = overlay_color;
	EMISSION = overlay_color;
	ALPHA = overlay_alpha;
}
