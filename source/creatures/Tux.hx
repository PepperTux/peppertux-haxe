package creatures;

// Worldmap support by AnatolyStev
// Ducking support by AnatolyStev (Do NOT mis-read that!)

// Tutorials Used:
// https://www.youtube.com/watch?v=Qdq-vXt-NOE
// https://www.youtube.com/watch?v=aQazVHDztsg and yes i know this is for godot but it was actually helpful for this

// I added lots of comments just in case someone wanted to do make a mod of this recreation but doesn't know how to code.

import creatures.forest.Snail;
import creatures.snow.Iceblock;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import objects.Fireball;
import worldmap.WorldmapState;

enum TuxStates
{
    Small;
    Big;
    Fire;
}

class Tux extends FlxSprite
{
    // (Added by AnatolyStev) Holding Iceblock Stuff
    public var heldIceblock:Iceblock = null;
    public var heldSnail:Snail = null;

    // (Added by AnatolyStev) Ducking stuff
    var isDucking = false;

    // Current State
    public var currentState = Small;

    // Coffee Ball Stuff
    var canShoot = true;
    var shootCooldown = 0.3;

    // Invicibility Power-Up (Herring)
    var herringDuration = 14.0;
    public var invincible = false;
    var smallCape:FlxSprite;
    var bigCape:FlxSprite;

    // Whether Tux can take damage or not
    var canTakeDamage = true;

    // Speed
    var walkSpeed = 320;
    var speed = 0; // DON'T CHANGE THIS UNLESS YOU KNOW WHAT YOU'RE DOING. You should only change walkSpeed and runSpeed.
    var runSpeed = 320; // TODO: Remove this
    var tuxAcceleration = 2000;
    var deceleration = 1600;

    // Direction
    public var direction = 1;

    // Jump stuff and Gravity
    public var minJumpHeight = 512; // Jump Height (Minimum)
    public var maxJumpHeight = 576; // Jump Height (Maximum)
    var gravity = 1000; // Gravity, I don't recommend changing this but you can if you want low gravity or high gravity.
    var decelerateOnJumpRelease = -0.5; // thanks godot tutorial that i used. also dont change this

    // Coin Stuff
	public var totalDistros = 0;

    // Invincibility Frames
    var invFrames = 1.0;

    // Images, if replaced, make sure the replacement image has the same animations!
    var smallTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/smalltux.png", "assets/images/characters/tux/smalltux.xml");
    var bigTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/bigtux.png", "assets/images/characters/tux/bigtux.xml");
    var fireTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/firetux.png", "assets/images/characters/tux/firetux.xml");

    // You probably shouldn't change any of the below if you're making a mod.
    public function new()
    {
        super();

        // Is this even needed? I'm NEVER doing this coding stuff for a job. Pretty sure I did this when I was really tired. I'm extremely sorry.
        smallTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/smalltux.png", "assets/images/characters/tux/smalltux.xml");
        bigTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/bigtux.png", "assets/images/characters/tux/bigtux.xml");
        fireTuxImage = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/firetux.png", "assets/images/characters/tux/firetux.xml");
        
        drag.x = deceleration; // Add Deceleration
        acceleration.x = 0; // Stop him before keys are pressed, very important.
        acceleration.y = gravity; // Add Gravity

        switch(currentState)
        {
            case Small:
                frames = smallTuxImage;
            case Big:
                frames = bigTuxImage;
            case Fire:
                frames = fireTuxImage;
        }

        // I doubt some of this is actually needed, like the solid = false stuff, but I'm adding it anyways! What could possibly go wrong?
        smallCape = new FlxSprite(this.x, this.y);
        bigCape = new FlxSprite(this.x, this.y);
        smallCape.loadGraphic("assets/images/characters/tux/cape.png", true, 32, 32);
        bigCape.loadGraphic("assets/images/characters/tux/bigcape.png", true, 64, 64);
        smallCape.animation.add("normal", [0, 1], 16, true); // REPLACE THIS WITH STARS
        bigCape.animation.add("alsonormal", [0, 1], 16, true); // REPLACE THIS WITH STARS
        smallCape.setSize(32, 32);
        bigCape.setSize(32, 32);
        smallCape.solid = false;
        bigCape.solid = false;
        smallCape.visible = false;
        bigCape.visible = false;

        reloadGraphics();
    }

	override public function update(elapsed:Float)
	{
        // these will have to be changed if options are added that would allow the player to change keybinds or whatever it's called
        // Left + A = Go Left, Right + D = Go Right, Control = Run, Down + S = Duck (NOT ADDED YET!!!), Space + Up + W = Jump
        // I've gotten very used to this stuff being in update(elapsed:Float)

        if (FlxG.keys.justPressed.ONE)
        {
            currentState = Small;
            reloadGraphics();
        }
        else if (FlxG.keys.justPressed.TWO)
        {
            currentState = Big;
            reloadGraphics();
        }
        else if (FlxG.keys.justPressed.THREE)
        {
            currentState = Fire;
            reloadGraphics();
        }
        else if (FlxG.keys.justPressed.FOUR)
        {
            invincible = true;
        }
        else if (FlxG.keys.justPressed.FIVE)
        {
            Global.tuxState = currentState;

            if (!Global.completedLevels.contains(Global.currentLevel))
            {
                Global.completedLevels.push(Global.currentLevel);
            }

            Global.saveProgress();
            FlxG.switchState(WorldMapState.new);
        }

        // Make sure Tux cant escape the level through the left side of the screen
        if (x < 0)
        {
            x = 0;
        }

        // If Tux is below level, kill him
        if (y > Global.PS.map.height - height)
        {
            die();
        }

        // Tux animation stuff
        if (!isDucking || currentState == Small)
        {
            if (velocity.x != 0)
            {
                animation.play("walk");
            }
            else if (velocity.x == 0 && isTouching(FLOOR))
            {
                animation.play("stand");
            }

            if (!isTouching(FLOOR))
            {
                animation.play("jump");
            }
        }
        else if (isDucking && (currentState == Big || currentState == Fire))
        {
            animation.play("duck");
        }

        if (velocity.x > 0)
        {
            direction = 1;
            flipX = false;
            smallCape.flipX = true;
            bigCape.flipX = true;
            smallCape.offset.x = 6;
            bigCape.offset.x = 28;
        }
        else if (velocity.x < 0)
        {
            direction = -1;
            flipX = true;
            smallCape.flipX = false;
            bigCape.flipX = false;
            smallCape.offset.x = 4;
            bigCape.offset.x = 4;
        }

        // Stuff to move Tux
        if (FlxG.keys.pressed.CONTROL) // Running
        {
            speed = runSpeed;
        }
        else 
        {
            speed = walkSpeed;
        }

        // Ducking stuff
        if (currentState == Big || currentState == Fire)
        {
            if (FlxG.keys.anyPressed([DOWN, S]) && isTouching(FLOOR))
            {
                isDucking = true;
            }
            else if (!FlxG.keys.anyPressed([DOWN, S]) && isTouching(FLOOR))
            {
                isDucking = false;
            }
        }
        else
        {
            isDucking = false;
        }

        maxVelocity.x = speed; // Stop Tux from running too fast. This is very important unless you want him to be like Sonic.

        if (!isDucking || !isTouching(FLOOR))
        {
            if (FlxG.keys.anyPressed([LEFT, A]) && !FlxG.keys.anyPressed([RIGHT, D])) // Moving Left
            {
                acceleration.x = -tuxAcceleration;
            }
            else if (FlxG.keys.anyPressed([RIGHT, D]) && !FlxG.keys.anyPressed([LEFT, A])) // Moving Right
            {
                acceleration.x = tuxAcceleration;
            }
            else
            {
                acceleration.x = 0;
            }
        }
        else
        {
            acceleration.x = 0;
        }

        // May look complicated, but checking height IS needed.
        if (isDucking && (currentState == Big || currentState == Fire))
        {
            if (height != 32)
            {
                setSize(30, 32);
                offset.set(10, 35);
                velocity.y = 1000;
            }
        }
        else if ((currentState == Big || currentState == Fire) && isDucking == false)
        {
            if (height != 63)
            {
                var prevBottom = y + height;
                setSize(30, 63);
                offset.set(10, 4);
                y = prevBottom - height;
            }
        }

        if (FlxG.keys.anyJustPressed([SPACE, UP, W]) && isTouching(FLOOR)) // Jumping. Using anyJustPressed so the player can't just hold down the jump button to jump every frame they can.
        {
            if (velocity.x == 320 || velocity.x == -320)
            {
                velocity.y = -maxJumpHeight;
            }
            else
            {
                velocity.y = -minJumpHeight;
            }

            if (currentState == Small) // Play small Tux jump sound
            {
                FlxG.sound.play('assets/sounds/jump.wav');
            }
            else if (currentState == Big || currentState == Fire) // Play big Tux jump sound (It seems to be the exact same?)
            {
                FlxG.sound.play('assets/sounds/bigjump.wav');
            }
        }
        if (FlxG.keys.anyJustReleased([SPACE, UP, W]) && velocity.y < 0) // Variable Jump Height Stuff
        {
            velocity.y = decelerateOnJumpRelease;
        }

        if (invincible)
        {
            smallCape.x = this.x;
            smallCape.y = this.y;
            bigCape.x = this.x;
            bigCape.y = this.y;
            smallCape.animation.play("normal");
            bigCape.animation.play("alsonormal");

            if (currentState == Small)
            {
                smallCape.visible = true;
                Global.PS.items.add(smallCape); // Is this what they call a hack? Feel like capes should be in their own group.
            }
            else
            {
                smallCape.visible = false;
            }

            if (currentState == Big || currentState == Fire)
            {
                bigCape.visible = true;
                Global.PS.items.add(bigCape);
            }
            else
            {
                bigCape.visible = false;
            }
        }
        else
        {
            smallCape.visible = false;
            bigCape.visible = false;
        }

        shootBall();

        if (heldIceblock != null)
        {
            if (FlxG.keys.justReleased.CONTROL)
            {
                throwIceblock();
            }
        }

        if (heldSnail != null)
        {
            if (FlxG.keys.justReleased.CONTROL)
            {
                throwSnail();
            }
        }

		super.update(elapsed); // Put this after the movement code, should probably also be after everything else in update.
	}

    public function holdIceblock(iceblock:Iceblock)
    {
        if (heldIceblock != null || heldSnail != null)
        {
            return;
        }

        if (FlxG.keys.pressed.CONTROL)
        {
            heldIceblock = iceblock;
            iceblock.pickUp(this);
        }
    }

    public function holdSnail(snail:Snail)
    {
        if (heldIceblock != null || heldSnail != null)
        {
            return;
        }

        if (FlxG.keys.pressed.CONTROL)
        {
            heldSnail = snail;
            snail.pickUp(this);
        }
    }

    public function throwIceblock()
    {
        if (heldIceblock == null)
        {
            return;
        }

        heldIceblock.iceblockThrow();
        heldIceblock = null;
    }

    public function throwSnail()
    {
        if (heldSnail == null)
        {
            return;
        }

        heldSnail.snailThrow();
        heldSnail = null;
    }

    public function takeDamage() //  Makes Tux take damage.
    {
        if (canTakeDamage == true)
        {
            canTakeDamage = false;
            new FlxTimer().start(invFrames, function(_) {canTakeDamage = true;}, 1);
            FlxG.sound.play('assets/sounds/hurt.wav');
            
            if (currentState == Fire) // If current state is fire, make him go down to just being big.
            {
                currentState = Big;
                reloadGraphics();
            }
            else if (currentState == Big) // If current state is big, make him go down to just being small.
            {
                var prevBottom = y + height;
                currentState = Small;
                reloadGraphics();
                y = prevBottom - height;
            }
            else if (currentState == Small) // If current state is small, kill him.
            {
                die();
            }
        }
    }
    
    public function die() // Tux dies. This will be changed to not just do this.
    {
        currentState = Small;
        Global.tuxState = Small;
        canTakeDamage = false;
        Global.lives -= 1;
        Global.coins = 0;
        FlxG.resetState();
    }

    public function reloadGraphics()
    {
        animation.reset();

        switch(currentState)
        {
            case Small:    
                var fixedMaybeOne = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/smalltux.png", "assets/images/characters/tux/smalltux.xml");
                frames = fixedMaybeOne;

                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.play('stand');

                setSize(27, 32);
                offset.set(8, 9);
            case Big:
                var fixedMaybeTwo = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/bigtux.png", "assets/images/characters/tux/bigtux.xml");
                frames = fixedMaybeTwo;
                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix('duck', 'duck', 10, false);
                animation.play('stand');
                setSize(30, 63);
                offset.set(10, 4);
            case Fire:
                var fixedMaybeThree = FlxAtlasFrames.fromSparrow("assets/images/characters/tux/firetux.png", "assets/images/characters/tux/firetux.xml");
                frames = fixedMaybeThree;
                animation.addByPrefix('stand', 'stand', 10, false);
                animation.addByPrefix('walk', 'walk', 10, true);
                animation.addByPrefix('jump', 'jump', 10, false);
                animation.addByPrefix('duck', 'duck', 10, false);
                animation.play('stand');
                setSize(30, 63);
                offset.set(10, 4);
        }
    }

    public function bigTux()
    {
        if (currentState == Small)
        {
            var smallHeight = height;
            currentState = Big;
            reloadGraphics();
            y -= height - smallHeight;
        }
    }

    public function fireTux()
    {
        if (currentState == Small)
        {
            var smallHeight = height;
            currentState = Fire;
            reloadGraphics();
            y -= height - smallHeight;
        }
        else
        {
            currentState = Fire;
            reloadGraphics();
        }
    }

    public function herringTux()
    {
        var previousSong = Global.currentSong;

        FlxG.sound.play("assets/sounds/invincible_start.ogg", 1, false);
        FlxG.sound.playMusic("assets/music/invincible.ogg", 1, true);

        invincible = true;

        new FlxTimer().start(herringDuration, function(_)
        {
            FlxG.sound.playMusic(previousSong, 1.0, true);
            invincible = false;
        });
    }

    function shootBall()
    {
        if (currentState != Fire)
        {
            return;
        }

        if (FlxG.keys.justPressed.CONTROL && canShoot)
        {
            var fireball:Fireball = new Fireball(x + 16, y + 16);
            fireball.direction = direction;
            Global.PS.items.add(fireball);
            FlxG.sound.play("assets/sounds/shoot.wav");

            canShoot = false;
            new FlxTimer().start(shootCooldown, function(_) canShoot = true);
        }
    }
}