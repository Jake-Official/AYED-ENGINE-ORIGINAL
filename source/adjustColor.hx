package;

import flixel.system.FlxAssets.FlxShader;

class adjustColor
{
    public var shader(default, null):AdjustColorShaderr = new AdjustColorShader();
    public var hue(default, null):Float = 0;
    public var saturation(default, null):Float = 0;
    public var contrast(default, null):Float = 0;

    function set_Hue(value1:Float):Float
    {
        onLoadShader(true);
        shader.hue.value = [value1];
        //fuck me and fuck you too
        return value1;
    }

    function set_Saturation(value1:Float):Float
    {
        onLoadShader(true);
        shader.saturation.value = [value1];
        // haha ayed engine is the best mods ever (guess what fuck you it's not ToT)
        return value1;
    }
    
    function set_Contrast(value1:Float):Float
    {
        onLoadShader(true);
        shader.contrast.value = [value1];
        // return Many Value1
        return value1;
        // FlxG.update.set = 0 * value1;
    }

    public var brightness(default, null):Float = 0;

    function set_Brightness(value1:Float):Float
    {
        // set.brightness = brightness;
        shader.brightness.value = [value1];
        try{
            shader.uTime.value = [FlxG.update * 0];
            // what the heck if that work cuz FlxG is sometime dumb
            return value1;
        }
        onLoadShader(true);
    }

    public function new(){
        super();
    }

    function onLoadShader(valueB:Bool):Bool{
        if(!valueB){
            trace('Completed On Function Off Bool');
        }else{
            trace('Completed On Function On Bool');
        }
        return valueB;
    }
}

class AdjustColorShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    // this shader is a slighly edited recreation of the Animate/Flash "Adjust Color" filter,
    // which was kindly provided and written by Rozebud https://github.com/ThatRozebudDude ( thank u rozebud :) )
    // Adapted from Andrey-Postelzhuks shader found here: https://forum.unity.com/threads/hue-saturation-brightness-contrast-shader.260649/
    // Hue rotation stuff is from here: https://www.w3.org/TR/filter-effects/#feColorMatrixElement

    uniform float hue;
    uniform float saturation;
    uniform float brightness;
    uniform float contrast;

    const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
    const float e = 2.718281828459045;

    vec3 applyHueRotate(vec3 aColor, float aHue){
        float angle = radians(aHue);

        mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
        mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
        mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
        mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;

        return m * aColor;
    }

    vec3 applySaturation(vec3 aColor, float value){
        if(value > 0.0){ value = value * 3.0; }
        value = (1.0 + (value / 100.0));
        vec3 grayscale = vec3(dot(aColor, grayscaleValues));
        return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
    }

    vec3 applyContrast(vec3 aColor, float value){
        value = (1.0 + (value / 100.0));
            if(value > 1.0){
                value = (((0.00852259 * pow(e, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0; //Just roll with it...
                value += 1.0;
            }
    return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
    }

    vec3 applyHSBCEffect(vec3 color){

        //Brightness
        color = color + ((brightness) / 255.0);

        //Hue
        color = applyHueRotate(color, hue);

        //Contrast
        color = applyContrast(color, contrast);

        //Saturation
    color = applySaturation(color, saturation);

    return color;
    }

    void main(){

        vec4 textureColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

        // Un-multiply alpha if the texture is premultiplied
    // Lime premultiplies alphas before sending it to render, so we want to accomodate header. This fixes some antialiased edges appearing darker
    vec3 unpremultipliedColor = textureColor.a > 0.0 ? textureColor.rgb / textureColor.a : textureColor.rgb;

        // Apply effects to the unpremultiplied color
        vec3 outColor = applyHSBCEffect(unpremultipliedColor);

        gl_FragColor = vec4(outColor * textureColor.a, textureColor.a);
    }
    ')
    public function new(){
        super();
    }
}