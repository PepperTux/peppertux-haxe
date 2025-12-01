package;

import creatures.tropical.BrownSnake;
import creatures.tropical.PurpleSnake;
import objects.Scripting;
import creatures.misc.Flame;
import creatures.snow.Crystallo;
import objects.SolidKill;
import creatures.snow.IceKrush;
import flixel.addons.editors.tiled.TiledImageLayer;
import creatures.tropical.Snake;
import creatures.forest.ghost.FatBat;
import objects.movingplatforms.TinyWood;
import objects.movingplatforms.SmallIcefloe;
import objects.movingplatforms.Icefloe;
import objects.movingplatforms.Big;
import objects.Trampoline;
import creatures.tropical.Cherrybomb;
import creatures.forest.ghost.Kirby;
import creatures.tropical.Crab;
import creatures.tropical.Brab;
import creatures.tropical.Grab;
import creatures.forest.Snail;
import creatures.misc.MrBomb;
import creatures.forest.ViciousIvy;
import creatures.forest.WalkingLeaf;
import objects.Unisolid;
import objects.SolidHurt;
import creatures.misc.Stalactite;
import creatures.mountain.OldBomb;
import creatures.snow.BouncingSnowball;
import objects.Solid;
import creatures.snow.Smartball;
import creatures.snow.FlyingSnowball;
import creatures.snow.Iceblock;
import creatures.mountain.MetalJumpy;
import creatures.snow.SnowJumpy;
import objects.Coin;
import creatures.snow.Snowball;
import creatures.snow.Spiky;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.tile.FlxTilemap;
import objects.BonusBlock;
import objects.BrickBlock;
import objects.Goal;
import states.PlayState;
import tiles.AnimatedTiles;

class LevelLoader extends FlxState
{

    public static function loadLevel(state:PlayState, level:String)
    {
        var tiledMap = new TiledMap(level);

        // MAKE SURE TO PUT THESE THINGS IN YOUR LEVEL OR THE GAME MIGHT CRASH!!!!!!!!!! Sorry for not being very professional but I just needed to make it VERY clear. Do NOT remove the custom properties of the base level for your level.
        var song = tiledMap.properties.get("music");
        var levelName = tiledMap.properties.get("levelName");
        var levelCreator = tiledMap.properties.get("levelCreator");

        Global.levelName = levelName;
        Global.creatorOfLevel = levelCreator;

        // FlxG.sound.playMusic(song, 1.0, true); only add back if there's a problem
        Global.currentSong = song;

        // Load background the new way
        for (layer in tiledMap.layers)
        {
            if (Std.isOfType(layer, TiledImageLayer))
            {
                var imageLayer:TiledImageLayer = cast layer;
                var path:String = Std.string(imageLayer.imagePath);
                path = StringTools.replace(path, "../", "");
                path = "assets/" + path;

                var image = new FlxBackdrop(path, XY);

                image.offset.x = Std.parseFloat(imageLayer.properties.get("offsetX"));
                image.offset.y = Std.parseFloat(imageLayer.properties.get("offsetY"));
                
                image.scrollFactor.x = imageLayer.parallaxX;
                image.scrollFactor.y = imageLayer.parallaxY;

                state.add(image);
            }
        }

        // Furthest Background
        var furthestBackgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Furthest Background");
        
        var furthestBackgroundMap = new FlxTilemap();
        furthestBackgroundMap.loadMapFromArray(furthestBackgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/normalTiles.png", 32, 32, 1);
        furthestBackgroundMap.solid = false;

        // Even Further Background
        var evenFurtherBackgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Even Further Background");
        
        var evenFurtherBackgroundMap = new FlxTilemap();
        evenFurtherBackgroundMap.loadMapFromArray(evenFurtherBackgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/normalTiles.png", 32, 32, 1);
        evenFurtherBackgroundMap.solid = false;

        // Further Background
        var furtherBackgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Further Background");
        
        var furtherBackgroundMap = new FlxTilemap();
        furtherBackgroundMap.loadMapFromArray(furtherBackgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/normalTiles.png", 32, 32, 1);
        furtherBackgroundMap.solid = false;
        
        // Background
        var backgroundLayer:TiledTileLayer = cast tiledMap.getLayer("Background");
        
        var backgroundMap = new FlxTilemap();
        backgroundMap.loadMapFromArray(backgroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/normalTiles.png", 32, 32, 1);
        backgroundMap.solid = false;

        // Main (Used to be named Interactive during HaxeTux development)
        var interactiveLayer:TiledTileLayer = cast tiledMap.getLayer("Main");

        state.map = new FlxTilemap();
        state.map.loadMapFromArray(interactiveLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/normalTiles.png", 32, 32, 1);
        state.map.solid = false;

        // Foreground
        var foregroundLayer:TiledTileLayer = cast tiledMap.getLayer("Foreground");
        
        state.foregroundMap = new FlxTilemap();
        state.foregroundMap.loadMapFromArray(foregroundLayer.tileArray, tiledMap.width, tiledMap.height, "assets/images/normalTiles.png", 32, 32, 1);
        state.foregroundMap.solid = false;

        state.add(furthestBackgroundMap);
        state.add(evenFurtherBackgroundMap);
        state.add(furtherBackgroundMap);
        state.add(backgroundMap);

        // Load collision
        for (solid in getLevelObjects(tiledMap, "Cutscene"))
        {
            switch (solid.type)
            {
                case "StopTux":
                    var stopSquare = new StopTux(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(stopSquare);
                case "StartTux":
                    var startSquare = new StartTux(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(startSquare);
                case "WalkTuxRight":
                    var walkRightSquare = new WalkTuxRight(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(walkRightSquare);
                case "WalkTuxLeft":
                    var walkLeftSquare = new WalkTuxLeft(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(walkLeftSquare);
                case "RunTuxRight":
                    var runRightSquare = new RunTuxRight(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(runRightSquare);
                case "RunTuxLeft":
                    var runLeftSquare = new RunTuxLeft(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(runLeftSquare);
                case "TuxJumpSmall":
                    var jumpSmallSquare = new TuxJumpSmall(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(jumpSmallSquare);
                case "TuxJump":
                    var tuxJumpSquare = new TuxJump(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(tuxJumpSquare);
                case "TuxJumpHigh":
                    var jumpHighSquare = new TuxJumpHigh(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(jumpHighSquare);
                case "FadeOut":
                    var fadeOutSquare = new FadeOut(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(fadeOutSquare);
                case "StopTuxAndWalkRight":
                    var stopAndWalkRightSquare = new StopTuxAndWalkRight(solid.x, solid.y, solid.width, solid.height);
                    state.scripting.add(stopAndWalkRightSquare);
            }
        }

        for (solid in getLevelObjects(tiledMap, "Solid"))
        {
            var solidSquare = new Solid(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.collision.add(solidSquare);
        }

        for (solid in getLevelObjects(tiledMap, "Hurt Collision"))
        {
            var hurtSquare = new SolidHurt(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.hurtCollision.add(hurtSquare);
        }

        for (solid in getLevelObjects(tiledMap, "Kill Collision"))
        {
            var killSquare = new SolidKill(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.killCollision.add(killSquare);
        }

        for (solid in getLevelObjects(tiledMap, "Unisolid"))
        {
            var unisolidSquare = new Unisolid(solid.x, solid.y, solid.width, solid.height); // Need this because width and height.
            state.collision.add(unisolidSquare);
        }

        // Load animated tiles
        for (object in getLevelObjects(tiledMap, "Animated Tiles"))
        {
            switch (object.type)
            {
                default:
                    state.atiles.add(new WaterNew(object.x, object.y - 32));
                case "flag":
                    state.atiles.add(new Flag(object.x, object.y - 32));
                case "lava":
                    state.atiles.add(new Lava(object.x, object.y - 32));
            }
        }

        // Load goal
        for (object in getLevelObjects(tiledMap, "Level"))
        {
            switch (object.type)
            {
                case "goal": // Might add a checkpoint at some point, don't replace this with default!
                    state.items.add(new Goal(object.x, object.y - 32));
            }
        }

        // Load distros
        for (distro in getLevelObjects(tiledMap, "Coins"))
            state.items.add(new Coin(distro.x, distro.y - 32));

        // Load blocks
        for (block in getLevelObjects(tiledMap, "Blocks"))
        {
            var blockToAdd = new BonusBlock(block.x, block.y - 32);
            blockToAdd.content = block.type;
            state.blocks.add(blockToAdd);
        }

        for (object in getLevelObjects(tiledMap, "Objects"))
        {
            switch (object.type)
            {
                case "trampoline":
                    state.trampolines.add(new Trampoline(object.x, object.y - 32));
                case "wood":
                    state.platforms.add(new Big(object.x, object.y - 32));
                case "icefloe":
                    state.platforms.add(new Icefloe(object.x, object.y - 44));
                case "smallicefloe":
                    state.platforms.add(new SmallIcefloe(object.x, object.y - 44));
                case "tinywood":
                    state.platforms.add(new TinyWood(object.x, object.y - 32));
            }
        }

        // Load bricks
        for (brick in getLevelObjects(tiledMap, "Bricks"))
        {
            switch(brick.type)
            {
                default:
                    state.bricks.add(new EmptyNormalBrickBlock(brick.x, brick.y - 32));
                case "snow":
                    state.bricks.add(new EmptySnowBrickBlock(brick.x, brick.y - 32));
                case "coin":
                    state.bricks.add(new CoinNormalBrickBlock(brick.x, brick.y - 32));
                case "snowcoin":
                    state.bricks.add(new CoinSnowBrickBlock(brick.x, brick.y - 32));
            }
        }

        // Load enemies
        for (enemy in getLevelObjects(tiledMap, "Enemies"))
            switch(enemy.type)
            {
                default:
                    state.enemies.add(new Snowball(enemy.x, enemy.y - 32));
                case "spiky":
                    state.enemies.add(new Spiky(enemy.x, enemy.y - 33));
                case "jumpy": // Here so old levels don't break
                    state.enemies.add(new MetalJumpy(enemy.x, enemy.y - 37));
                case "metaljumpy":
                    state.enemies.add(new MetalJumpy(enemy.x, enemy.y - 37));
                case "snowjumpy":
                    state.enemies.add(new SnowJumpy(enemy.x, enemy.y - 42));
                case "smartball":
                    state.enemies.add(new Smartball(enemy.x, enemy.y - 32));
                case "flyingsnowball":
                    state.enemies.add(new FlyingSnowball(enemy.x - 6, enemy.y - 34));
                case "iceblock":
                    state.enemies.add(new Iceblock(enemy.x, enemy.y - 30));
                case "bouncingsnowball":
                    state.enemies.add(new BouncingSnowball(enemy.x, enemy.y - 32));
                case "crystallo":
                    state.enemies.add(new Crystallo(enemy.x, enemy.y - 28));
                case "icekrush":
                    state.enemies.add(new IceKrush(enemy.x, enemy.y - 32));
                case "bomb": // Here so old levels don't break
                    state.enemies.add(new OldBomb(enemy.x, enemy.y - 35));
                case "oldbomb":
                    state.enemies.add(new OldBomb(enemy.x, enemy.y - 35));
                case "cherrybomb":
                    state.enemies.add(new Cherrybomb(enemy.x, enemy.y - 39));
                case "mrbomb":
                    state.enemies.add(new MrBomb(enemy.x, enemy.y - 35));
                case "icicle":
                    state.enemies.add(new IceStalactite(enemy.x, enemy.y - 32));
                case "foreststalactite":
                    state.enemies.add(new ForestStalactite(enemy.x, enemy.y - 36));
                case "mountainstalactite":
                    state.enemies.add(new MountainStalactite(enemy.x, enemy.y - 39));
                case "coconut":
                    state.enemies.add(new Coconut(enemy.x, enemy.y - 32));
                case "viciousivy":
                    state.enemies.add(new ViciousIvy(enemy.x, enemy.y - 19));
                case "walkingleaf":
                    state.enemies.add(new WalkingLeaf(enemy.x, enemy.y - 19));
                case "snail":
                    state.enemies.add(new Snail(enemy.x, enemy.y - 29));
                case "kirby":
                    state.enemies.add(new Kirby(enemy.x, enemy.y - 38));
                case "fatbat":
                    state.enemies.add(new FatBat(enemy.x, enemy.y - 36));
                case "crab":
                    state.enemies.add(new Crab(enemy.x, enemy.y - 35));
                case "brab":
                    state.enemies.add(new Brab(enemy.x, enemy.y - 35));
                case "grab":
                    state.enemies.add(new Grab(enemy.x, enemy.y - 35));
                case "snake":
                    state.enemies.add(new Snake(enemy.x, enemy.y - 8));
                case "purplesnake":
                    state.enemies.add(new PurpleSnake(enemy.x, enemy.y - 8));
                case "brownsnake":
                    state.enemies.add(new BrownSnake(enemy.x, enemy.y - 8));
                case "flame":
                    state.enemies.add(new Flame(enemy.x, enemy.y - 32));
                case "iceflame":
                    state.enemies.add(new IceFlame(enemy.x, enemy.y - 32));
            }
        
        for (object in getLevelObjects(tiledMap, "Animated Tiles Foreground"))
        {
            switch (object.type)
            {
                default:
                    state.atilesFront.add(new WaterNew(object.x, object.y - 32));
                case "flag":
                    state.atilesFront.add(new Flag(object.x, object.y - 32));
                case "lava":
                    state.atilesFront.add(new Lava(object.x, object.y - 32));
            }
        }

        // Don't be like me. Don't remove this.
        var tuxPosition:TiledObject = getLevelObjects(tiledMap, "Player")[0];
        state.tux.setPosition(tuxPosition.x, tuxPosition.y - 37);
    }

    public static function getLevelObjects(map:TiledMap, layer:String):Array<TiledObject>
    {
        if ((map != null) && (map.getLayer(layer) != null))
        {
            var objLayer:TiledObjectLayer = cast map.getLayer(layer);
            return objLayer.objects;
        }
        else
        {
            trace("Object layer " + layer + " not found! Also credits to Discover Haxeflixel.");
            return [];
        }
    }
}