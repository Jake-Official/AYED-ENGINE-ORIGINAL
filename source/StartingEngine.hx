package;

import haxe.display.Protocol.FileParams;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import lime.app.Application;
import Controls;

class StartingEngine extends MusicBeatState
{
    public var discordLink:String = '';
    var velocityBG:FlxBackdrop;
    var startingText:FlxText;

    override function create() 
    {
        loadLink();

        #if mobile
        FlxG.mouse.visible = true;
        #end

        PlatformUtil.sendWindowsNotification("AYED ENGINE DEMO", "Loading Assets Game ...", 3);

        FlxG.sound.playMusic(Paths.music('MusicCredits'), 1);

		velocityBG = new FlxBackdrop(Paths.image('velocityBG'));
		velocityBG.velocity.set(50, 50);
		add(velocityBG);

        startingText = new FlxText(0, 0, 0, '       Yo Player ! This Mods Is May Be Some Assets Not Completed Yet \n
        cuz your running as DEMO version Mods And Version Engine Is 2.0\n
        Flash Warning | Bit Loader Song | Some Bug May Be Fixed In Next Version \n
        Hope Ya Enjoy The Mods And Engine And Thank You For Downloading It !!!!\n
        Press Space To Join Discord Server Developer Engine !!!! -Jake_Official', 20);
        startingText.color = FlxColor.WHITE;
        startingText.screenCenter();
        // startingText.alpha = 0.4;
        add(startingText);

        super.create();
    }

    function loadLink(){
        var http = new haxe.Http("https://raw.githubusercontent.com/Jake-Official/FNF-AYED-ENGINE/refs/heads/main/Lib/discordLink.txt");

        http.onData = function (data:String) {
            discordLink = data;
            trace('Data Has Been Loaded: ${discordLink}');
        }

        http.onError = function (error) {
        trace('error: $error');
        }

        http.request();
    }

    var selectedShit:Bool;
    // var fs = controls.FULLSCREEN;
    override function update(elapsed:Float)
    {
        if(!selectedShit){

            if (FlxG.mouse.justPressed || FlxG.keys.justPressed.ENTER)
            {
                startingEngine();
                selectedShit = true;
            }
            //shit shit shit not more crash mfs
        }

        if (FlxG.keys.justPressed.SPACE)
        {
            if(discordLink != null){
                FlxG.openURL(discordLink);
            }else{
                FlxG.openURL('https://discord.gg/Fe8fdm4dse');
            }
        }


        if(FlxG.keys.justPressed.F11){
            if(Application.current.window.fullscreen){
                Application.current.window.fullscreen = false;
                trace('Full Screen Is Turned Off');
            }else{
                Application.current.window.fullscreen = true;
                trace('Full Screen Is Turned On');
            }
        }

        super.update(elapsed);
    }

    function startingEngine(){
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.sound('confirmMenu'));
        MusicBeatState.switchState(new TitleState());
        TitleState.initialized = false;
        TitleState.closedState = false;
        FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
    }
}