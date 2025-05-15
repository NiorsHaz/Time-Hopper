/*
	Alternative Glitch Effect Shader for Sprite2D
	Based on original by Yui Kinomoto @arlez80
	MIT License
*/

shader_type canvas_item;

// 振動の強さ
uniform float shake_power : hint_range(0.0, 0.1) = 0.03;
// 振動率
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
// 振動速度
uniform float shake_speed : hint_range(0.0, 10.0) = 5.0;
// 振動ブロックサイズ
uniform float shake_block_size : hint_range(1.0, 100.0) = 30.5;
// 色の分離率
uniform float shake_color_rate : hint_range(0.0, 0.1) = 0.01;

float random(float seed) {
	return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
	// Activer/désactiver le glitch en fonction du taux
	float enable_shift = float(random(trunc(TIME * shake_speed)) < shake_rate);

	// Utiliser les coordonnées UV locales du sprite
	vec2 fixed_uv = UV;
	fixed_uv.x += (random((trunc(UV.y * shake_block_size) / shake_block_size) + TIME) - 0.5) * shake_power * enable_shift;

	// Lire la couleur de la texture du sprite
	vec4 pixel_color = texture(TEXTURE, fixed_uv);

	// Appliquer la séparation des couleurs
	pixel_color.r = mix(
		pixel_color.r,
		texture(TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0)).r,
		enable_shift
	);
	pixel_color.b = mix(
		pixel_color.b,
		texture(TEXTURE, fixed_uv + vec2(-shake_color_rate, 0.0)).b,
		enable_shift
	);

	COLOR = pixel_color;
}