package creatures.snow;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;

enum IceblockStates
{
    Normal;
    Squished;
    MovingSquished;
    Held; // Holding Iceblock added by AnatolyStev
}

class Iceblock extends Enemy
{
    var iceblockImage = FlxAtlasFrames.fromSparrow("assets/images/characters/iceblock.png", "assets/images/characters/iceblock.xml");

    public var currentIceblockState = Normal;

    var waitToCollide:Float = 0;

    public var held:Tux = null;

    public function new (x:Float, y:Float)
    {
        super(x, y);

        frames = iceblockImage;
        animation.addByPrefix('walk', 'walk', 10, true);
        animation.addByPrefix('flat', 'flat', 10, false);
        animation.play('walk');

        setSize(31, 29);
        offset.set(2, 9);
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

        if (waitToCollide > 0)
        {
            waitToCollide -= elapsed;
        }

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

        if (justTouched(WALL) && isOnScreen() && currentIceblockState == MovingSquished)
        {
            trace("Hit Wall!");
            FlxG.sound.play("assets/sounds/ricochet.wav", 1.0, false);
        }
    }

    public function pickUp(tux:Tux)
    {
        if (currentIceblockState != Squished || held != null)
        {
            return;
        }

        currentIceblockState = Held;
        held = tux;
        solid = false;
        velocity.x = 0;
        velocity.y = 0;
        animation.play("flat");
    }

    public function iceblockThrow() // I couldn't be BOTHERED to make it so damageOthers and stuff is set to true when MovingSquished is the state :)
    {
        if (currentIceblockState != Held || held == null)
        {
            return;
        }

        currentIceblockState = MovingSquished;
        direction = held.direction;
        flipX = !held.flipX;
        solid = true;
        damageOthers = true;
        held = null;
        waitToCollide = 0.25;
        FlxG.sound.play("assets/sounds/kick.wav");
    }

    override public function interact(tux:Tux)
    {
        if (!alive || waitToCollide > 0)
        {
            return;
        }

        if (currentIceblockState == MovingSquished)
        {
            damageOthers = true;
        }

        checkIfHerring(tux);

        FlxObject.separateY(this, tux);

        if (currentIceblockState == MovingSquished)
        {
            if (tux.velocity.y > 0 && tux.y + tux.height < y + 10 && tux.invincible == false)
            {
                waitToCollide = 0.25;
                currentIceblockState = Squished;
                Global.score += scoreAmount;
                animation.play("flat");
                velocity.x = 0;
                if (FlxG.keys.anyPressed([SPACE, UP, W]))
                {
                    tux.velocity.y = -tux.maxJumpHeight;
                }
                else
                {
                    tux.velocity.y = -tux.minJumpHeight / 2;
                }
            }
            else
            {
                if (tux.invincible == false)
                {
                    tux.takeDamage();
                }
            }
        }
        else if (currentIceblockState == Squished)
        {
            if (tux.velocity.y > 0 && tux.y + tux.height < y + 10 && tux.invincible == false)
            {
                if (FlxG.keys.anyPressed([SPACE, UP, W]))
                {
                    tux.velocity.y = -tux.maxJumpHeight;
                }
                else
                {
                    tux.velocity.y = -tux.minJumpHeight / 2;
                }
            }

            waitToCollide = 0.25;

            if (!isTouching(UP) && FlxG.keys.pressed.CONTROL && (tux.heldSnail == null || tux.heldIceblock == null)) // Longest IF statement award goes to THIS one here (Made by AnatolyStev)
            {
                tux.holdIceblock(this);
                return;
            }

            direction = tux.direction;
            flipX = !tux.flipX;
            currentIceblockState = MovingSquished;
            damageOthers = true;
        }
        else
        {
            if (tux.velocity.y > 0 && tux.y + tux.height < y + 10 && tux.invincible == false)
            {
                waitToCollide = 0.25;
                Global.score += scoreAmount;
                animation.play("flat");
                currentIceblockState = Squished;
                velocity.x = 0;
                if (FlxG.keys.anyPressed([SPACE, UP, W]))
                {
                    tux.velocity.y = -tux.maxJumpHeight;
                }
                else
                {
                    tux.velocity.y = -tux.minJumpHeight / 2;
                }
            }
            else
            {
                if (tux.invincible == false)
                {
                    tux.takeDamage();
                }
            }
        }
    }
}