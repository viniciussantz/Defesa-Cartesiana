shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform sampler2D textura_terra : source_color, repeat_enable, filter_linear_mipmap;
uniform vec2 escala_uv = vec2(1.0, 15.0); // X = Repetição na Largura | Y = Repetição no Comprimento
uniform float largura_borda : hint_range(0.001, 0.5) = 0.2;
uniform bool inverter_eixos = false; // Marque caso os eixos da malha estejam trocados

void fragment() {
    // 1. Identifica qual eixo é a LARGURA e qual é o COMPRIMENTO do caminho
    float uv_largura = inverter_eixos ? UV.y : UV.x;
    float uv_comprimento = inverter_eixos ? UV.x : UV.y;

    // 2. Garante que a largura fique estritamente entre 0.0 e 1.0
    float u_limpo = fract(uv_largura);

    // 3. Máscara de transparência contínua para as bordas laterais
    float dist_borda = min(u_limpo, 1.0 - u_limpo);
    float mascara_borda = smoothstep(0.0, largura_borda, dist_borda);

    // 4. Aplica a textura com a repetição (escala) correta
    vec2 uv_textura = vec2(u_limpo, uv_comprimento) * escala_uv;
    vec4 cor_terra = texture(textura_terra, uv_textura);

    ALBEDO = cor_terra.rgb;
    ALPHA = cor_terra.a * mascara_borda;
}