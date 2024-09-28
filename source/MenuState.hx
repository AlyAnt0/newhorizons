package;

import flixel.FlxState;
import flixel.ui.FlxSpriteButton;
import flixel.FlxSprite;
import flixel.FlxG;


class MenuState extends FlxState{

    var menuPictures = null; // for login promo images

    var createPenguin:FlxSpriteButton;
    var createPenguinSprite:FlxSprite;

    var login:FlxSpriteButton;
    var loginSprite:FlxSprite;


    override public function create(){
        FlxG.autoPause = false; // Disable automatic pausing when the window loses focus
        FlxG.mouse.useSystemCursor = true; // Use native system cursor instead of Haxeflixel's
            
        // TODO: For some reason, it seems to override the background when loading the MenuState, replacing corebackground with a black screen.


        super.create();

        // createPenguinSprite.loadGraphic("assets/");
        // createPenguin = new FlxButton(0,0, "Create a Penguin", null);
        // add(createPenguin); 

        loginSprite = new FlxSprite().loadGraphic("assets/player.png");
        login = new FlxSpriteButton(0,0, loginSprite, loginPrompt);
        add(login);
        

        
        login.screenCenter();
    }

    function createPenguinPrompt(){
        // TODO
    }

    function loginPrompt(){
        // TODO - until login implemented, this button will simply open the local instance.
        FlxG.switchState(new PlayState());
    }


}