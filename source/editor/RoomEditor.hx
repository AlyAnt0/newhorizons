package editor;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxState;

class RoomEditor extends FlxState
{
	var backgroundLayersDataLoaded:Array<Dynamic> = [];
	var backgroundLayers:FlxGroup;

	var layersDatas:Array<Dynamic> = [];

	override function create():Void
	{
		bgColor = 0xff888888;
		super.create();
	}

	override function update(elapsed:Float):Void
	{
		

		super.update(elapsed);
	}

	function createObject(data:Dynamic):Void
	{
		
	}
}