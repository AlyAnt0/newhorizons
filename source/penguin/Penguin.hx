package penguin;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

enum PenguinAction {
    Idle(direction: CardinalDirection);
    Moving(goal: FlxPoint);
    Sitting(direction: CardinalDirection);
    Dancing;
    Waving(waveTimer: Float);
}

class Penguin {
    // TODO(mvh): Penguin clothing state.  Should we use a separate class for this so we just have a simple API for it here,
    //            rather than having to also deal with all the clothing stuff here.

    public var x:Float = 0;
    public var y:Float = 0;

    // Action state.
    private var currentAction: PenguinAction;
    private var actionJustChanged: Bool;

    // Sprite state.
    private var penguinSprite: FlxSprite;
    private var sprites: Array<FlxSprite>;

    // Text state.
    private var penguinName: FlxText;

    // Constants.
    private final speed: Float = 200;
    private final waveDuration: Float = 1.33;
    private final fadeOutDistance: Float = 105;
    private final fadeMultiplier: Float = 3;


    // Constructor
    public function new(X: Float = 0, Y: Float = 0) {
        if (sprites == null) sprites = new Array<FlxSprite>();

        this.x = X;
        this.y = Y;

        loadPenguinSprite(x, y);
        loadPenguinName();

        updatePosition();
        trace('created penguin!');

        setIdle(North);
    }

    // General updates.
    public function update(elapsed: Float): Void {
        switch (currentAction) {
            case Idle(direction): updateIdle(elapsed, direction);
            case Moving(goal): updateMoving(elapsed, goal);
            case Sitting(direction): updateSitting(elapsed, direction);
            case Dancing: updateDancing(elapsed);
            case Waving(waveTimer): updateWaving(elapsed, waveTimer);
        }
        actionJustChanged = false;

        updatePosition();
    }

    public function updatePosition():Void
    {
        penguinSprite.x = this.x;
        penguinSprite.y = this.y;

        var textWidth: Float = penguinName.width;
        penguinName.x = penguinSprite.x - (textWidth / 2) + (penguinSprite.width / 2);
        penguinName.y = penguinSprite.y + 150;
    }

    // Sprite getters.
    public function getSprites(): Array<FlxSprite> {
        return sprites;
    }
    public function getPenguinSprite(): FlxSprite {
        return penguinSprite;
    }

    // Text getters.
    public function getPenguinName(): FlxText {
        return penguinName;
    }

    // Action setters.
    public function setIdle(direction: CardinalDirection) {
        currentAction = Idle(direction);
        actionJustChanged = true;
    }
    public function setMoving(goalX: Float, goalY: Float) {
        currentAction = Moving(FlxPoint.get(goalX, goalY));
        trace(goalX, goalY);
        actionJustChanged = true;
    }
    public function setSitting(direction: CardinalDirection) {
        currentAction = Sitting(direction);
        actionJustChanged = true;
    }
    public function setDancing() {
        currentAction = Dancing;
        actionJustChanged = true;
    }
    public function setWaving(waveTimer: Float = 0) {
        currentAction = Waving(waveTimer);
        actionJustChanged = true;
    }

    // Action updates.
    private function updateIdle(elapsed: Float, direction: CardinalDirection): Void {
        switch (direction) {
            case North:     penguinSprite.animation.play("idle_N");
            case NorthEast: penguinSprite.animation.play("idle_NE");
            case East:      penguinSprite.animation.play("idle_E");
            case SouthEast: penguinSprite.animation.play("idle_SE");
            case South:     penguinSprite.animation.play("idle_S");
            case SouthWest: penguinSprite.animation.play("idle_SW");
            case West:      penguinSprite.animation.play("idle_W");
            case NorthWest: penguinSprite.animation.play("idle_NW");
        }
    }
    private function updateMoving(elapsed: Float, goal: FlxPoint): Void {
        var direction: FlxPoint = FlxPoint.get(goal.x - penguinSprite.x, goal.y - penguinSprite.y);
        var distance: Float = Math.sqrt(direction.x * direction.x + direction.y * direction.y);
        var moveAngle: Float = Math.atan2(direction.y, direction.x) * (180 / Math.PI);

        // Check if penguin will be past goal.
        if (distance < speed * elapsed) {
            penguinSprite.x = goal.x;
            penguinSprite.y = goal.y;
            setIdle(angleToDirection(moveAngle)); // TODO(mvh): decide on the direction based on the direction vector.
            return;
        }

        direction.normalize();
        x += direction.x * speed * elapsed;
        y += direction.y * speed * elapsed;

        // Determine walking animation and update currentDirection
        switch (angleToDirection(moveAngle)) {
            case North:     penguinSprite.animation.play("walk_N");
            case NorthEast: penguinSprite.animation.play("walk_NE");
            case East:      penguinSprite.animation.play("walk_E");
            case SouthEast: penguinSprite.animation.play("walk_SE");
            case South:     penguinSprite.animation.play("walk_S");
            case SouthWest: penguinSprite.animation.play("walk_SW");
            case West:      penguinSprite.animation.play("walk_W");
            case NorthWest: penguinSprite.animation.play("walk_NW");
        }
    }
    private function updateSitting(elapsed: Float, direction: CardinalDirection): Void {
        // TODO(mvh): Give the player the ability to change what direction they sit in.
        if (actionJustChanged) {
            switch (direction) {
                case North:     penguinSprite.animation.play("sit_N");
                case NorthEast: penguinSprite.animation.play("sit_NE");
                case East:      penguinSprite.animation.play("sit_E");
                case SouthEast: penguinSprite.animation.play("sit_SE");
                case South:     penguinSprite.animation.play("sit_S");
                case SouthWest: penguinSprite.animation.play("sit_SW");
                case West:      penguinSprite.animation.play("sit_W");
                case NorthWest: penguinSprite.animation.play("sit_NW");
            }
        }
    }
    private function updateDancing(elapsed: Float): Void {
        if (actionJustChanged) penguinSprite.animation.play("dance", true);
    }
    private function updateWaving(elapsed: Float, waveTimer: Float): Void {
        if (actionJustChanged) penguinSprite.animation.play("wave", true);

        waveTimer += elapsed;
        if (waveTimer >= waveDuration) {
            setIdle(North);
            return;
        }

        currentAction = Waving(waveTimer);
    }

    // Load the penguin sprite related stuff.
    private function loadPenguinSprite(X: Float, Y: Float) {
        // Load the texture atlas
        var penguinGraphic: FlxGraphic = FlxG.bitmap.add("assets/images/player/player.png");
        var penguinFrames: FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(penguinGraphic, "assets/images/player/player.json");

        penguinSprite = new FlxSprite(X, Y);
        penguinSprite.frames = penguinFrames; // Set the frames from your atlas //player.loadGraphic("assets/images/player.png");
        //player.animation.addByPrefix("idle", "0_idle", 12, true); // '0_idle' is the prefix common in all frames

        penguinSprite.animation.add("idle_N", [0], 0, false);
        penguinSprite.animation.add("idle_NW", [1], 0, false);
        penguinSprite.animation.add("idle_W", [2], 0, false);
        penguinSprite.animation.add("idle_SW", [3], 0, false);
        penguinSprite.animation.add("idle_S", [4], 0, false);
        penguinSprite.animation.add("idle_SE", [5], 0, false);
        penguinSprite.animation.add("idle_E", [6], 0, false);
        penguinSprite.animation.add("idle_NE", [7], 0, false);

        penguinSprite.animation.add("walk_N", [8, 9, 10, 11, 12, 13, 14, 15], 13, true); 
        penguinSprite.animation.add("walk_NW", [16, 17, 18, 19, 20, 21, 22, 23], 13, true); 
        penguinSprite.animation.add("walk_W", [24, 25, 26, 27, 28, 29, 30, 31], 13, true); 
        penguinSprite.animation.add("walk_SW", [32, 33, 34, 35, 36, 37, 38, 39], 13, true); 
        penguinSprite.animation.add("walk_S", [40, 41, 42, 43, 44, 45, 46, 47], 13, true); 
        penguinSprite.animation.add("walk_SE", [48, 49, 50, 51, 52, 53, 54, 55], 13, true); 
        penguinSprite.animation.add("walk_E", [56, 57, 58, 59, 60, 61, 62, 63], 13, true); 
        penguinSprite.animation.add("walk_NE", [64, 65, 66, 67, 68, 69, 70, 71], 13, true);

        penguinSprite.animation.add("sit_N", [398,72], 13, false);
        penguinSprite.animation.add("sit_NW", [400,73], 13, false);
        penguinSprite.animation.add("sit_W", [402,74], 13, false);
        penguinSprite.animation.add("sit_SW", [404,75], 13, false);
        penguinSprite.animation.add("sit_S", [406,76], 13, false);
        penguinSprite.animation.add("sit_SE", [408,77], 13, false);
        penguinSprite.animation.add("sit_E", [410,78], 13, false);
        penguinSprite.animation.add("sit_NE", [412,79], 13, false);

        penguinSprite.animation.add("sit_N_ifidle", [397,398,72], 13, false);
        penguinSprite.animation.add("sit_NW_ifidle", [399,400,73], 13, false);
        penguinSprite.animation.add("sit_W_ifidle", [401,402,74], 13, false);
        penguinSprite.animation.add("sit_SW_ifidle", [403,404,75], 13, false);
        penguinSprite.animation.add("sit_S_ifidle", [405,406,76], 13, false);
        penguinSprite.animation.add("sit_SE_ifidle", [407,408,77], 13, false);
        penguinSprite.animation.add("sit_E_ifidle", [409,410,78], 13, false);
        penguinSprite.animation.add("sit_NE_ifidle", [411,412,79], 13, false);

        penguinSprite.animation.add("wave", [80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 88, 91, 91, 87, 88, 89, 90, 88, 91, 91, 87, 88, 89, 90, 88, 91, 91, 87, 88, 89, 90, 90, 90, 90], 13, false);

        penguinSprite.animation.addByPrefix("dance", "4_dance", 13, true); 

        penguinSprite.centerOrigin();
        penguinSprite.screenCenter();

        addSprite(penguinSprite);
    }

    private function addSprite(sprite: FlxSprite): Void {
        sprites.push(sprite);
    }

    private function loadPenguinName() {
        penguinName = new FlxText(0, 0, 0, "Penguin", 18);
        penguinName.setFormat("Arial", 24, 0x000000, "center"); // Black color
    }

    private function angleToDirection(angle: Float): CardinalDirection {
        if (angle < 0) angle += 360;

        // Determine walking animation and update currentDirection
        if (angle >= 337.5 || angle < 22.5) return East;
        if (angle >= 22.5 && angle < 67.5) return NorthEast;
        if (angle >= 67.5 && angle < 112.5) return North;
        if (angle >= 112.5 && angle < 157.5) return NorthWest;
        if (angle >= 157.5 && angle < 202.5) return West;
        if (angle >= 202.5 && angle < 247.5) return SouthWest;
        if (angle >= 247.5 && angle < 292.5) return South;
        //if (angle >= 292.5 && angle < 337.5) {
            return SouthEast;
        //}
    }
}
