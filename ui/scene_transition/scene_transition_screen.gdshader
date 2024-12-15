shader_type canvas_item;

uniform sampler2D noise_texture;
uniform sampler2D dissolve_noise_texture;
uniform vec4 color_1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 color_2 : source_color = vec4(34.0, 32.0, 12.0, 1.0);
uniform float tiling_factor : hint_range(0.0, 10.0) = 1.0;
uniform float move_speed : hint_range(0.0, 0.5) = 0.1;
uniform float subtraction_speed : hint_range(0.1, 5.0) = 1.0;

void fragment() {

	// Calculate UV coordinates and apply tiling
	vec2 uv = UV * tiling_factor;

	// Offset UV coordinates to move the noise texture up or down
	uv.y += TIME * -move_speed;

	// Adjust UV coordinates for seamless tiling
	uv = fract(uv);

	// Sample the noise texture using the modified UV coordinates
	float noise_value = texture(noise_texture, uv).r;

	// Sample the dissolve noise texture using the modified UV coordinates
	float dissolve_value = texture(dissolve_noise_texture, uv).r;

	// Calculate the time-dependent factor for subtraction
	float subtraction_factor = sin(TIME * subtraction_speed);

	// Subtract the values of the dissolve noise texture from the noise texture
	float final_value = noise_value - (dissolve_value * subtraction_factor);

	// Interpolate between the 2 colors based on the final value
	vec4 final_color = mix(color_1, color_2, final_value);

	// Output the final color
	COLOR = final_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
