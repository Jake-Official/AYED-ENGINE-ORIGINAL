package;

import haxe.xml.Access;
import flixel.system.FlxAssets.FlxShader;

class SparkUseShader {
    public var shader(default, null):SparkShader = new SparkShader();

    public function new(){
        shader.iTime.value = [0.0];
    }
    public function update(elapsed:Float):Float{
        shader.iTime.value[0] += elapsed;
        return elapsed;
    }
}
class SparkShader extends FlxShader {
    @:glFragmentSource('
    // Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

    #pragma header

    #define iResolution vec3(openfl_TextureSize, 0.)
    uniform float iTime;
    #define iChannel0 bitmap
    #define texture flixel_texture2D

    // variables which are empty, they need just to avoid crashing shader
    uniform vec4 iMouse;

    // end of ShadertoyToFlixel header

    #define NUM_LAYERS 20.

    mat2 Rot(float a) {
        float s = sin(a), c = cos(a);
        return mat2( c, -s, s, c);
    }

    float Star(vec2 uv, float flare) {
        float d = length(uv);
        float m = .04/d; //smoothstep(.2, 0.5, d);
        
        float rays = max(0., 1. - abs(uv.x*uv.y*0.));
        m += rays*flare;
        uv *= Rot(3.1415/4.);
        rays = max(0., 1. - abs(uv.x*uv.y*1000.));
        m += rays*.3*flare;
        
        m*=smoothstep(1., .2, d);
        return m;
    }

    float Hash21(vec2 p) {
        p = fract(p*vec2(1223.34, 16312.21));  
        p += dot(p, p+45.85);
        return fract(p.x*p.y);
    }

    vec3 StarLayer(vec2 uv) {
        vec3 col = vec3(0);
        
        vec2 gv = fract(uv) -.5;
        vec2 id = floor(uv);
        
        for (int y=-1;y<=1;y++) {
            for (int x=-1;x<=1;x++) {
                vec2 offs = vec2(x, y);
                
                float n = Hash21(id+offs);
                float size = fract(n*345.29);
                float star = Star(gv-offs-vec2(n,fract(n*34.))+.5, smoothstep(.6,.9,size));
                
                vec3 color = sin(vec3(.2,.3,.9)*fract(n*678.3)*19.37)*.5;
                
                star *= sin(iTime*.03*n*7.);
                col += star*size*color;
            }
        }
        
        // col.rg = gv;
        
        // if (gv.x > .48 || gv.y>.48) col.r=1.;
        
        return col;
    }

    void mainImage( out vec4 fragColor, in vec2 fragCoord )
    {
        vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
        float t = iTime*.1;
        vec3 col = vec3(0);
        vec2 M = (iMouse.xy-iResolution.xy*.5)/iResolution.y;
        uv *= (sin(iTime)+1.0)*.4 + .1;
        // uv += M*4.;
        uv *= Rot(t*.8);
            
        
        for (float i=0.; i<1.; i+=1./NUM_LAYERS) {
            float depth = fract(i+t);
            float scale = mix(20., .5, depth);
            float fade = depth*smoothstep(1.,.9,depth);
            col += StarLayer(uv*scale+i*453.2-M)*fade;
        }
        col *= -1.;
        col += vec3(1.);
        fragColor = vec4(col, texture(iChannel0, fragCoord / iResolution.xy).a);
    }

    void main() {
        mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
    }
    ')
    public function new(){
        super();
    }
}