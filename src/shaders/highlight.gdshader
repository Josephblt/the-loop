shader_type canvas_item;
render_mode unshaded;

uniform vec4 shine_color : source_color = vec4(0.88, 0.8, 1.0, 0.9);
uniform float cycle_interval : hint_range(0.5, 5.0, 0.1) = 2.5;
uniform float shine_speed : hint_range(0.05, 2.0, 0.05) = 0.45;
uniform float shine_width : hint_range(0.01, 0.25, 0.01) = 0.07;
uniform float shine_softness : hint_range(0.001, 0.25, 0.001) = 0.04;
uniform float shine_angle : hint_range(-180.0, 180.0, 1.0) = 35.0;

void fragment() {
	float mask = texture(TEXTURE, UV).a;
	vec2 position = UV - vec2(0.5);
	position.x *= TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;

	float angle = radians(shine_angle);
	vec2 direction = vec2(cos(angle), sin(angle));
	float phase = fract(dot(position, direction) * cycle_interval - TIME * shine_speed);
	float distance_to_shine = abs(phase - 0.5);
	float shine = 1.0 - smoothstep(shine_width, shine_width + shine_softness, distance_to_shine);

	float left = texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a;
	float right = texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a;
	float above = texture(TEXTURE, UV - vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a;
	float below = texture(TEXTURE, UV + vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a;
	float inner_edge = clamp(mask - min(min(left, right), min(above, below)), 0.0, 1.0);
	float intensity = shine * mix(0.55, 1.0, inner_edge);

	COLOR = vec4(shine_color.rgb, mask * intensity * shine_color.a);
}
