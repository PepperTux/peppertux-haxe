package objects;

// Made by Vaesea, fixed by AnatolyStev
// Well actually it came from Discover Haxeflixel but still

import flixel.FlxObject;
import creatures.Tux;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.Coin;

class EmptyNormalBrickBlock extends FlxSprite
{
    var scoreAmount = 25;
    var gravity = 1000;

    var HFraycast2d:FlxSprite; // it's BASICALLY a raycast2d, right?? (I believe the word you were looking for was area2d)

    var brickImage = FlxAtlasFrames.fromSparrow('assets/images/objects/brick.png', 'assets/images/objects/brick.xml');
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = true;

        frames = brickImage;
        animation.addByPrefix('normal', 'normal', 12, false);
        animation.play("normal");

        HFraycast2d = new FlxSprite(x + 8, y + height);
        HFraycast2d.makeGraphic(Std.int(width) - 16, Std.int(height) + 1, FlxColor.TRANSPARENT); // all this STD is gonna give me a... Nevermind. Forget about it. Std.int is there because width and height need to be ints.
        HFraycast2d.immovable = true;
        HFraycast2d.solid = false;
    }

    override public function update(elapsed:Float)
    {
        if (isOnScreen())
        {
            super.update(elapsed);
        }
    }
    
    public function hit(tux:Tux)
    {
        if (!HFraycast2d.overlaps(tux))
        {
            return;
        }

        if (tux.currentState == Big || tux.currentState == Fire)
        {
            FlxObject.separateY(this, tux);
            Global.score += scoreAmount;
            FlxG.sound.play('assets/sounds/brick.wav');
            
            for (i in 0...4)
            {
                var debris:FlxParticle = new FlxParticle();
                debris.loadGraphic('assets/images/particles/brick.png', true, 8, 8);
                debris.animation.add("rotate", [0, 1], 16, true);
                debris.animation.play("rotate");

                var countX = (i % 2 == 0) ? 1 : -1;
                var countY = (Math.floor(i / 2)) == 0 ? -1 : 1;

                debris.setPosition(4 + x + countX * 4, 4 + y + countY * 4);
                debris.lifespan = 6;
                debris.acceleration.y = gravity;
                debris.velocity.y = -160 + (10 * countY);
                debris.velocity.x = 40 * countX;
                debris.exists = true;

                Global.PS.add(debris);
            }

            kill();
        }
        else
        {
            var currentY = y;
            FlxTween.tween(this, {y: currentY - 4}, 0.05)
            .wait(0.05)
            .then(FlxTween.tween(this, {y: currentY}, 0.05));
        }
    }
}

class EmptySnowBrickBlock extends FlxSprite
{
    var scoreAmount = 25;
    var gravity = 1000;

    var HFraycast2d:FlxSprite; // it's BASICALLY a raycast2d, right??

    var brickSnowImage = FlxAtlasFrames.fromSparrow('assets/images/objects/brick.png', 'assets/images/objects/brick.xml');
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = true;

        frames = brickSnowImage;
        animation.addByPrefix('normal', 'snow', 12, false);
        animation.play("normal"); // Fixed :)

        HFraycast2d = new FlxSprite(x + 8, y + height);
        HFraycast2d.makeGraphic(Std.int(width) - 16, Std.int(height) + 1, FlxColor.TRANSPARENT); // all this STD is gonna give me a... Nevermind. Forget about it. Std.int is there because width and height need to be ints.
        HFraycast2d.immovable = true;
        HFraycast2d.solid = false;
    }

    override public function update(elapsed:Float)
    {
        if (isOnScreen())
        {
            super.update(elapsed);
        }
    }
    
    public function hit(tux:Tux)
    {
        if (HFraycast2d.overlaps(tux) == false)
        {
            return;
        }

        if (tux.currentState == Big || tux.currentState == Fire)
        {
            FlxObject.separateY(this, tux);
            Global.score += scoreAmount;
            FlxG.sound.play('assets/sounds/brick.wav');
            
            for (i in 0...4)
            {
                var debris:FlxParticle = new FlxParticle();
                debris.loadGraphic('assets/images/particles/brick.png', true, 8, 8);
                debris.animation.add("rotate", [0, 1], 16, true);
                debris.animation.play("rotate");

                var countX = (i % 2 == 0) ? 1 : -1;
                var countY = (Math.floor(i / 2)) == 0 ? -1 : 1;

                debris.setPosition(4 + x + countX * 4, 4 + y + countY * 4);
                debris.lifespan = 6;
                debris.acceleration.y = gravity;
                debris.velocity.y = -160 + (10 * countY);
                debris.velocity.x = 40 * countX;
                debris.exists = true;

                Global.PS.add(debris);
            }

            kill();
        }
        else
        {
            var currentY = y;
            FlxTween.tween(this, {y: currentY - 4}, 0.05)
            .wait(0.05)
            .then(FlxTween.tween(this, {y: currentY}, 0.05));
        }
    }
}

class CoinNormalBrickBlock extends FlxSprite
{
    var scoreAmount = 25;
    var gravity = 1000;

    var howManyHits = 5;
    var isHit = false;

    var HFraycast2d:FlxSprite; // it's BASICALLY a raycast2d, right??

    var brickCoinImage = FlxAtlasFrames.fromSparrow('assets/images/objects/brick.png', 'assets/images/objects/brick.xml');
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        solid = true;
        immovable = true;

        frames = brickCoinImage;
        animation.addByPrefix('normal', 'normal', 12, false);
        animation.addByPrefix('empty', 'empty', 12, false);
        animation.play("normal");

        HFraycast2d = new FlxSprite(x + 8, y + height);
        HFraycast2d.makeGraphic(Std.int(width) - 16, Std.int(height) + 1, FlxColor.TRANSPARENT); // all this STD is gonna give me a... Nevermind. Forget about it. Std.int is there because width and height need to be ints.
        HFraycast2d.immovable = true;
        HFraycast2d.solid = false;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (howManyHits == 0)
        {
            animation.play("empty");
        }
    }
    
    public function hit(tux:Tux)
    {
        if (HFraycast2d.overlaps(tux) == false || isHit == true)
        {
            return;
        }

        if (howManyHits > 0)
        {
            FlxObject.separateY(this, tux);
            var currentY = y;
            howManyHits -= 1;
            isHit = true;
            FlxTween.tween(this, {y: currentY - 4}, 0.05)
            .wait(0.05)
            .then(FlxTween.tween(this, {y: currentY}, 0.05, {onComplete: function (_)
            {
                isHit = false;
            }}));
            createItem();
        }
    }

    function createItem()
    {
        FlxG.sound.play('assets/sounds/brick.wav');
        var coin:Coin = new Coin(Std.int(x), Std.int(y - 32));
        coin.setFromBlock();
        Global.PS.items.add(coin);
    }
}

class CoinSnowBrickBlock extends FlxSprite
{
    var scoreAmount = 25;
    var gravity = 1000;

    var howManyHits = 5;
    var isHit = false;

    var HFraycast2d:FlxSprite; // it's BASICALLY a raycast2d, right??

    var snowBrickCoinImage = FlxAtlasFrames.fromSparrow('assets/images/objects/brick.png', 'assets/images/objects/brick.xml');
    
    public function new(x:Float, y:Float)
    {
        super(x, y);
        solid = true;
        immovable = true;

        frames = snowBrickCoinImage;
        animation.addByPrefix('normal', 'snow', 12, false);
        animation.addByPrefix('empty', 'empty', 12, false);
        animation.play("normal");

        HFraycast2d = new FlxSprite(x + 8, y + height);
        HFraycast2d.makeGraphic(Std.int(width) - 16, Std.int(height) + 3, FlxColor.TRANSPARENT); // all this STD is gonna give me a... Nevermind. Forget about it. Std.int is there because width and height need to be ints.
        HFraycast2d.immovable = true;
        HFraycast2d.solid = false;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (howManyHits == 0)
        {
            animation.play("empty");
        }
    }
    
    public function hit(tux:Tux)
    {
        if (HFraycast2d.overlaps(tux) == false || isHit == true)
        {
            return;
        }

        if (howManyHits > 0)
        {
            FlxObject.separateY(this, tux);
            var currentY = y;
            howManyHits -= 1;
            isHit = true;
            FlxTween.tween(this, {y: currentY - 4}, 0.05)
            .wait(0.05)
            .then(FlxTween.tween(this, {y: currentY}, 0.05, {onComplete: function (_)
            {
                isHit = false;
            }}));
            createItem();
        }
    }

    function createItem()
    {
        FlxG.sound.play('assets/sounds/brick.wav');
        var coin:Coin = new Coin(Std.int(x), Std.int(y - 32));
        coin.setFromBlock();
        Global.PS.items.add(coin);
    }
}