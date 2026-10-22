shader_type spatial;
render_mode unshaded, cull_disabled;

const float LOCAL_PIXEL_ENCODING_SCALE = 8.0;

varying vec3 local_position;


void vertex() {
	local_position = VERTEX;
}


void fragment() {
	float local_pixel_size = max(length(dFdx(local_position)), length(dFdy(local_position)));
	float encoded_pixel_size = min(local_pixel_size * LOCAL_PIXEL_ENCODING_SCALE, 0.75);
	ALBEDO = vec3(1.0, encoded_pixel_size, 1.0);
}
