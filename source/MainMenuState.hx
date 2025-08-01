package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import haxe.Json;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.addons.display.FlxBackdrop;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouse;
import openfl.filters.ShaderFilter;
// import openfl.display.Shader;
import AssShader;
import haxe.Http;

using StringTools;

typedef MainMenuEditor = {
	testShit:Bool,
	selectedX:Float,
	selectedY:Float,
	secondItemX:Float,
	secondItemY:Float,
	threeItemX:Float,
	threeItemY:Float,
	fourItemX:Float,
	fourItemY:Float,
	creditsBgIconX:Float,
	creditsBgIconY:Float,
	middleCenterPressedX:Float,
	middleCenterPressedY:Float,
	visibleMouse:Bool
}

class MainMenuState extends MusicBeatState
{
	public static var showUpdate:Bool = false; // i sometime fucked up on da one
	public static var ayedVersion:String = 'DEMO';
	public static var ayedEngineVersion:String = '2.0'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	var mouseAhh:FlxMouse;

	public static var creditsBG:Array<Array<String>> = [
	['Jake_Official', 'https://x.com/Jake_Official00'],
	['PryoMania', 'https://www.youtube.com/channel/UCFSSXfpYCSP-fIbtTCVhoOA'],
	['justinsketches', "https://x.com/JustinSketches"]
	];

	var availableV:FlxText;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	public static var leavedTheState:Bool = false;
	
	/*
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		#if MODS_ALLOWED 'mods', #end
		#if ACHIEVEMENTS_ALLOWED 'awards', #end
		'credits',
		#if !switch 'donate', #end
		'options'
	];
	*/

	// shit item
	var menushittyList:Array<String>;
	public static var loadImg:FlxGraphicAsset;
	public static var scrImg:String;
	var shaderThing:AssShader;
	var sumShit:FlxText;
	// shit done item

	var velocityBG:FlxBackdrop;
	var magenta:FlxSprite;
	var shitJson:MainMenuEditor;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	public static var updateEngineGit:String = '';

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		FlxG.mouse.visible = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		if(ClientPrefs.hasBeated){
			menushittyList = ['freeplay', 'credits', 'options', 'browser'];
		}else{
			menushittyList = ['freeplay', 'credits', 'options'];
		}

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		shitJson = Json.parse(Paths.getTextFromFile('images/JsonFileGame/shitJson.json'));

		ClientPrefs.hasBeated = shitJson.testShit;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		scrImg = "artMainMenuBg/menuBG" + FlxG.random.int(1, 4);

		loadImg = Paths.image(scrImg);

		shaderThing = new AssShader();

		var yScroll:Float = Math.max(0.25 - (0.05 * (4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80);
		bg.loadGraphic(loadImg);
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);

		velocityBG = new FlxBackdrop(Paths.image('velocityBG'));
		velocityBG.alpha = 0.2;
		velocityBG.velocity.set(50, 50);
		if (!ClientPrefs.lowQuality){
			remove(velocityBG);
		}else{
			add(velocityBG);
		}

		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...menushittyList.length)
		{
			// var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, 130);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.loadGraphic(Paths.image("MainMenuItem/" + menushittyList[i]));
			/*No Animation Until Next Version
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + menushittyList[i]);
			menuItem.animation.addByPrefix('idle', menushittyList[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', menushittyList[i] + " white", 24);
			menuItem.animation.play('idle');
			*/
			menuItem.ID = i;
			// menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (menushittyList.length - 4) * 0.135;
			if(menushittyList.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			// menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();

			if(FlxG.mouse.overlaps(menuItem)){
				FlxG.mouse.load(("assets/images/input/overlapsCursor.png"), 1);
			}else{
				FlxG.mouse.load(("assets/images/input/cursor.png"), 1);
			}

			if(!ClientPrefs.hasBeated){
				switch(menushittyList[i]){
					case "freeplay":
						menuItem.setPosition(shitJson.secondItemX, shitJson.secondItemY);
					case "credits":
						menuItem.setPosition(shitJson.threeItemX, shitJson.threeItemY);
					case "options":
						menuItem.setPosition(shitJson.fourItemX, shitJson.fourItemY);
				}				
			}else{
				switch(menushittyList[i]){
					case "freeplay":
						menuItem.setPosition(shitJson.secondItemX, shitJson.secondItemY);
					case "credits":
						menuItem.setPosition(shitJson.threeItemX, shitJson.threeItemY);
					case "options":
						menuItem.setPosition(shitJson.fourItemX, shitJson.fourItemY);
					case "browser":
						menuItem.setPosition(shitJson.secondItemX + 380, shitJson.secondItemY);
				}
			}

		}

		// FlxG.camera.follow(camFollowPos, null, 1); //i removed that

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "VS AYED V " + ayedVersion, 12);
		versionShit.color = 0x1900FF;
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.CYAN, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' V" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.PINK, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		sumShit = new FlxText(FlxG.width - 644, 0, 0, "", 32);
		sumShit.updateHitbox();
		sumShit.text = "Click On Shift To See The Credits Of Menu BackGround";
		sumShit.scrollFactor.set();
		sumShit.setFormat("VCR OSD Mono", 16, FlxColor.BLACK, LEFT);
		add(sumShit);
		availableV = new FlxText(20, FlxG.height - 38, 0, "", 28);
		availableV.x = FlxG.width - (availableV.width + 250);

		var http = new haxe.Http("https://raw.githubusercontent.com/Jake-Official/FNF-AYED-ENGINE/refs/heads/main/gitVersion.txt");

		http.onData = function (data:String) {
        	updateEngineGit = data;
			var curEngine = ayedEngineVersion;
			trace('Online Version Engine : $updateEngineGit | Current Version Engine : $curEngine');
			if(updateEngineGit != curEngine){
				showUpdate = true;
				trace("Version Engine Isn't Matching");
				availableV.visible = true;
			}else{
				availableV.visible = false;
			}
        }

        http.onError = function (error) {
        trace('error: $error');
        }

        http.request();

		availableV.text = updateEngineGit;
		availableV.scrollFactor.set();
		availableV.setFormat("VCR OSD Mono", 32, FlxColor.CYAN, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		availableV.visible = false;
		add(availableV);


		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		shaderThing.update(elapsed);
		// assShader.set_iTime(elapsed); // not heck no
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if(showUpdate){
			availableV.visible = true;
		}else{
			availableV.visible = false;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxG.mouse.x / 4,  FlxG.mouse.y / 4);
		// camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			/**
			if(leavedTheState){
			FlxTween.tween(FlxG.camera, {
				'zoom': 1}, 1.2, {ease:FlxEase.circOut, onComplete:function(twnShit:FlxTween){
					selectedSomethin = false;
					FlxG.camera.zoom = 1;
					twnShit.destroy();
					return;
				}});
			}else{
				//nothing is going on just fuck me instead
			}
			**/
			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
			if(FlxG.keys.justPressed.F12){
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				MusicBeatState.switchState(new BattleAreaState());
			}

			for(what in menuItems.members){
				if(FlxG.mouse.overlaps(what)){

					curSelected = menuItems.members.indexOf(what);

					if(FlxG.mouse.pressed){
						selectedSomethin = true;

						FlxG.sound.play(Paths.sound('confirmMenu'), 1);
	
						var chooseItem:String = menushittyList[curSelected];

						menuItems.forEach(function(spr:FlxSprite) {
							if (curSelected != spr.ID) {
								FlxTween.tween(spr, {alpha: 0}, 0.4, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween) {
										spr.kill();
									// versionShitA.color = 0x4677FF;
									}
								});
							} else {	
								if(!ClientPrefs.hasBeated){
									switch (chooseItem) {
										case 'freeplay':
											FlxTween.tween(spr, {x: shitJson.selectedX, y: shitJson.selectedY}, 1.2, {ease:FlxEase.circInOut, onComplete:function(twnShit:FlxTween){
												MusicBeatState.switchState(new FreeplayState());
											}});
										case 'credits':
											FlxTween.tween(spr, {x: shitJson.selectedX, y: shitJson.selectedY}, 1.2, {ease:FlxEase.circInOut, onComplete:function(twnShit:FlxTween){
												MusicBeatState.switchState(new CreditsState());
											}});
										case 'options':
											FlxTween.tween(spr, {x: shitJson.selectedX, y: shitJson.selectedY}, 1.2, {ease:FlxEase.circInOut, onComplete:function(twnShit:FlxTween){
												MusicBeatState.switchState(new options.OptionsState());
											}});
										}
								}else{
									switch (chooseItem) {
										case 'freeplay':
											FlxTween.tween(spr, {x: shitJson.selectedX, y: shitJson.selectedY}, 1.2, {ease:FlxEase.circInOut, onComplete:function(twnShit:FlxTween){
												MusicBeatState.switchState(new FreeplayState());
											}});
										case 'credits':
											FlxTween.tween(spr, {x: shitJson.selectedX, y: shitJson.selectedY}, 1.2, {ease:FlxEase.circInOut, onComplete:function(twnShit:FlxTween){
												MusicBeatState.switchState(new CreditsState());
											}});
										case 'options':
											FlxTween.tween(spr, {x: shitJson.selectedX, y: shitJson.selectedY}, 1.2, {ease:FlxEase.circInOut, onComplete:function(twnShit:FlxTween){
												MusicBeatState.switchState(new options.OptionsState());
											}});
										case 'browser':
											if(FlxG.keys.justPressed.SHIFT){
												//new state shit for iframe LOLS
												//selectedSomethin = true;
												FlxG.sound.play(Paths.sound('confirmMenu'));
												// MusicBeatState.switchState(new IframeState());
											}else{
												FlxG.openURL('notYet.com/what_thefuck');
												MusicBeatState.resetState();
												// what	
											}
									}
								}
							}
						});
					}
				}
			}

			if(FlxG.keys.justPressed.SHIFT){
				selectedSomethin = true;
				trace("fucking hates tween's groups shit");
				FlxG.sound.play(Paths.sound("confirmMenu"));
				
				FlxTween.tween(FlxG.camera, {'zoom': 1.5}, 2, {ease:FlxEase.circOut, onComplete:function(twnShit:FlxTween){
					openSubState(new BackGroundCredits());
					twnShit.destroy();
				}});
			}

			var fs = controls.FULLSCREEN;

			if(fs){
				if(Application.current.window.fullscreen){
					Application.current.window.fullscreen = false;
					trace('Full Screen Is Turned Off');
				}else{
					Application.current.window.fullscreen = true;
					trace('Full Screen Is Turned On');
				}
			}

			/*
			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									#if MODS_ALLOWED
									case 'mods':
										MusicBeatState.switchState(new ModsMenuState());
									#end
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			*/
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}

typedef BackGroundCreditsTypeDef = {
	scaleXBg:Float,
	scaleYBg:Float,
	textCredX:Float,
	textCredY:Float,
	textAlpha:String
}

class BackGroundCredits extends MusicBeatSubstate{
	var bgCredits:FlxSprite;
	var alphabetC:Alphabet;
	var bg:FlxSprite;
	var bgShit:FlxSprite;
	var shitJson:BackGroundCreditsTypeDef;
	var alphabetN:Alphabet;

	override function create(){
		FlxG.mouse.visible = true;

		shitJson = Json.parse(Paths.getTextFromFile("images/JsonFileGame/BackgroundCreditsSetting.json", true));
		
		#if desktop
		trace("sometime i hates coding like FUCK");
		DiscordClient.changePresence("In the Credits BackGround Main Menu", null);
		#end

		bgShit = new FlxSprite(0, 0);
		bgShit.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bgShit.alpha = 0.5;
		add(bgShit);
		trace("Background Added");

		bgCredits = new FlxSprite(0, 50);
		bgCredits.loadGraphic(MainMenuState.loadImg);
		bgCredits.scale.x = shitJson.scaleXBg;
		bgCredits.scale.y = shitJson.scaleYBg;
		bgCredits.updateHitbox();
		bgCredits.screenCenter();
		add(bgCredits);

		alphabetC = new Alphabet(shitJson.textCredX, shitJson.textCredY, "", true);
		if(alphabetC.text == "Jake_Official"){
			alphabetC.x = FlxG.height - 70;
		}else{
			//nothing special!
		}
		// fucking hates coding and i love coding
		switch(MainMenuState.scrImg){
			case "artMainMenuBg/menuBG1":
				alphabetC.text = MainMenuState.creditsBG[0][0];
			case "artMainMenuBg/menuBG2":
				alphabetC.text = MainMenuState.creditsBG[0][0];
			case "artMainMenuBg/menuBG3":
				alphabetC.text = MainMenuState.creditsBG[1][0];
			case "artMainMenuBg/menuBG4":
				alphabetC.text = MainMenuState.creditsBG[1][0];
		}
		alphabetC.alpha=1;
		alphabetC.updateHitbox();
		add(alphabetC);

		super.create();
	}

	override function update(elapsed:Float){
		if(FlxG.keys.justPressed.ENTER){
			switch(MainMenuState.scrImg){
				case "artMainMenuBg/menuBG1":
					FlxG.openURL(MainMenuState.creditsBG[0][1]);
				case "artMainMenuBg/menuBG2":
					FlxG.openURL(MainMenuState.creditsBG[0][1]);
				case "artMainMenuBg/menuBG3":
					FlxG.openURL(MainMenuState.creditsBG[1][1]);
				case "artMainMenuBg/menuBG4":
					FlxG.openURL(MainMenuState.creditsBG[1][1]);
			}
		}
		if(FlxG.keys.justPressed.ESCAPE){
			close();
			MusicBeatState.resetState();
			// MainMenuState.leavedTheState = true; // da shit didn't work fuck you haxe
		}	
		super.update(elapsed);
	}
}