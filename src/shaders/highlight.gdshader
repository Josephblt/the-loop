shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 color : source_color = vec4(0.88235295, 0.8, 1.0, 0.7529412);
uniform float flow_speed : hint_range(0.0, 100.0) = 5.0;

uniform float angle_x : hint_range(0.0, 360.0) = 30.0;
uniform float angle_y : hint_range(0.0, 360.0) = 45.0;
uniform float angle_z : hint_range(0.0, 360.0) = 60.0;

uniform float width : hint_range(0.0, 1.0) = 0.1;
uniform float spacing : hint_range(0.001, 100.0) = 10.0;

group_uniforms Noise;

uniform float scale : hint_range(0.1, 100.0) = 5.0;
uniform float amount : hint_range(0.0, 1.0) = 0.25;
uniform float speed : hint_range(0.0, 10.0) = 5.0;

float random(vec2 position)
{
	return fract(sin(dot(position, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 position)
{
	vec2 cell = floor(position);
	vec2 fraction = fract(position);
	vec2 blend = fraction * fraction * (3.0 - 2.0 * fraction);

	float bottom_left = random(cell);
	float bottom_right = random(cell + vec2(1.0, 0.0));
	float top_left = random(cell + vec2(0.0, 1.0));
	float top_right = random(cell + vec2(1.0, 1.0));

	float bottom = mix(bottom_left, bottom_right, blend.x);
	float top = mix(top_left, top_right, blend.x);

	return mix(bottom, top, blend.y);
}

vec3 rotate_x(vec3 vector, float angle)
{
	float sine = sin(angle);
	float cosine = cos(angle);

	return vec3(
		vector.x,
		vector.y * cosine - vector.z * sine,
		vector.y * sine + vector.z * cosine
	);
}

vec3 rotate_y(vec3 vector, float angle)
{
	float sine = sin(angle);
	float cosine = cos(angle);

	return vec3(
		vector.x * cosine + vector.z * sine,
		vector.y,
		-vector.x * sine + vector.z * cosine
	);
}

vec3 rotate_z(vec3 vector, float angle)
{
	float sine = sin(angle);
	float cosine = cos(angle);

	return vec3(
		vector.x * cosine - vector.y * sine,
		vector.x * sine + vector.y * cosine,
		vector.z
	);
}

vec3 rotate_xyz(vec3 vector, vec3 angles)
{
	vector = rotate_x(vector, angles.x);
	vector = rotate_y(vector, angles.y);
	vector = rotate_z(vector, angles.z);

	return vector;
}

void fragment()
{
	vec3 world_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vec3 angles = radians(vec3(
		angle_x,
		angle_y,
		angle_z
	));

	vec3 direction = rotate_xyz(
		vec3(1.0, 0.0, 0.0),
		angles
	);

	vec3 normal = rotate_xyz(
		vec3(0.0, 1.0, 0.0),
		angles
	);

	float band_position = dot(world_vertex, normal);
	float position_along_band = dot(world_vertex, direction);

	vec2 noise_position = vec2(
		position_along_band * scale,
		TIME * speed
	);

	float noise_value = noise(noise_position);
	float shape_offset = (noise_value * 2.0 - 1.0) * amount;
	float animated_position = band_position + shape_offset - TIME * flow_speed;

	float local_position = mod(animated_position, spacing);
	float distance_to_band = min(
		local_position,
		spacing - local_position
	);

	float mask = 1.0 - step(
		width,
		distance_to_band
	);

	ALBEDO = color.rgb;
	ALPHA = mask * color.a;
}
