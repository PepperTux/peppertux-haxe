package creatures.snow;

// This uses the floaing platform code but modified.

import objects.Fireball;
import flixel.graphics.frames.FlxAtlasFrames;

class Crystallo extends Enemy
{
    public var minX:Float;
    public var maxX:Float;

    var crystalloImage = FlxAtlasFrames.fromSparrow("assets/images/characters/crystallo.png", "assets/images/characters/crystallo.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = crystalloImage;

        animation.addByPrefix('walk', 'crystallo walk', 8, true);
        animation.addByPrefix('squished', 'crystallo squished', 8, false);
        animation.play('walk');

        minX = x - 100;
        maxX = x + 100;

        setSize(39, 28);
        offset.set(4, 0);
    }

    override private function move()
    {
        velocity.x = direction * walkSpeed;

        if (x > maxX && direction > 0) // To actually like stop it from flipping every frame, there's a thing that checks for direction here.
        {
            flipDirection();
        }
        else if (x < minX && direction < 0) // Same here.
        {
            flipDirection();
        }
    }

    override public function collideFireball(fireball:Fireball)
    {
        fireball.kill();
    }
}