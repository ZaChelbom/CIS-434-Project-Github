shader_type canvas_item;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	
	float grey = tex_color.r * 0.299 + tex_color.g * 0.587 + tex_color.b * 0.114; //convert the color to a grey color
	
	COLOR = vec4(vec3(grey), tex_color.a);
}