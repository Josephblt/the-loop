shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, shadows_disabled;

group_uniforms Edge;

uniform sampler2D portal_shape_sdf : filter_linear, repeat_disable;
uniform vec4 color_1 : source_color = vec4(0.88235295, 0.8, 1.0, 1.0);
uniform float min_width : hint_range(0.0, 0.5, 0.005) = 0.1;
uniform float max_width : hint_range(0.0, 0.5, 0.005) = 0.25;
uniform float pulse_speed : hint_range(0.0, 4.0, 0.05) = 1.0;
uniform float blur : hint_range(0.001, 0.25, 0.001) = 0.25;

group_uniforms Highlight;

uniform sampler2D noise_texture : repeat_enable, filter_linear;
uniform vec4 color_2 : source_color = vec4(0.45882353, 0.32156864, 0.61960787, 1.0);
uniform float width : hint_range(0.0, 0.5, 0.005) = 0.25;
uniform float noise : hint_range(0.0, 0.25, 0.005) = 0.25;
uniform float softness : hint_range(0.001, 0.1, 0.001) = 0.1;


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

	float edge_pulse = sin(TIME * pulse_speed * 6.28318530718) * 0.5 + 0.5;
	float pulsed_edge_width = mix(min_width, max(min_width, max_width), edge_pulse);
	float frame_end = 0.5 + pulsed_edge_width;
	float frame_mask = 1.0 - smoothstep(frame_end - blur, frame_end + blur, shape_distance);
	float noisy_highlight_width = max(width - noise_value * noise, 0.0);
	float highlight_end = frame_end + noisy_highlight_width;
	float highlight_mask = 1.0 - smoothstep(highlight_end - softness, highlight_end + softness, shape_distance);

	float frame_alpha = frame_mask * color_1.a;
	float highlight_alpha = highlight_mask * color_2.a;
	float overlay_alpha = frame_alpha + highlight_alpha * (1.0 - frame_alpha);
	vec3 overlay_color = color_1.rgb * frame_alpha;
	overlay_color += color_2.rgb * highlight_alpha * (1.0 - frame_alpha);
	overlay_color /= max(overlay_alpha, 0.0001);

	ALBEDO = overlay_color;
	EMISSION = overlay_color;
	ALPHA = overlay_alpha * activation;
}
