package objects;

import flixel.FlxObject;
import flixel.FlxG;
import creatures.Tux;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class Trampoline extends FlxSprite
{
    var minBounceHeight = 512;
    var maxBounceHeight = 900;
    var trampolineImage = FlxAtlasFrames.fromSparrow('assets/images/objects/trampoline.png', 'assets/images/objects/trampoline.xml');

    public function new(x:Float, y:Float) 
    {
        super(x, y);
        solid = true;
        immovable = true;

        frames = trampolineImage;
        animation.addByPrefix("normal", "normal", 10, false);
        animation.addByPrefix("bounce", "bounce", 10, false);
        animation.play("normal");
    }

    public function bounceTux(tux:Tux)
    {
        FlxObject.separateX(this, tux);

        if (isTouching(UP))
        {
            animation.play("bounce");
            FlxG.sound.play("assets/sounds/trampoline.wav", 1, false);

            if (FlxG.keys.anyPressed([SPACE, UP, W]))
            {
                tux.velocity.y = -maxBounceHeight;
            }
            else
            {
                tux.velocity.y = -minBounceHeight;
            }
        }
    }
}