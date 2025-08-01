package;

import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxSprite;
import haxe.Json;
import flixel.FlxCamera;
import flixel.text.FlxText;

typedef ItemEditor = {
    fightX:Float,
    fightY:Float,
    fleeX:Float,
    fleeY:Float,
    itemsX:Float,
    itemsY:Float,
    partyX:Float,
    partyY:Float,
    backGroundColor:FlxColor,
    loadImgBg:String
}

class BattleAreaState extends MusicBeatState{
    var bgShit:FlxSprite;
    // var mouseE:FlxMouse;
    var camHUD:FlxCamera;
    // var curSeleted:Int = -1;
    var itemShit:ItemEditor;
    public var buttonName:Array<String> = ["fight", "items", "flee", "party"];
    var groupShit:FlxTypedGroup<FlxSprite>;

    var colorGuess:Array<String> = ["WHITE", "BLACK", "RED", "YELLOW", "GREEN", "CYAN", "GRAY", "BLUE"];

    override function create(){
        FlxG.mouse.visible = true;

        #if desktop
        DiscordClient.changePresence("In The BattleAreaState", null);
        #end

        itemShit = Json.parse(Paths.getTextFromFile("images/Item/JSON/itemsEditor.json", false));

        bgShit = new FlxSprite(0, 0);
        if(itemShit.loadImgBg == null){
            bgShit.makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
            // this thing is just when backgroundcolor 
        }else{
            bgShit.loadGraphic(Paths.image("Item/" + itemShit.loadImgBg));
        }
        bgShit.updateHitbox();
        add(bgShit);

        trace("Function Running Complete");

        groupShit = new FlxTypedGroup<FlxSprite>();
        add(groupShit);

        for(i in 0...buttonName.length){
            var sprite:FlxSprite = new FlxSprite(500, 500);
            sprite.loadGraphic(Paths.image("Item/" + buttonName[i]));
            sprite.updateHitbox();
            sprite.ID = i;
            groupShit.add(sprite);
            // curSeleted = i;
            sprite.antialiasing = ClientPrefs.globalAntialiasing;

            switch(buttonName[i]){
                case "fight":
                    sprite.setPosition(itemShit.fightX, itemShit.fightY);
                case "items":
                    sprite.setPosition(itemShit.itemsX, itemShit.itemsY);
                case "flee":
                    sprite.setPosition(itemShit.fleeX, itemShit.fleeY);
                case "party":
                    sprite.setPosition(itemShit.partyX, itemShit.partyY);
            }
        }

        super.create();
    }
    var curSelected:Int;

    override function update(elapsed:Float){
        if(FlxG.keys.justPressed.ESCAPE){
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new MainMenuState());
        }
        for(item in groupShit.members){
            if(FlxG.mouse.overlaps(item)){
                
                curSelected = groupShit.members.indexOf(item);
                
                if(FlxG.mouse.pressed){
                    FlxG.sound.play(Paths.sound('confirmMenu'), 1);
                    
                    var chooseItem:String = buttonName[curSelected];

                    groupShit.forEach(function(spr:FlxSprite){
                        if (curSelected != spr.ID) {
                            //nothing to do with it
                            return;
                        } else {	
                            switch(chooseItem){
                                case 'fight':
                                    FlxG.sound.play(Paths.sound("confirmMenu"));
                                case 'flee':
                                    FlxG.sound.play(Paths.sound("confirmMenu"));
                                case 'items':
                                    FlxG.sound.play(Paths.sound("confirmMenu"));
                                case 'party':
                                    FlxG.sound.play(Paths.sound("confirmMenu"));
                            }
                        }
                    });
                }
            }
        }
        super.update(elapsed);
    }
}