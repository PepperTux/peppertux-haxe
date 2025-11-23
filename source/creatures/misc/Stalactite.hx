package creatures.misc;

// There's alot of Enemy.hx functions here because this extends Enemy and I don't want certain things happening.
// This uses the bonus block player detection stuff.

import objects.Fireball;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;

class IceStalactite extends Enemy
{
    // Shaking
    var shakeDuration = 0.5;
    var shakeIntensity = 0.1;
    var isShaking = false;

    // Falling
    var isBroken = false; // TODO: Replace with a state at some point?

    // Image
    var iceStalactiteImage = FlxAtlasFrames.fromSparrow("assets/images/characters/icestalactite.png", "assets/images/characters/icestalactite.xml");

    var playerDetection:FlxSprite;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        acceleration.y = 0;
        
        // Image
        frames = iceStalactiteImage;
        animation.addByPrefix("normal", "normal", 12, false);
        animation.addByPrefix("broken", "broken", 12, false);
        animation.play("normal");

        // Hitbox
        setSize(28, 42);
        offset.set(2, 0);

        immovable = true;

        playerDetection = new FlxSprite(this.x - 40, this.y);
        playerDetection.makeGraphic(Std.int(width) + 80, FlxG.height, FlxColor.TRANSPARENT);
        playerDetection.alpha = 0.5; // This is here if someone changes the color.
        playerDetection.immovable = true;
        playerDetection.solid = true;
        Global.PS.add(playerDetection);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (playerDetection.overlaps(Global.PS.tux) && !isShaking) // You don't really need to put "true" or "false" sometimes.
        {
            isShaking = true;
            immovable = false;
            damageOthers = true;
            FlxG.sound.play("assets/sounds/cracking.wav");
            FlxTween.shake(this, shakeIntensity, shakeDuration, X, {onComplete: fall});
        }

        playerDetection.x = x - 40;
        playerDetection.y = y;
    }

    public function fall(_)
    {
        acceleration.y = gravity;
    }

    override public function interact(tux:Tux)
    {
        if (!tux.invincible || !isBroken)
        {
            tux.takeDamage();
        }

        if (isBroken) // Works fine without isBroken here, but just trying to make sure it works...
        {
            return;
        }
    }

    override private function move()
    {
        if (isBroken) // Here because super.update(elapsed); makes it so the code for hitting the floor has to be here.
        {
            animation.play("broken");
            setSize(28, 42);
            offset.set(2, 6);
            damageOthers = false;
            acceleration.y = 0;
            velocity.y = 0;
            solid = false;
            new FlxTimer().start(2.0, function(_)
            {
                kill();
            }, 1);
        }

        if (justTouched(FLOOR)) // Same comment as the one on line 104.
        {
            isBroken = true;
            FlxG.sound.play("assets/sounds/icecrash.ogg", 1, false);
        }
    }

    override public function kill()
    {
        exists = false;
        alive = false;
    }

    override private function checkIfHerring(tux:Tux)
    {
        return;
    }

    override public function killFall()
    {
        return;
    }

    override public function collideOtherEnemy(otherEnemy:Enemy)
    {
        if (damageOthers == true)
        {
            otherEnemy.killFall();
        }
    }

    override public function collideFireball(fireball:Fireball)
    {
        fireball.kill();

        if (playerDetection.overlaps(Global.PS.tux) && !isShaking)
        {
            isShaking = true;
            immovable = false;
            damageOthers = true;
            FlxG.sound.play("assets/sounds/sizzle.wav");
            FlxTween.shake(this, shakeIntensity, shakeDuration, X, {onComplete: fall});
        }
    }
}

class ForestStalactite extends Enemy
{
    // Shaking
    var shakeDuration = 0.5;
    var shakeIntensity = 0.1;
    var isShaking = false;

    // Falling
    var isBroken = false; // TODO: Replace with a state at some point?

    // Image
    var forestStalactiteImage = FlxAtlasFrames.fromSparrow("assets/images/characters/foreststalactite.png", "assets/images/characters/foreststalactite.xml");

    var playerDetection:FlxSprite;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        acceleration.y = 0;
        
        // Image
        frames = forestStalactiteImage;
        animation.addByPrefix("normal", "normal", 12, false);
        animation.addByPrefix("broken", "broken", 12, false);
        animation.play("normal");

        // Hitbox
        setSize(27, 34);
        offset.set(2, 0);

        immovable = true;

        playerDetection = new FlxSprite(this.x - 40, this.y);
        playerDetection.makeGraphic(Std.int(width) + 80, FlxG.height, FlxColor.TRANSPARENT);
        playerDetection.alpha = 0.5;
        playerDetection.immovable = true;
        playerDetection.solid = true;
        Global.PS.add(playerDetection);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (playerDetection.overlaps(Global.PS.tux) && !isShaking) // You don't really need to put "true" or "false" sometimes.
        {
            isShaking = true;
            immovable = false;
            damageOthers = true;
            FlxG.sound.play("assets/sounds/cracking.wav");
            FlxTween.shake(this, shakeIntensity, shakeDuration, X, {onComplete: fall});
        }

        playerDetection.x = x - 40;
        playerDetection.y = y;
    }

    public function fall(_)
    {
        acceleration.y = gravity;
    }

    override public function interact(tux:Tux)
    {
        if (!tux.invincible || !isBroken)
        {
            tux.takeDamage();
        }

        if (tux.invincible || isBroken) // Works fine without isBroken here, but just trying to make sure it works...
        {
            return;
        }
    }

    override private function move()
    {
        if (isBroken) // Here because super.update(elapsed); makes it so the code for hitting the floor has to be here.
        {
            animation.play("broken");
            setSize(27, 34);
            offset.set(2, 5);
            acceleration.y = 0;
            velocity.y = 0;
            solid = false;
            damageOthers = false;
            new FlxTimer().start(2.0, function(_)
            {
                kill();
            }, 1);
        }

        if (justTouched(FLOOR)) // Same comment as the one on line 104.
        {
            isBroken = true;
            FlxG.sound.play("assets/sounds/icecrash.ogg", 1, false);
        }
    }

    override public function kill()
    {
        exists = false;
        alive = false;
    }

    override private function checkIfHerring(tux:Tux)
    {
        return;
    }

    override public function killFall()
    {
        return;
    }

    override public function collideOtherEnemy(otherEnemy:Enemy)
    {
        if (damageOthers == true)
        {
            otherEnemy.killFall();
        }
    }

    override public function collideFireball(fireball:Fireball)
    {
        return;
    }
}

class Coconut extends Enemy
{
    // Shaking
    var shakeDuration = 0.5;
    var shakeIntensity = 0.1;
    var isShaking = false;

    // Falling
    var isBroken = false; // TODO: Replace with a state at some point?

    // Image
    var coconutImage = FlxAtlasFrames.fromSparrow("assets/images/characters/coconut.png", "assets/images/characters/coconut.xml");

    var playerDetection:FlxSprite;

    public function new(x:Float, y:Float)
    {
        super(x, y);

        acceleration.y = 0;
        
        // Image
        frames = coconutImage;
        animation.addByPrefix("normal", "coconut normal", 12, false);
        animation.addByPrefix("broken", "coconut broken", 12, false);
        animation.play("normal");

        // Hitbox
        setSize(25, 25);
        offset.set(19, 3);

        immovable = true;

        playerDetection = new FlxSprite(this.x - 40, this.y);
        playerDetection.makeGraphic(Std.int(width) + 80, FlxG.height, FlxColor.TRANSPARENT);
        playerDetection.alpha = 0.5;
        playerDetection.immovable = true;
        playerDetection.solid = true;
        Global.PS.add(playerDetection);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (playerDetection.overlaps(Global.PS.tux) && !isShaking) // You don't really need to put "true" or "false" sometimes.
        {
            isShaking = true;
            immovable = false;
            damageOthers = true;
            FlxG.sound.play("assets/sounds/cracking.wav");
            FlxTween.shake(this, shakeIntensity, shakeDuration, X, {onComplete: fall});
        }

        playerDetection.x = x - 40;
        playerDetection.y = y;
    }

    public function fall(_)
    {
        acceleration.y = gravity;
    }

    override public function interact(tux:Tux)
    {
        if (!tux.invincible || !isBroken)
        {
            tux.takeDamage();
        }

        if (tux.invincible || isBroken) // Works fine without isBroken here, but just trying to make sure it works...
        {
            return;
        }
    }

    override private function move()
    {
        if (isBroken) // Here because super.update(elapsed); makes it so the code for hitting the floor has to be here.
        {
            animation.play("broken");
            setSize(25, 25);
            offset.set(19, 7);
            acceleration.y = 0;
            velocity.y = 0;
            solid = false;
            damageOthers = false;
            new FlxTimer().start(2.0, function(_)
            {
                kill();
            }, 1);
        }

        if (justTouched(FLOOR)) // Same comment as the one on line 104.
        {
            isBroken = true;
            FlxG.sound.play("assets/sounds/coconut.wav");
        }
    }

    override public function kill()
    {
        exists = false;
        alive = false;
    }

    override private function checkIfHerring(tux:Tux)
    {
        return;
    }

    override public function killFall()
    {
        return;
    }

    override public function collideOtherEnemy(otherEnemy:Enemy)
    {
        if (damageOthers == true)
        {
            otherEnemy.killFall();
        }
    }

    override public function collideFireball(fireball:Fireball)
    {
        return;
    }
}