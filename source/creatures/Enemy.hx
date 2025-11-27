package creatures;

// Original file by Vaesea
// Very simple Jumpy fix by AnatolyStev

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

class Enemy extends FlxSprite
{
    var fallForce = 128;
    var dieFall = false;

    var damageOthers = false;

    var currentState = Alive;

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

        super.update(elapsed);
    }

    function flipDirection()
    {
        flipX = !flipX;
        direction = -direction;
    }

    function move()
    {
    }

    public function interact(tux:Tux)
    {
        checkIfHerring(tux);

        if (!alive)
        {
            return;
        }

        FlxObject.separateY(tux, this);

        if (tux.velocity.y > 0 && tux.y + tux.height < y + 10 && tux.invincible == false) // Can't just do the simple isTouching UP thing because then if the player hits the corner of the enemy, they take damage. That's not exactly fair.
        {
            if (FlxG.keys.anyPressed([SPACE, UP, W]))
            {
                tux.velocity.y = -tux.maxJumpHeight;
            }
            else
            {
                tux.velocity.y = -tux.minJumpHeight / 2;
            }

            kill();
        }
        else
        {
            if (tux.invincible == false)
            {
                tux.takeDamage();
            }
        }
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
}
