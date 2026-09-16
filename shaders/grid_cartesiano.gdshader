shader_type spatial;
render_mode unshaded;

uniform bool exibir_grid = true; // Controla se o grid desenha linhas ou apenas a cor de fundo
uniform float tamanho_celula = 2.0;
uniform vec4 cor_fundo : source_color = vec4(0.18, 0.24, 0.15, 1.0);  
uniform vec4 cor_grade : source_color = vec4(0.7, 0.7, 0.7, 0.3);   
uniform vec4 cor_eixo_x : source_color = vec4(0.9, 0.2, 0.2, 1.0);  
uniform vec4 cor_eixo_z : source_color = vec4(0.2, 0.6, 0.9, 1.0);  

varying vec3 pos_mundo;

void vertex() {
	pos_mundo = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (!exibir_grid) {
		ALBEDO = cor_fundo.rgb;
	} else {
		vec2 coord = pos_mundo.xz / tamanho_celula;
		vec2 grid_pos = abs(fract(coord - 0.5) - 0.5);
		vec2 delta = fwidth(coord);
		
		vec2 line = smoothstep(vec2(0.5) - delta, vec2(0.5), grid_pos);
		float eh_linha = max(line.x, line.y);

		float largura_eixo = 0.1;
		bool eixo_x = abs(pos_mundo.z) < largura_eixo;
		bool eixo_z = abs(pos_mundo.x) < largura_eixo;

		vec4 cor_final = mix(cor_fundo, cor_grade, eh_linha);

		if (eixo_x) {
			cor_final = cor_eixo_x;
		} else if (eixo_z) {
			cor_final = cor_eixo_z;
		}

		ALBEDO = cor_final.rgb;
	}
}