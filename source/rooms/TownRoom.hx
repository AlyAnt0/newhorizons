package rooms;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

import penguin.Penguin;
import penguin.PenguinControllable;

class TownRoom extends FlxState {
    var backgroundAssets: AssetLoader;
    var foregroundAssets: AssetLoader;
    var roomAssets: AssetLoader;
    var userInterfaceAssets: AssetLoader;

    var penguin: Penguin;

    var renderGroup:FlxGroup;

    ///////// CREATE /////////
    override public function create():Void
    {
        super.create();

        FlxG.autoPause = false; // Disable automatic pausing when the window loses focus
        FlxG.mouse.useSystemCursor = true; // Use native system cursor instead of Haxeflixel's

        loadBackgroundAssets();
        loadRoomAssets();
        loadPlayer();
        setupRenderGroup();
        loadForegroundAssets();

        add(penguin.getPenguinName());

        loadUserInterfaceAssets();
    }

    ///////// UPDATE /////////
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        penguin.update(elapsed);

        renderGroup.members.sort(orderByY);

        // TODO(mvh): This is an example of room switching. In the future, use collision with triggers to switch the state.
        //            You could also do something similar to start a minigame. Though in that case there should also be a
        //            confirmation box.
        // TODO(mvh): Figure out how to do a loading screen when loading the next scene/room/minigame.
        if (FlxG.keys.justPressed.SPACE) FlxG.switchState(PlayState.new);
    }

    // Function to sort objects by Y value for draw order
    private function orderByY(a:FlxBasic, b:FlxBasic):Int {
        var spriteA:FlxSprite = cast a;
        var spriteB:FlxSprite = cast b;

        // Sort based on the y-position plus origin y
        var posA = spriteA.y + spriteA.origin.y;
        var posB = spriteB.y + spriteB.origin.y;

        if (posA < posB) return -1;
        if (posA > posB) return 1;
        return 0;
    }

    private function loadBackgroundAssets(): Void {
        backgroundAssets = new AssetLoader();
        backgroundAssets.loadSprites("assets/images/rooms/town/town_background.json");
        for (asset in backgroundAssets.getAssets()) add(asset.sprite);
    }

    private function loadRoomAssets(): Void {
        roomAssets = new AssetLoader();
        roomAssets.loadSprites("assets/images/rooms/town/town_room.json");
        for (asset in roomAssets.getAssets()) add(asset.sprite);
    }

    private function loadPlayer(): Void {
        penguin = new PenguinControllable(581, 516);
        for (sprite in penguin.getSprites()) add(sprite);
    }

    private function setupRenderGroup(): Void {
        renderGroup = new FlxGroup();

        // Room
        for (asset in roomAssets.getAssets()) renderGroup.add(asset.sprite);
        // Penguin
        renderGroup.add(penguin.getPenguinSprite());

        add(renderGroup);
    }

    private function loadForegroundAssets(): Void {
        foregroundAssets = new AssetLoader();
        foregroundAssets.loadSprites("assets/images/rooms/town/town_foreground.json");
        for (asset in foregroundAssets.getAssets()) add(asset.sprite);
    }

    private function loadUserInterfaceAssets(): Void {
        userInterfaceAssets = new AssetLoader();
        userInterfaceAssets.loadSprites("assets/images/userInterface.json");
        for (asset in userInterfaceAssets.getAssets()) add(asset.sprite);
    }
}
