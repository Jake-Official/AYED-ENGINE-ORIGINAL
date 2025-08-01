package;

import Sys.sleep;
import discord_rpc.DiscordRpc;

using StringTools;

#if LUA_ALLOWED
import llua.Lua;
import llua.State;
#end

class DiscordClient
{
	public static var isInitialized:Bool = false;

	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "1338655375297220669",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "Friday Night Funkin'",
			state: null,
			largeImageKey: 'discord_percht',
			smallImageKey: 'ayed_mad_shit',
			largeImageText: "AYED ENGINE DEMO"
			// Button1Text: 'you wanna play mods',
			// Button1URL: 'https://www.youtube.com/watch?v=SQl6uFQAuZU&t=84s'
		});
	}
	public static function changeIdClient(idClient:String){
		DiscordRpc.start({
			clientID: idClient,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
	}

	#if LUA_ALLOWED
	public static function addLuaIDChange(lua:State){
		Lua_helper.add_callback(lua, "ChangeIDClient", 
		function(idClient:String){
			changeIdClient(idClient);
		});
	}
	#end

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'discord_percht',
			largeImageText: "AYED ENGINE " + MainMenuState.ayedEngineVersion,
			smallImageKey: 'ayed_mad_shit',
			smallImageText: 'ayed fucking staring at ya',
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	#if LUA_ALLOWED
	public static function addLuaCallbacks(lua:State)
	{
		Lua_helper.add_callback(lua, "changePresence",
			function(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
			{
				changePresence(details, state, smallImageKey, hasStartTimestamp, endTimestamp);
			});
	}
	#end
}
