package penguin;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class PenguinControllable extends Penguin {
    // Sprite state.
    private var targetSprite: FlxSprite;
    private var circleSprite: FlxSprite;
    private var clickCollisionSprite: FlxSprite;

    // Mouse state.
    private var lastMousePos: FlxPoint;
    private var usingCachedMousePos: Bool;

    // Constructor.
    override public function new(X: Float, Y: Float,
                                 flxStateAddCallback: FlxBasic -> FlxBasic,
                                 flxGroupAddCallback: FlxBasic -> FlxBasic = null) {
        if (sprites == null) sprites = new Array<FlxSprite>();
        if (flxStateAdd == null) flxStateAdd = flxStateAddCallback;
        if (flxGroupAdd == null) flxGroupAdd = flxGroupAddCallback;

        loadTargetSprite(X, Y);
        loadCircleSprite(X, Y);
        loadClickCollisionSprite(X, Y);

        super(X, Y, flxStateAddCallback, flxGroupAddCallback);

    }

    // General updates.
    override public function update(elapsed: Float): Void {
        handleInput();
        super.update(elapsed);

        circleSprite.x = penguinSprite.x + ((penguinSprite.width / 2) - (circleSprite.width / 2));
        circleSprite.y = penguinSprite.y + ((penguinSprite.height / 2) - (circleSprite.height / 2));

        clickCollisionSprite.x = penguinSprite.x + ((penguinSprite.width / 2) - (circleSprite.width / 2));
        clickCollisionSprite.y = penguinSprite.y + ((penguinSprite.height / 2) - (circleSprite.height / 2)) - 31;
    }

    // Action setters.
    override public function setIdle(direction: CardinalDirection) {
        targetSprite.visible = false; // TODO(mvh): Also handle the cases where the walk is interupted rather than just ending.

        lastMousePos = FlxPoint.get(FlxG.mouse.x, FlxG.mouse.y);
        usingCachedMousePos = true;

        super.setIdle(direction);
    }
    override public function setMoving(goalX: Float, goalY: Float) {
        final min: FlxPoint = FlxPoint.get( 182, 819);
        final max: FlxPoint = FlxPoint.get(1257, 900);

        if (goalX > min.x && goalX < max.x && goalY > min.x && goalY < max.y) {
            targetSprite.x = goalX - targetSprite.origin.x;
            targetSprite.y = goalY - targetSprite.origin.y;
            targetSprite.visible = true;
            targetSprite.alpha = 1;
            var targetX: Float = goalX - penguinSprite.origin.x;
            var targetY: Float = goalY - penguinSprite.origin.y;

            super.setMoving(targetX, targetY);
        }
    }

    // Action updates.
    override private function updateIdle(elapsed: Float, direction: CardinalDirection): Void {
        if (actionJustChanged == true) {
            super.updateIdle(elapsed, direction);
            return;
        }

        final maxMouseDistance: Float = 150;

        final mouseMoveDelta: FlxPoint = FlxPoint.get(
            FlxG.mouse.x - lastMousePos.x,
            FlxG.mouse.y - lastMousePos.y);
        final mouseMoveDistance: Float = Math.sqrt(
            mouseMoveDelta.x * mouseMoveDelta.x
          + mouseMoveDelta.y * mouseMoveDelta.y);

        final mouseDelta: FlxPoint = FlxPoint.get(
            FlxG.mouse.x - (penguinSprite.x + penguinSprite.width / 2),
            FlxG.mouse.y - (penguinSprite.y + penguinSprite.height / 2.75));
        final mouseAngle: Float = Math.atan2(mouseDelta.y, mouseDelta.x) * (180 / Math.PI);

        if (usingCachedMousePos == false || mouseMoveDistance > maxMouseDistance) {
            usingCachedMousePos = false;
            super.updateIdle(elapsed, angleToDirection(mouseAngle));
            return;
        }

        super.updateIdle(elapsed, direction);

    }

    // Handle keyboard input.
    private function handleInput(): Void {
        if (FlxG.keys.justPressed.W) setWaving();
        if (FlxG.keys.justPressed.S) setSitting(North);
        if (FlxG.keys.justPressed.D) setDancing();
        if (FlxG.mouse.justPressed) setMoving(FlxG.mouse.x, FlxG.mouse.y);

        if (FlxG.keys.justPressed.UP) setSitting(South); // Why is up south?
        if (FlxG.keys.justPressed.DOWN) setSitting(North); // Why is down north?
        if (FlxG.keys.justPressed.LEFT) setSitting(West);
        if (FlxG.keys.justPressed.RIGHT) setSitting(East);
    }

    // Load the target sprite related stuff.
    private function loadTargetSprite(X: Float, Y: Float): Void {
        targetSprite = new FlxSprite();
        targetSprite.loadGraphic("assets/images/targetcircle.png");
        targetSprite.centerOrigin();
        targetSprite.alpha = 1;
        targetSprite.visible = false; // Initially invisible
        addSprite(targetSprite);
    }

    // Load the circle sprite related stuff.
    private function loadCircleSprite(X: Float, Y: Float): Void {
        circleSprite = new FlxSprite(X, Y);
        circleSprite.loadGraphic("assets/images/playercircle.png");
        circleSprite.centerOrigin();
        addSprite(circleSprite);
    }

    // Load the click collisions sprite related stuff.
    private function loadClickCollisionSprite(X: Float, Y: Float): Void {
        clickCollisionSprite = new FlxSprite(X, Y);
        clickCollisionSprite.loadGraphic("assets/images/player/collision.png");
        clickCollisionSprite.centerOrigin();
        clickCollisionSprite.visible = true;
        //addSprite(clickCollisionSprite);
    }
}
