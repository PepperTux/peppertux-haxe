package objects.movingplatforms;

// Code originally made by Vaesea, code remade by AnatolyStev

import flixel.FlxSprite;

class FloatingPlatform extends FlxSprite
{
    public var velocityY = 8;
    public var minY:Float;
    public var maxY:Float;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        immovable = true;
        solid = true;

        minY = y - 8;
        maxY = y + 8;
        velocity.y = velocityY;
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        if (y > maxY)
        {
            velocity.y = -Math.abs(velocityY);
        }
        else if (y < minY)
        {
            velocity.y = Math.abs(velocityY);
        }
    }
}