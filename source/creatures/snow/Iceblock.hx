package creatures.snow;

import creatures.Enemy;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;

class Iceblock extends Enemy
{
    var iceblockImage = FlxAtlasFrames.fromSparrow("assets/images/characters/iceblock.png", "assets/images/characters/iceblock.xml");

    public function new (x:Float, y:Float)
    {
        super(x, y);

        frames = iceblockImage;
        animation.addByPrefix('walk', 'walk', 10, true);
        animation.addByPrefix('flat', 'flat', 10, false);
        animation.play('walk');

        setSize(31, 29);
        offset.set(2, 9);

        canBeHeld = true;
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