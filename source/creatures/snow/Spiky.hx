package creatures.snow;

// Ground detecting stuff by AnatolyStev, it's taken from the Smartball.hx file.

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;

class Spiky extends Enemy
{
    var point:FlxSprite;

    var spikyImage = FlxAtlasFrames.fromSparrow("assets/images/characters/spiky.png", "assets/images/characters/spiky.xml");

    public function new(x:Float, y:Float)
    {
        super(x, y);

        frames = spikyImage;
        animation.addByPrefix('walk', 'walk', 10, true);
        animation.play('walk');

        point = new FlxSprite();
        point.makeGraphic(1, 1, FlxColor.TRANSPARENT);
        Global.PS.add(point);

        setSize(33, 33);
        offset.set(5, 9);
    }

    override private function move()
    {
        // Ground Detectors
        var groundDetectorX = if (direction == 1) { x + this.width + 1; } else { x - 1; } // what is this
        var groundDetectorY = y + this.height + offset.y + 1;

        point.setPosition(groundDetectorX, groundDetectorY);

        // Things
        var hasGround = false;

        // Check for solid objects
        if (FlxG.overlap(point, Global.PS.blocks) || FlxG.overlap(point, Global.PS.bricks) || FlxG.overlap(point, Global.PS.collision) || FlxG.overlap(point, Global.PS.platforms))
        {
            hasGround = true;
        }

        if (!hasGround && currentState == Alive)
        {
            flipDirection();
        }

        // Walk
        velocity.x = direction * walkSpeed;
    }

    override public function interact(tux:Tux)
    {
        if (alive && tux.invincible == false)
        {
            tux.takeDamage();
        }

        if (tux.invincible == true)
        {
            killFall();
        }
    }
}
