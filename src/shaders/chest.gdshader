shader_type canvas_item;

uniform float jiggle = 2.5;
uniform float speed = 2.0;

uniform float amplitude    = 5.0;
uniform float noise_scale  = 50.0;
uniform float noise_speed  = 2.5;

uniform int pixelSize = 4;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i + vec2(0.0,0.0));
  float b = hash(i + vec2(1.0,0.0));
  float c = hash(i + vec2(0.0,1.0));
  float d = hash(i + vec2(1.0,1.0));
  vec2 u = f*f*(3.0-2.0*f);
  return mix(a, b, u.x) +
  (c - a) * u.y * (1.0 - u.x) +
  (d - b) * u.x * u.y;
}

void vertex() {
	VERTEX.y += VERTEX_ID % 2 == 0 ? cos((TIME * speed) + VERTEX.x + float(VERTEX_ID * 10)) * jiggle : sin((TIME * speed) + VERTEX.x + float(VERTEX_ID * 10)) * jiggle;
}

void fragment() {
  vec2 uv = UV;

  // float nx = noise(uv * noise_scale + vec2(TIME * noise_speed, 0.0));
  // float ny = noise(uv * noise_scale + vec2(0.0, TIME * noise_speed));
  // vec2 rand_dir = normalize(vec2(nx * 2.0 - 1.0, ny * 2.0 - 1.0));

  // float n = noise(uv * noise_scale + vec2(TIME * noise_speed));
  // float off = (n * 2.0 - 1.0) * amplitude;

  // vec2 uv2 = uv + rand_dir * off * TEXTURE_PIXEL_SIZE;
  // COLOR.a = min(COLOR.a, texture(TEXTURE, uv2).a);

  ivec2 size = textureSize(TEXTURE, 0);
	
	int xRes = size.x;
	int yRes = size.y;
	
	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);
	
	float grid_uv_x = round(uv.x * xFactor) / xFactor;
	float grid_uv_y = round(uv.y * yFactor) / yFactor;
	
	vec4 text = texture(TEXTURE, vec2(grid_uv_x, grid_uv_y));
	
	COLOR = text;

  vec4 orig = texture(TEXTURE, uv);
  if (orig.a <= 0.0) {
    discard;
  }
}