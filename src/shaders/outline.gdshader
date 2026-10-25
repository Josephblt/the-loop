shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(1.0, 10.0) = 1.0;

void fragment() {
	float center = texture(TEXTURE, UV).a;
	vec2 offset = TEXTURE_PIXEL_SIZE * outline_width;

	float neighbors = 0.0;

	neighbors = max(neighbors, texture(TEXTURE, UV + vec2( offset.x, 0.0)).a);
	neighbors = max(neighbors, texture(TEXTURE, UV + vec2(-offset.x, 0.0)).a);
	neighbors = max(neighbors, texture(TEXTURE, UV + vec2(0.0,  offset.y)).a);
	neighbors = max(neighbors, texture(TEXTURE, UV + vec2(0.0, -offset.y)).a);

	neighbors = max(neighbors, texture(TEXTURE, UV + vec2( offset.x,  offset.y)).a);
	neighbors = max(neighbors, texture(TEXTURE, UV + vec2(-offset.x,  offset.y)).a);
	neighbors = max(neighbors, texture(TEXTURE, UV + vec2( offset.x, -offset.y)).a);
	neighbors = max(neighbors, texture(TEXTURE, UV + vec2(-offset.x, -offset.y)).a);

	float outline = max(neighbors - center, 0.0);

	COLOR = vec4(
		outline_color.rgb,
		outline_color.a * outline
	);
}
