package creatures.forest;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;

enum SnailStates
{
    Normal;
    Squished;
    MovingSquished;
    Held; // Holding Iceblock added by AnatolyStev
}

class Snail extends Enemy
{
    var snailImage = FlxAtlasFrames.fromSparrow("assets/images/characters/snail.png", "assets/images/characters/snail.xml");

    public function new (x:Float, y:Float)
    {
        super(x, y);

        frames = snailImage;
        animation.addByPrefix('walk', 'walk', 10, true);
        animation.addByPrefix('flat', 'flat', 20, true);
        animation.play('walk');

        setSize(31, 29);
        offset.set(0, 4);

        canBeHeld = true;
        snail = true;
    }

    override private function move()
    {
        if (currentIceblockState == MovingSquished)
        {
            velocity.x = direction * walkSpeed * 6;
        }
        else if (currentIceblockState == Squished || currentIceblockState == Held)
        {
            velocity.x = 0;

            if (currentIceblockState == Held)
            {
                velocity.y = 0;
            }
        }
        else
        {
            velocity.x = direction * walkSpeed;
        }
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (currentIceblockState == Held && held != null)
        {
            if (held.flipX == true)
            {
                x = held.x - 8;
            }
            else if (held.flipX == false)
            {
                x = held.x + 11;
            }

            y = held.y;
            flipX = !held.flipX;
        }
    }
}