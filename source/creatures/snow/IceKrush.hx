package creatures.snow;

import flixel.util.FlxTimer;
import objects.Fireball;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

enum IceKrushStates
{
    Normal;
    Crushing;
    Crushed;
    Recovering;
}

class IceKrush extends Enemy
{
    var playerDetection:FlxSprite; // Player Detection (obviously)
    var point:FlxSprite; // Ceiling Detection (you should probably know this if you look in the code)

    var currentIcecrusherState = Normal;

    var initialX:Float;
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        loadGraphic("assets/images/characters/icecrusher-small.png");
        acceleration.y = 0;

        acceleration.x = 0;
        drag.x = 10000000000; // Setting it to a really big number should stop the Icecrusher from going sideways...

        solid = true;

        playerDetection = new FlxSprite(this.x - 40, this.y);
        playerDetection.makeGraphic(Std.int(width) + 80, FlxG.height, FlxColor.TRANSPARENT);
        playerDetection.alpha = 0.5; // This is here if someone changes the color.
        playerDetection.immovable = true;
        playerDetection.solid = true;
        Global.PS.add(playerDetection);

        point = new FlxSprite();
        point.makeGraphic(1, 1, FlxColor.TRANSPARENT);
        Global.PS.add(point);

        initialX = x;

        damageOthers = true;
    }

    override public function update(elapsed:Float)
    {   
        x = initialX;
        super.update(elapsed);

        if (playerDetection.overlaps(Global.PS.tux) && currentIcecrusherState == Normal) // You don't really need to put "true" or "false" sometimes.
        {
            fall();
        }

        playerDetection.y = y + 32;
    }

    override private function move()
    {
        var ceilingDetectorX = x + width / 2; // May seem a little complicated, but this is meant to place it at the middle.
        var ceilingDetectorY = y - 1;
        point.setPosition(ceilingDetectorX, ceilingDetectorY);

        var hasCeiling = false;

        // Check for solid objects. All of them.
        if (FlxG.overlap(point, Global.PS.blocks) || FlxG.overlap(point, Global.PS.bricks) || FlxG.overlap(point, Global.PS.collision) || FlxG.overlap(point, Global.PS.platforms))
        {
            hasCeiling = true;
        }

        if (currentIcecrusherState == Normal)
        {
            acceleration.y = 0;
            velocity.y = 0;
        }
        else if (currentIcecrusherState == Crushing)
        {
            acceleration.y = gravity;
        }
        else if (currentIcecrusherState == Recovering)
        {
            velocity.y = -250;
            acceleration.y = 0;
        }

        if (hasCeiling == true)
        {
            currentIcecrusherState = Normal;
        }

        if (justTouched(FLOOR) && currentIcecrusherState == Crushing)
        {
            Global.PS.camera.shake(0.01, 0.1);
            
            currentIcecrusherState = Crushed;

            new FlxTimer().start(0.5, function(_)
            {
                currentIcecrusherState = Recovering;
            });
        }
    }

    function fall()
    {
        currentIcecrusherState = Crushing;
        acceleration.y = gravity;
    }

    override public function interact(tux:Tux)
    {
        FlxObject.separate(this, tux);
        
        if (isTouching(DOWN))
        {
            tux.y -= 1;
            currentIcecrusherState = Recovering;
            tux.takeDamage();
        }
    }

    override public function kill()
    {
        return;
    }

    override function checkIfHerring(tux:Tux)
    {
        return;
    }

    override public function killFall()
    {
        return;
    }

    override public function collideOtherEnemy(otherEnemy:Enemy)
    {
        return;
    }

    override public function collideFireball(fireball:Fireball)
    {
        fireball.kill();
    }
}