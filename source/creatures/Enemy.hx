package creatures;

// Original file by Vaesea
// Very simple Jumpy fix by AnatolyStev
// Holding Iceblock code originally by AnatolyStev, improved by Vaesea.

import flixel.sound.FlxSound;
import objects.Fireball;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

enum EnemyStates
{
    Alive;
    Dead;
}

enum IceblockStates
{
    Normal;
    Squished;
    MovingSquished;
    Held; // Holding Iceblock added by AnatolyStev
}

class Enemy extends FlxSprite
{
    var fallForce = 128;
    var dieFall = false;

    var currentState = Alive;

    // Iceblock / Snail stuff
    public var canBeHeld = false;
    public var currentIceblockState = Normal;
    public var held:Tux = null;
    var waitToCollide:Float = 0;
    var damageOthers = false;
    var snail = false;
    var snailJump = 256;

    var canFireballDamage = true;

    var gravity = 1000;
    var walkSpeed = 80;
    var jumpHeight = 128;
    var scoreAmount = 50;
    var bag = false; // TODO: Rename to jumpy
    var tornado = false; // TODO: Remove tornado variable
    public var direction = -1;
    var appeared = false;

    var fallSound:FlxSound;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = false;
        acceleration.y = gravity;
        
        fallSound = FlxG.sound.load("assets/sounds/fall.wav", 1, false);
        fallSound.proximity(x, y, FlxG.camera.target, FlxG.width * 0.6);
    }

    override public function update(elapsed: Float)
    {
        if (waitToCollide > 0)
        {
            waitToCollide -= elapsed;
        }

        if (bag == false && tornado == false)
        {
            if (isOnScreen())
            {
                appeared = true;
            }

            if (appeared && alive)
            {
                move();

                if (justTouched(WALL))
                {
                    flipDirection();
                }
            }
        }

        if (bag == true || tornado == true)
        {
            exists = true;
            appeared = true;
            move();
        }

        if (canBeHeld == true)
        {
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
                FlxG.sound.play("assets/sounds/iceblock_bump.wav", 1.0, false);
            }
        }

        super.update(elapsed);
    }

    function flipDirection()
    {
        flipX = !flipX;
        direction = -direction;

        if (snail && currentIceblockState == MovingSquished)
        {
            velocity.y = -snailJump;
        }
    }

    function move()
    {
    }

    public function interact(tux:Tux)
    {
        checkIfHerring(tux);

        var tuxStomp = (tux.velocity.y > 0 && tux.y + tux.height < y + 10); // This checks for Tux stomping the enemy. This should've been here since day 1.

        if (!alive || waitToCollide > 0)
        {
            return;
        }

        if (currentIceblockState == MovingSquished)
        {
            damageOthers = true;
        }

        FlxObject.separateY(tux, this);

        if (tuxStomp && tux.invincible == false) // Can't just do the simple isTouching UP thing because then if the player hits the corner of the enemy, they take damage. That's not exactly fair.
        {
            Global.score += scoreAmount;

            if (FlxG.keys.anyPressed([SPACE, UP, W]))
            {
                tux.velocity.y = -tux.maxJumpHeight;
            }
            else
            {
                tux.velocity.y = -tux.minJumpHeight / 2;
            }

            if (!canBeHeld)
            {
                kill();
            }
            else
            {
                waitToCollide = 0.25;

                if (currentIceblockState == MovingSquished)
                {
                    currentIceblockState = Squished;
                    animation.play("flat");
                    velocity.x = 0;
                }
                else if (currentIceblockState == Squished)
                {
                    direction = tux.direction;
                    flipX = !tux.flipX;
                    currentIceblockState = MovingSquished;
                    damageOthers = true;
                }
                else
                {
                    animation.play("flat");
                    currentIceblockState = Squished;
                    velocity.x = 0;
                }
            }

            return;
        }

        if (canBeHeld && currentIceblockState == Squished)
        {
            if (!isTouching(UP) && FlxG.keys.pressed.CONTROL && tux.heldEnemy == null)
            {
                tux.holdIceblock(this);
                return;
            }

            if (!tuxStomp)
            {
                direction = tux.direction;
                flipX = !tux.flipX;
                currentIceblockState = MovingSquished;
                damageOthers = true;
                FlxG.sound.play("assets/sounds/kick.wav");
                waitToCollide = 0.25;
                return;
            }
        }

        // Shouldn't get this far unless Tux should actually be damaged.
        tux.takeDamage();
    }

    override public function kill()
    {
        currentState = Dead;
        
        if (dieFall == false)
        {
            FlxG.sound.play('assets/sounds/squish.wav');
            alive = false;
            Global.score += scoreAmount;
            velocity.x = 0;
            acceleration.x = 0;
            immovable = true;
            animation.play("squished");

            new FlxTimer().start(2.0, function(_)
            {
                exists = false;
                visible = false;
            }, 1);
        }
        else
        {
            fallSound.setPosition(x + width / 2, y + height);
            fallSound.play();
            flipY = true;
            acceleration.x = 0;
            velocity.x = fallForce;
            velocity.y = -fallForce;
            solid = false;
        }
    }

    function checkIfHerring(tux:Tux)
    {
        if (tux.invincible == true)
        {
            killFall();
        }
    }

    public function killFall()
    {
        dieFall = true;
        kill();
    }

    public function collideOtherEnemy(otherEnemy:Enemy)
    {
        if (otherEnemy.damageOthers == true)
        {
            killFall();
        }
    }

    public function collideFireball(fireball:Fireball)
    {
        fireball.kill();
        if (canFireballDamage)
        {
            killFall();
        }
    }

    public function pickUp(tux:Tux)
    {
        if (canBeHeld == true)
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
    }

    public function iceblockThrow() // I couldn't be BOTHERED to make it so damageOthers and stuff is set to true when MovingSquished is the state :)
    {
        if (canBeHeld == true)
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
    }
}
