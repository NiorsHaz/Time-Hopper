/*
	CRT Effect Shader for Godot 4.4
	MIT License
*/

shader_type canvas_item;

// Déclaration de SCREEN_TEXTURE pour Godot 4.4
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Nombre de scanlines
uniform float scanline_count : hint_range(0.0, 1800.0) = 50.0;
// Intensité de la courbure
uniform float curvature : hint_range(0.0, 10.0) = 3.0;
// Intensité des scanlines
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.9;
// Décalage RGB
uniform float rgb_offset : hint_range(0.0, 0.01) = 0.003;

vec2 uv_curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv.x *= 1.0 + pow(abs(uv.y) / curvature, 2.0);
	uv.y *= 1.0 + pow(abs(uv.x) / curvature, 2.0);
	uv = (uv / 2.0) + 0.5;
	return uv;
}

void fragment() {
	// Appliquer la courbure aux coordonnées UV
	vec2 curved_uv = uv_curve(SCREEN_UV);

	// Initialiser la couleur par défaut (noir pour les zones hors texture)
	vec4 final_color = vec4(0.0, 0.0, 0.0, 1.0);

	// Vérifier si les UV sont valides
	if (curved_uv.x >= 0.0 && curved_uv.x <= 1.0 && curved_uv.y >= 0.0 && curved_uv.y <= 1.0) {
		// Lire les canaux RGB avec un décalage pour l'effet CRT
		float r = texture(SCREEN_TEXTURE, curved_uv + vec2(rgb_offset, 0.0)).r;
		float g = texture(SCREEN_TEXTURE, curved_uv).g;
		float b = texture(SCREEN_TEXTURE, curved_uv - vec2(rgb_offset, 0.0)).b;

		// Appliquer les scanlines
		float s = sin(curved_uv.y * scanline_count * PI * 2.0);
		s = (s * 0.5 + 0.5) * scanline_intensity + (1.0 - scanline_intensity);
		vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);

		// Combiner la couleur et les scanlines
		final_color = vec4(r, g, b, 1.0) * scan_line;
	}

	// Définir la couleur finale
	COLOR = final_color;
}