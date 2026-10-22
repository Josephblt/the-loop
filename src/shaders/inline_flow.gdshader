shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(0.92, 0.82, 1.0, 1.0);
uniform vec4 halo_color : source_color = vec4(0.48, 0.18, 1.0, 0.55);
uniform float core_width : hint_range(0.01, 0.5) = 0.04;
uniform float halo_width : hint_range(0.02, 1.5) = 0.2;
uniform float noise_scale : hint_range(1.0, 40.0) = 18.0;
uniform float flow_speed : hint_range(0.0, 8.0) = 2.6;
uniform float breakup : hint_range(0.0, 1.0) = 0.65;

const float LOCAL_PIXEL_ENCODING_SCALE = 8.0;


float mask_value(vec3 mask_color) {
	return step(0.9, mask_color.r) * step(mask_color.g, 0.8) * step(0.9, mask_color.b);
}

float random_value(vec2 position) {
	return fract(sin(dot(position, vec2(12.9898, 78.233))) * 43758.5453);
}

float value_noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 blend = smoothstep(vec2(0.0), vec2(1.0), fract(position));
	float bottom = mix(random_value(cell), random_value(cell + vec2(1.0, 0.0)), blend.x);
	float top = mix(random_value(cell + vec2(0.0, 1.0)), random_value(cell + vec2(1.0)), blend.x);
	return mix(bottom, top, blend.y);
}

void fragment() {
	vec3 center_color = texture(TEXTURE, UV).rgb;
	float center = mask_value(center_color);
	float local_pixel_size = max(center_color.g / LOCAL_PIXEL_ENCODING_SCALE, 0.0001);
	float core_radius = core_width / local_pixel_size;
	float halo_radius = halo_width / local_pixel_size;
	float core_mask = 1.0;
	float halo_mask = 1.0;

	for (int index = 0; index < 16; index++) {
		float angle = float(index) * 0.3926991;
		vec2 direction = vec2(cos(angle), sin(angle));
		vec3 core_color_sample = texture(TEXTURE, UV + direction * TEXTURE_PIXEL_SIZE * core_radius).rgb;
		vec3 halo_color_sample = texture(TEXTURE, UV + direction * TEXTURE_PIXEL_SIZE * halo_radius).rgb;
		float core_sample = mask_value(core_color_sample);
		float halo_sample = mask_value(halo_color_sample);
		core_mask = min(core_mask, core_sample);
		halo_mask = min(halo_mask, halo_sample);
	}

	core_mask = max(center - core_mask, 0.0);
	halo_mask = max(center - halo_mask, 0.0) * (1.0 - core_mask);

	vec2 forward_flow = UV * noise_scale + vec2(TIME * flow_speed, -TIME * flow_speed * 0.7);
	vec2 reverse_flow = UV.yx * noise_scale * 1.9 + vec2(-TIME * flow_speed * 1.3, TIME * flow_speed);
	float chaos = value_noise(forward_flow) * 0.65 + value_noise(reverse_flow) * 0.35;
	float broken_edge = mix(1.0, smoothstep(0.25, 0.8, chaos), breakup);
	float flare = 0.55 + chaos * chaos * 1.1;
	float alpha = core_mask * core_color.a * broken_edge * flare;
	alpha += halo_mask * halo_color.a * broken_edge * chaos;
	vec3 color = mix(halo_color.rgb, core_color.rgb, core_mask);

	COLOR = vec4(color, alpha);
}
