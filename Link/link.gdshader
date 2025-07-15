shader_type canvas_item;
uniform int lightning_number = 1;
uniform vec2 amplitude = vec2(2.0,1.0);
uniform float offset = 0.45;
uniform float thickness = 0.02;
uniform float speed = 3.0;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_thickness = 0.08;
uniform vec4 glow_color : source_color = vec4(0.2, 0, 0.8, 0.0);
uniform float alpha : hint_range(0, 1) = 1.0;
uniform float start_y = 0.5; // Y coordinate where lightning starts and ends

// plot function 
float plot(vec2 st, float pct, float half_width){
  return  smoothstep( pct-half_width, pct, st.x) -
          smoothstep( pct, pct+half_width, st.x);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 n) {
    float total = 0.0, amp = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amp;
        n += n;
        amp *= 0.5;
    }
    return total;
}

// Function to create lightning that starts and ends at the same Y coordinate
float lightning_path(vec2 uv, float lightning_offset) {
    vec2 t = uv * amplitude + vec2(-lightning_offset, lightning_offset) - TIME * speed;
    
    // Generate base noise
    float base_noise = fbm(t) * offset;
    
    // Create a falloff function that forces the lightning to return to start_y at the edges
    float edge_falloff = sin(uv.x * 3.14159); // Sine wave from 0 to 1 across X
    
    // Combine noise with falloff to ensure endpoints match
    float lightning_y = start_y + (base_noise - 0.5 * offset) * edge_falloff;
    
    return lightning_y;
}

void fragment(){
	vec2 uv = UV;
	vec4 color = vec4(0.0, 0.0, 0.0, 0.0);
	
	float lightning_y;
	float pct;
	float buffer;	
	
	// add more lightning
	for (int i = 0; i < lightning_number; i++){
		lightning_y = lightning_path(uv, float(i));
		pct = plot(uv, lightning_y, thickness);
		buffer = plot(uv, lightning_y, glow_thickness);
		color += pct * base_color;
		color += buffer * glow_color;
	}
	
	color.a *= alpha;
	COLOR = color;
}