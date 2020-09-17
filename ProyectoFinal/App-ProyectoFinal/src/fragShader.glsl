#version 430

in vec3 varyingNormal;
in vec3 varyingLightDir;
in vec3 varyingVertPos;
in vec3 varyingHalfVector;

in vec4 varyingColor;

out vec4 fragColor;

struct PositionalLight
{	vec4 ambient;  
	vec4 diffuse;  
	vec4 specular;  
	vec3 position;
};

struct Material
{	vec4 ambient;  
	vec4 diffuse;  
	vec4 specular;  
	float shininess;
};

uniform vec4 globalAmbient;
uniform PositionalLight light;
uniform Material material;
uniform mat4 mv_matrix;	 
uniform mat4 proj_matrix;
uniform mat4 norm_matrix;

uniform int op_shader;
uniform vec3 u_color;

void main() {

    if (op_shader == 0){
        fragColor = vec4(u_color, 1.0);
    }

    if (op_shader == 1){ // blingphong
        vec3 L = normalize(varyingLightDir);
        vec3 N = normalize(varyingNormal);
        vec3 V = normalize(-varyingVertPos);
        
        // get the angle between the light and surface normal:
        float cosTheta = dot(L,N);
        
        // halfway vector varyingHalfVector was computed in the vertex shader,
        // and interpolated prior to reaching the fragment shader.
        // It is copied into variable H here for convenience later.
        vec3 H = normalize(varyingHalfVector);
        
        // get angle between the normal and the halfway vector
        float cosPhi = dot(H,N);

        // compute ADS contributions (per pixel):
        vec3 ambient = ((globalAmbient * material.ambient) + (light.ambient * material.ambient)).xyz;
        vec3 diffuse = light.diffuse.xyz * material.diffuse.xyz * max(cosTheta,0.0);
        vec3 specular = light.specular.xyz * material.specular.xyz * pow(max(cosPhi,0.0), material.shininess*3.0);
        fragColor = vec4((ambient + diffuse + specular), 1.0);
    }

    if (op_shader == 2){ //goraud
	    fragColor = varyingColor;
    }

    if (op_shader == 3){ // phong
    	vec3 L = normalize(varyingLightDir);
        vec3 N = normalize(varyingNormal);
        vec3 V = normalize(-varyingVertPos);
        
        // compute light reflection vector, with respect N:
        vec3 R = normalize(reflect(-L, N));
        
        // get the angle between the light and surface normal:
        float cosTheta = dot(L,N);
        
        // angle between the view vector and reflected light:
        float cosPhi = dot(V,R);

        // compute ADS contributions (per pixel):
        vec3 ambient = ((globalAmbient * material.ambient) + (light.ambient * material.ambient)).xyz;
        vec3 diffuse = light.diffuse.xyz * material.diffuse.xyz * max(cosTheta,0.0);
        vec3 specular = light.specular.xyz * material.specular.xyz * pow(max(cosPhi,0.0), material.shininess);
        
        fragColor = vec4((ambient + diffuse + specular), 1.0);
    }
    
}