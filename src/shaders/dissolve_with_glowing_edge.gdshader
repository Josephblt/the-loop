shader_type spatial;

uniform sampler2D albedo_texture : source_color, filter_nearest_mipmap;
uniform sampler2D noise_texture : filter_nearest_mipmap, repeat_enable;

uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform float edge_width : hint_range(0.0, 0.3) = 0.1;
uniform vec4 edge_color : source_color = vec4(0.45, 0.32, 0.61, 1.0);

void fragment() {
	vec3 base_color = texture(albedo_texture, UV).rgb;
	float noise = texture(noise_texture, UV).r;
	float remaining = 1.0 - dissolve;

	if (remaining <= 0.0 || noise > remaining) {
		discard;
	}

	float edge = smoothstep(max(remaining - edge_width, 0.0), remaining, noise);
	edge *= 1.0 - step(0.9999, remaining);

	ALBEDO = mix(base_color, edge_color.rgb, edge * edge_color.a);
}
