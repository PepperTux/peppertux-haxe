package objects;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class Fireball extends FlxSprite
{
    var moveSpeed = 440;
    var jumpHeight = 320;
    var gravity = 1000;

    public var direction = -1;

    var howManyBounces = 3;
    var bounces = 0;

    var fireballImage = FlxAtlasFrames.fromSparrow("assets/images/objects/firebullet.png", "assets/images/objects/firebullet.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = fireballImage;
        animation.addByPrefix('normal', 'normal', 12, true);
        animation.play('normal');

        acceleration.y = gravity;
    }

    override public function update(elapsed:Float)
    {
        velocity.x = direction * moveSpeed;

        if (justTouched(FLOOR))
        {
            velocity.y -= jumpHeight;
            bounces += 1;
        }

        if (bounces == howManyBounces)
        {
            kill();
        }

        if (justTouched(WALL) || justTouched(CEILING))
        {
            kill();
        }

        super.update(elapsed);
    }
}