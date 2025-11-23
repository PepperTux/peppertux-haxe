package states;

// Original file made by Vaesea
// Saving Tux's state support done by AnatoyStev

import objects.SolidKill;
import objects.movingplatforms.FloatingPlatform;
import objects.Trampoline;
import objects.SolidHurt;
import objects.TuxDoll;
import LevelLoader;
import creatures.Enemy;
import creatures.Tux;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import objects.Fireball;
import objects.BonusBlock;
import objects.BrickBlock;
import objects.Coin;
import objects.Goal;
import objects.Herring;
import objects.PowerUp;
import substates.IntroSubState;

class PlayState extends FlxState
{
	public var map:FlxTilemap;
	public var foregroundMap:FlxTilemap;

	public var collision(default, null):FlxTypedGroup<FlxSprite>;
	public var hurtCollision(default, null):FlxTypedGroup<FlxSprite>;
	public var killCollision(default, null):FlxTypedGroup<FlxSprite>;
	public var atiles(default, null):FlxTypedGroup<FlxSprite>;
	public var tux(default, null):Tux;
	public var items(default, null):FlxTypedGroup<FlxSprite>;
	public var blocks(default, null):FlxTypedGroup<FlxSprite>;
	public var bricks(default, null):FlxTypedGroup<FlxSprite>;
	public var platforms(default, null):FlxTypedGroup<FloatingPlatform>;
	public var trampolines(default, null):FlxTypedGroup<FlxSprite>;
	public var enemies(default, null):FlxTypedGroup<Enemy>;
	public var atilesFront(default, null):FlxTypedGroup<FlxSprite>;
	public var td(default, null):FlxTypedGroup<TuxDoll>;

	var hud:HUD;

	var entities:FlxGroup;

	override public function create()
	{
		// Makes sure Global's variable "PS" works
		Global.PS = this;

		// Add stuff part 1
		collision = new FlxTypedGroup<FlxSprite>();
		hurtCollision = new FlxTypedGroup<FlxSprite>();
		killCollision = new FlxTypedGroup<FlxSprite>();
		atiles = new FlxTypedGroup<FlxSprite>();
		entities = new FlxGroup();
		items = new FlxTypedGroup<FlxSprite>();
		bricks = new FlxTypedGroup<FlxSprite>();
		blocks = new FlxTypedGroup<FlxSprite>();
		platforms = new FlxTypedGroup<FloatingPlatform>();
		trampolines = new FlxTypedGroup<FlxSprite>();
		enemies = new FlxTypedGroup<Enemy>();
		td = new FlxTypedGroup<TuxDoll>();
		tux = new Tux();
		tux.currentState = Global.tuxState;
		tux.reloadGraphics(); // May seem VERY useless but I just want to make it work.
		atilesFront = new FlxTypedGroup<FlxSprite>();
		hud = new HUD();

		// Loading the Test Level
		LevelLoader.loadLevel(this, Global.currentLevel);

		// Add stuff part 2
		entities.add(items);
		entities.add(bricks);
		entities.add(blocks);
		entities.add(platforms);
		entities.add(trampolines);
		entities.add(enemies);
		add(collision);
		add(hurtCollision);
		add(killCollision);
		add(atiles);
		add(map);
		add(entities);
		add(td);
		add(tux);
		add(foregroundMap);
		add(atilesFront);
		add(hud);

		// Camera
		FlxG.camera.follow(tux, FlxCameraFollowStyle.PLATFORMER);
		FlxG.camera.setScrollBoundsRect(0, 0, map.width, map.height, true);

		openSubState(new IntroSubState(FlxColor.BLACK));
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// Tux collision
		FlxG.collide(collision, tux);
		FlxG.overlap(hurtCollision, tux, collideHurtCollision);
		FlxG.overlap(killCollision, tux, collideKillCollision);
		FlxG.overlap(entities, tux, collideEntities);
		FlxG.overlap(td, tux, collideTuxDoll);
		FlxG.collide(tux, blocks, collideEntities);
		FlxG.collide(tux, bricks, collideEntities);
		FlxG.collide(trampolines, tux, collideEntities);

		// Enemy collision
		FlxG.collide(collision, entities);
		FlxG.collide(enemies, blocks);
		FlxG.collide(enemies, bricks);
		FlxG.overlap(entities, enemies, function (entity:FlxSprite, enemy:Enemy)
		{
			if (Std.isOfType(entity, Enemy))
			{
				enemy.collideOtherEnemy(cast entity);
			}
			if (Std.isOfType(entity, Fireball))
			{
				enemy.collideFireball(cast entity);
			}
		} );

		// Item collision
		FlxG.collide(collision, items);
		FlxG.collide(items, blocks);
		FlxG.collide(items, bricks);

		// Trampoline collision
		FlxG.collide(trampolines, blocks);
		FlxG.collide(trampolines, bricks);
		FlxG.collide(trampolines, collision);
		FlxG.collide(trampolines, enemies);

		// Platform collision
		FlxG.collide(platforms, enemies);
		FlxG.collide(platforms, items);
		FlxG.collide(platforms, tux);
	}

	function collideEntities(entity:FlxSprite, tux:Tux)
	{
		if (Std.isOfType(entity, Coin))
		{
			(cast entity).collect();
		}

		if (Std.isOfType(entity, Enemy))
		{
			(cast entity).interact(tux);
		}

		if (Std.isOfType(entity, EmptyNormalBrickBlock) || Std.isOfType(entity, EmptySnowBrickBlock) || Std.isOfType(entity, CoinSnowBrickBlock) || Std.isOfType(entity, CoinNormalBrickBlock))
		{
			(cast entity).hit(tux);
		}

		if (Std.isOfType(entity, BonusBlock))
		{
			(cast entity).hit(tux);
		}

		if (Std.isOfType(entity, Trampoline))
		{
			(cast entity).bounceTux(tux);
		}

		if (Std.isOfType(entity, PowerUp))
		{
			(cast entity).collect(tux);
		}

		if (Std.isOfType(entity, Herring))
		{
			(cast entity).collect(tux);
		}

		if (Std.isOfType(entity, Goal))
		{
			(cast entity).reach(tux);
		}
	}

	function collideTuxDoll(tuxDoll:TuxDoll, tux:Tux)
	{
		if (tuxDoll != null) // This is here to prevent a Null Object Reference, but I'm not sure it's needed anymore? Better to be safe rather than sorry, as the saying goes...
		{
			tuxDoll.collect(tux);
		}
	}

	function collideHurtCollision(hurt:SolidHurt, tux:Tux)
	{
		tux.takeDamage();
	}

	function collideKillCollision(kill:SolidKill, tux:Tux)
	{
		tux.die();
	}
	
	override public function destroy()
	{
		Global.saveProgress();
		super.destroy();
	}
}