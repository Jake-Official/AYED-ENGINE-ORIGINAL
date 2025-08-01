package;

import openfl.ui.Mouse;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;
import lime.app.Application;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	public static var hasbeenO:Bool = false;
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];
	var pisspoop:Array<Array<String>>;

	var leftSelection:FlxSprite;
	var rightSelection:FlxSprite;
	var logoBl:FlxSprite;
	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Menu Credits", null);
		#end
		
		FlxG.sound.playMusic(Paths.music('MusicCredits'));

		loadData(); //load Shit

		persistentUpdate = true;
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menuCredits'));
		add(bg);
		bg.screenCenter();

		logoBl = new FlxSprite(0, 0);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');

		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, true);
		// add(logoBl);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var discordLingInvite:String = '';

		pisspoop = [ //Name - Icon name - Description - Link - BG Color
			['AYED ENGINE DEVELOPER'],
			['Jake Official', 'Jake', 'Director + Top Artist + Animator + Composer + Coder + Charter + EVERYTHING', 'https://www.youtube.com/channel/UCUua-E46uqVaHnF45yEIo3Q', '333FFF'],
			['PryoMania', 'pryo', "Main Artist Engine + Loading Art + BackGround MainMenu + Background WeekAyed", 'https://www.youtube.com/channel/UCFSSXfpYCSP-fIbtTCVhoOA', '0F3F0A'],
			['Tsunami', 'tsunami', "Artist Background Heartburn AYED MIX", 'https://x.com/MistyMl2?t=JKlh1vc1iOGhoMeFgkdObw&s=09', 'A600FF'],
			['koi', 'koi', 'ReDesign AYED ENGINE Site', 'https://x.com/maybekoi_', '00FF00'],
			['Shiko', 'Shiko', 'artist', 'https://youtube.com/@shiko_shiko07?si=RsOSX3Dnd9g6Mjsc', 'FF00E6']
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}

		for (i in 0...creditsStuff.length)
		{
			// creditsStuff.x = FlxColor.PURPLE;

			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			// optionText.color = 0xFFFFFFFF;
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}

		var http = new haxe.Http("https://raw.githubusercontent.com/Jake-Official/AYED--ENGINE-SOURCE-CODE/refs/heads/main/discordLogInvite.txt");

		http.onData = function (link:String){
			discordLingInvite = link;
			if(link != discordLingInvite){
				discordLingInvite = link;
				trace('Link Server Invite Load Up : $discordLingInvite');
			}
		}

		http.onError = function(error){
			trace("error :" + error + ' Retry !!!');
		}

		http.request();
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, 0xFF000000);
		descBox.screenCenter();
		descBox.xAdd = -10;
		descBox.yAdd = -5;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		// add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, 0xFF00C4C4, LEFT/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();

		leftSelection = new FlxSprite(0);
		leftSelection.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftSelection.screenCenter(Y);
		add(leftSelection);
		leftSelection.animation.play('leftArrow');

		rightSelection = new FlxSprite(1225, 320);
		// rightSelection.screenCenter(Y);
		rightSelection.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		leftSelection.animation.addByPrefix('leftArrow', "arrow left0000", 24);
		rightSelection.animation.addByPrefix('rightArrow', "arrow right0000", 24);
		leftSelection.animation.addByPrefix('leftPush', "arrow push left0000", 24);
		rightSelection.animation.addByPrefix('rightPush', "arrow push right0000", 24);
		rightSelection.animation.play('rightArrow');
		add(rightSelection);

		super.create();
	}

	function loadData(){
		FlxG.save.data.hasbeenO = hasbeenO;
		trace('data Has Been Loaded + ${hasbeenO}');	
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		/*
		grpOptions.forEach(function(lmfao:Alphabet){
			if(lmfao.text = creditsStuff){

			}
		});
		*/

		if(!quitting)
		{
			if(curSelected > 1){
				if(FlxG.keys.justPressed.ENTER){
					if(FlxG.save.data.hasbeenO != null){
						hasbeenO = FlxG.save.data.hasbeenO;
					}
				if(!hasbeenO){
					hasbeenO = true;

					PlayState.SONG = Song.loadFromJson("dev-engine", "dev-engine");
					PlayState.isStoryMode = false;
					// PlayState.storyDifficulty = curDifficulty;
					LoadingState.loadAndSwitchState(new PlayState());
				}else{
					FlxG.openURL(creditsStuff[2][3]); //bitch what the fuck do you want 
				}
			}
		}
			
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;
				var leftP = controls.UI_LEFT_P;
				var rightP = controls.UI_LEFT_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}

				if(controls.UI_LEFT)
				{
					// FlxG.sound.play(Paths.sound('confirmMenu'));
					leftSelection.animation.play('leftPush');
					MusicBeatState.switchState(new CreditsFnfState());	
				}
				if (controls.UI_RIGHT)
				{
					rightSelection.animation.play('rightPush');
					MusicBeatState.switchState(new CreditsFnfState());
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
					CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				// FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
			var fs = controls.FULLSCREEN;

			if(fs){
				if(Application.current.window.fullscreen){
					Application.current.window.fullscreen = false;
				}else{
					Application.current.window.fullscreen = true;
				}
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int =  getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0x')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
