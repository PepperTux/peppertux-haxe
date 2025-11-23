package objects;

import creatures.Tux;
import flixel.util.FlxColor;
import flixel.FlxSprite;

class SolidKill extends FlxSprite
{
    public function new(x:Float, y:Float, width:Int, height:Int)
    {
        super(x, y);
        makeGraphic(width, height, FlxColor.TRANSPARENT);
        solid = true;
        immovable = true;
    }

    public function interact(tux:Tux)
    {
        tux.die();
    }
}