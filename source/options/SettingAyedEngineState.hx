package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import lime.app.Application;
import Controls;

using StringTools;

class SettingAyedEngineState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Setting Ayed Engine';
		rpcTitle = 'Just Some random Setting Added On Version V2'; //for Discord Rich Presence

		var option:Option = new Option('hide Art Loading Screen',
			"If It's Set True The art of loading screen Will Diappear",
			'hideLoadingState',
			'bool',
			false);
		addOption(option);

		// full screen will fucked the game sometime

        var option:Option = new Option('FPS Rainbow',
        "Rainbow FPS Color",
        'rainbowFPS',
        'bool',
        true);
        addOption(option);

        var option:Option = new Option('Hide Current Time Song',
        "Time Song Should Be Hide Or Naw",
        'hideTimeNum',
        'bool',
        true);
        addOption(option);
		
		var option:Option = new Option('Show Version Engine',
		"you show the version of ayed engine down in fps",
		'showAeVs',
		'bool',
		false);
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			'int',
			60);
		addOption(option);

		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	/*
	function onCheckBools()
	{
		if(ClientPrefs.fullScreen)
			Application.current.window.fullscreen = true;
		else
			Application.current.window.fullscreen = false;

		// if Load Game Assets
	}*/

	// Full screen Key Bind Has Been Added F11

	override function destroy()
	{
		// if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}
	
	function onChangeFramerate()
		{
			if(ClientPrefs.framerate > FlxG.drawFramerate)
			{
				FlxG.updateFramerate = ClientPrefs.framerate;
				FlxG.drawFramerate = ClientPrefs.framerate;
			}
			else
			{
				FlxG.drawFramerate = ClientPrefs.framerate;
				FlxG.updateFramerate = ClientPrefs.framerate;
			}
		}
}
