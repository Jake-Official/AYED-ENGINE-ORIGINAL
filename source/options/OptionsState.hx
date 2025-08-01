package options;

#if desktop
import Discord.DiscordClient;
#end
import Controls;
import flash.text.TextField;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
// import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import lime.app.Application;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Controls', 'Visuals and UI', 'Gameplay', 'Setting Ayed Engine'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var About:FlxText;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String)
	{
		switch (label)
		{
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Setting Ayed Engine':
				openSubState(new options.SettingAyedEngineState());
		}
	}

	// var MusicOptions:FlxSound;
	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end		

		onLoadMusic();

		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('menuOptions'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			// optionText.x = 100;
			// optionText.screenCenter();
			optionText.isMenuItem = true;
			optionText.color = 0xD1F4FF;
			// optionText.y += (100 * (i - (options.length / 2))) + 50;
			// optionText.x += (100 * (i - (options.length / 2))) + 50;
			var scr:Float = (options.length - 4) * 0.135;
			if (options.length < 6)
				scr = 0;
			// optionText.snapToPosition();
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		selectorLeft.color = 0x1900FF;
		// add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		selectorRight.color = 0x1900FF;
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		About = new FlxText(0, 0, 0, 'Here To Change Your Damn Settings Game', 32, true);
		About.color = 0x00FFFF;
		// About.screenCenter();
		// don't change that's pls okay
		// add(About);
		// add(Trying);

		// when the game starting the 

		super.create();
	}

	/* ba das s code
	private function ClickTrying()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		PlayState.SONG = Song.loadFromJson('tutorial', 'tutorial');
		PlayState.isStoryMode = false;
		LoadingState.loadAndSwitchState(new PlayState());
	}*/

	function onLoadMusic(){
		// dRaMa
		if (!PauseSubState.backSong){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}else{
			switch(PlayState.SONG.song){
				case 'heartburn-ayedmix':
					FlxG.sound.playMusic(Paths.music('optionsRandom/sample1'));
				case 'canell-really':
					FlxG.sound.playMusic(Paths.music('freshChilling'));
				default:
					FlxG.sound.playMusic(Paths.music('MusicCredits'));
			}	
		}
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		var fs = controls.FULLSCREEN;

		if(fs){
			if(Application.current.window.fullscreen){
				Application.current.window.fullscreen = false;
			}else{
				Application.current.window.fullscreen = true;
			}
		}

		if (controls.BACK)
		{
			// MusicOptions.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			// FlxG.sound.playMusic(Paths.music('freakyMenu'));
			if(PauseSubState.backSong){
				MusicBeatState.switchState(new PlayState());
				PauseSubState.backSong = false;
			}else{
				MusicBeatState.switchState(new MainMenuState());	
			}
		}

		if (controls.ACCEPT)
		{
			selectorRight.color = 0x00FFFF;
			selectorLeft.color = 0x00FFFF;
			openSelectedSubstate(options[curSelected]);
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 1;
			if (item.targetY == item.y)
			{
				item.alpha = 1;
				selectorRight.x = item.x + 800; // LOL ENGINE
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
