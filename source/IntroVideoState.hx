package;

import flixel.FlxG;
import sys.FileSystem;
#if VIDEOS_ALLOWED
import vlc.MP4Handler;
#end

class IntroVideoState extends MusicBeatState {
    var video:MP4Handler;
    var name:String = 'hell';

    override function create(){
        #if VIDEOS_ALLOWED
		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
            return;
            // FlxG.sys.exit();
		}

		video = new MP4Handler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			_NextStates();
		}
		#else
		FlxG.log.warn('Platform not supported!');
        FlxG.sys.exit(1);
		return;
		#end
    }
    override function update(elapsed:Float){
        if(FlxG.keys.justPressed.ENTER){
			video.stop();
			_NextStates();
        }
		// if the video tag was in update it's will be getting laggy for loop shit -jake_Official
        super.update(elapsed);
    }
	function _NextStates(){
		trace("Video Has Been Stopped Or Done And Now Next State");
		MusicBeatState.switchState(new TitleState());
	}
}