shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back;
uniform float sway_amplitude : hint_range(0.0, 1.0) = 0.15;
uniform float sway_speed : hint_range(0.0, 10.0) = 2.0;
uniform sampler2D texture;
uniform vec2 tex_size;

void vertex() {
    vec3 local_pos = VERTEX;

    float sway_factor = sin(TIME * sway_speed + local_pos.y * 2.0) * sway_amplitude;

	if (local_pos.y <=2.75 && local_pos.y >1.5){
    	sway_factor *= 0.65 - clamp(local_pos.y, 0,.5);
		local_pos.x += sway_factor;
		
	}
	else if (local_pos.y <=1.5){
		sway_factor *= 1.0 - clamp(local_pos.y, 0,.5);
		local_pos.x += sway_factor;
		
	}
	
    VERTEX = local_pos;
}

void fragment(){
    vec2 adjusted_uv = floor(UV * tex_size) / tex_size;
    
    vec4 tex_color = texture(texture, adjusted_uv);
    vec3 linear_color = pow(tex_color.rgb, vec3(2.5));
    ALBEDO = linear_color;
    ALPHA = tex_color.a;
	ROUGHNESS = 0.35;
}