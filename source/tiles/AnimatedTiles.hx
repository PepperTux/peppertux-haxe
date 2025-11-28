package tiles;

import flixel.FlxSprite;

class Flag extends FlxSprite
{
    var framesPS = 12;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("assets/images/animatedtiles/flag.png", true, 32, 32);
        animation.add("normal", [0, 1], framesPS, true);
        animation.play("normal");
    }
}

class WaterNew extends FlxSprite
{
    var framesPS = 16;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("assets/images/animatedtiles/water.png", true, 128, 32);
        animation.add("normal", [0, 1, 2, 3, 4, 5, 6, 7], framesPS, true);
        animation.play("normal");
    }
}

class Lava extends FlxSprite
{
    var framesPS = 16;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        loadGraphic("assets/images/animatedtiles/lava.png", true, 128, 32);
        animation.add("normal", [0, 1, 2, 3, 4, 5, 6, 7], framesPS, true);
        animation.play("normal");
    }
}