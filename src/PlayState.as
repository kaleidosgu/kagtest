package
{
	import flash.display.BlendMode;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import kag.util.KagResourceDataWrite;
	import kag.util.KagTxtResourcePath;
	import kag.util.KagResourceDataRead;
	import kag.util.map.KagMapGenerator;
	import mx.core.FlexSprite;
	import org.flixel.*;
	import flash.filesystem.File;

	public class PlayState extends FlxState
	{
		// Tileset that works with AUTO mode (best for thin walls)
		[Embed(source = '../res/image/world.png')]private static var auto_tiles:Class;
		[Embed(source = '../res/image/arrow.png')]private static var arrorPic:Class;
		[Embed(source = '../res/image/SmallExplosion2.png')]private static var explosionPic:Class;
		
		
		// Default tilemaps. Embedding text files is a little weird.
		[Embed(source = '../res/default_auto.txt', mimeType = 'application/octet-stream')]private static var default_auto:Class;

		[Embed(source="../res/image/spaceman.png")] private static var ImgSpaceman:Class;
		
		// Some static constants for the size of the tilemap tiles
		private const TILE_WIDTH:uint = 8;
		private const TILE_HEIGHT:uint = 8;
		
		// Box to show the user where they're placing stuff
		private var highlightBox:FlxObject;
		
		// Player modified from "Mode" demo
		private var player:FlxSprite;
		private var lineDraw:FlxSprite;
		
		// Some interface buttons and text
		private var autoAltBtn:FlxButton;
		private var resetBtn:FlxButton;
		private var quitBtn:FlxButton;
		private var helperTxt:FlxText;
		
		private var tileGroup:FlxGroup = new FlxGroup();
		private var tileNoGroup:FlxGroup = new FlxGroup();
		
		private var _mapData:Array = new Array();
		private var _mapGenerate:KagMapGenerator = null;
		
		private var _showWidth:uint = 0;
		private var _showHeight:uint = 0;
		private var _showScale:uint = 2;
		
		private var _textNotify:FlxText = null;
		private var _systemNotify:FlxText = null;
		
		private var _systemText:String = "System:"
		private var _arrowSprite:FlxSprite;
		private var _testPath:FlxPath;
		private var _explosionSprite1:FlxSprite;
		private var _playerCollide:Boolean = false;
		
		private var _expGroup:FlxGroup = new FlxGroup();
		
		private var _playerWidthHalf:Number = 0;
		private var _playerHeightHalf:Number = 0;
		
		private var _blockSprite:FlxSprite;
		private var _blockTileGroup:FlxGroup = new FlxGroup();
		public function PlayState()
		{
			
		}
		
		override public function create():void
		{
			var testVal:Number = 0.5;
			if ( testVal == 0 )
			{
				var a = 0;
			}
			else
			{
				var b = 0;
			}
			//FlxG.visualDebug = true;
			_showWidth 	= TILE_WIDTH * _showScale ;
			_showHeight	= TILE_HEIGHT * _showScale;
			FlxG.framerate = 50;
			FlxG.flashFramerate = 50;
			
			var kagResPath:KagTxtResourcePath = new KagTxtResourcePath("default_write");
			var filePathString:String = kagResPath.resourcePath;
			
			var dataRead:KagResourceDataRead = new KagResourceDataRead( filePathString );
			var dataString:Object = dataRead.getData();
			var mapString:String = dataString as String;
			initMapData( mapString );
			//test
			_mapGenerate = new KagMapGenerator( TILE_WIDTH, TILE_HEIGHT, tileGroup,this,2 );
			_mapGenerate.generateMap( mapString, auto_tiles );
			
			
			highlightBox = new FlxObject(0, 0, _showWidth, _showHeight);
			
			setupPlayer();
			setupText();
			
			_arrowSprite = new FlxSprite(0, 0);
			_arrowSprite.loadGraphic(arrorPic, true, false, 7, 12  );
			//_arrowSprite.ignoreDrawDebug = false
			add( _arrowSprite );
			createTile();
			
			_explosionSprite1 = new FlxSprite(0, 0);
			_explosionSprite1.loadGraphic( explosionPic, false, false, 24, 24 );
			_explosionSprite1.addAnimation("exp", [0, 1, 2, 3, 4, 5], 12, true);
			_explosionSprite1.immovable = true;
			_explosionSprite1.addAnimationCallback( animationFunction );
			add( _explosionSprite1 );
			
			_expGroup.add( _explosionSprite1 );
			
			_mapGenerate.generateTile( auto_tiles, 100, 150, tileGroup );	
			
			_blockSprite = new FlxSprite(130, 130);
			_blockSprite.loadGraphic( auto_tiles, false, false, TILE_WIDTH, TILE_HEIGHT );
			_blockSprite.frame = 3 * TILE_WIDTH * 2;
			_blockSprite.scale.x = 2;
			_blockSprite.scale.y = 2;
			_blockSprite.angle = 10;
			//_blockSprite.velocity.y = 100;
			_blockSprite.acceleration.y = 500;
			add( _blockSprite );
			_blockTileGroup.add( _blockSprite );
		}
		private function animationFunction( name:String, frame:uint, index:uint ):void
		{
			if ( name == "exp" )
			{
				if ( frame == 5 )
				{
					_explosionSprite1.kill();
				}
			}
		}
		private function createTile():void
		{
			for ( var tileIndex:uint = 0; tileIndex < 20; tileIndex++ )
			{
				var posX:Number = tileIndex * _showWidth;
				_mapGenerate.generateTile( auto_tiles, posX, 200,tileNoGroup);	
				if ( tileIndex < 10 )
				{
					//_mapGenerate.generateTile( auto_tiles, posX, 200,tileGroup );	
				}
				else
				{
					//_mapGenerate.generateTile( auto_tiles, posX, 200,tileNoGroup );	
				}
			}
			
			for ( var tileYIndex:uint = 0; tileYIndex < 10; tileYIndex++ )
			{
				var posY:Number = tileYIndex * _showHeight;
				_mapGenerate.generateTile( auto_tiles, 30, posY, tileNoGroup);	
				_mapGenerate.generateTile( auto_tiles, 85, posY, tileNoGroup);	
			}
		}
		
		private function fireSprite( startX:Number, startY:Number, endX:Number, endY:Number ):void
		{
			var startPoint:FlxPoint = new FlxPoint( startX, startY );
			var endPoint:FlxPoint = new FlxPoint( endX, endY );
			var pathArray:Array = new Array();
			pathArray.push( startPoint );
			pathArray.push( endPoint );
			
			_arrowSprite.stopFollowingPath();
			_testPath = new FlxPath( pathArray );
			
			_arrowSprite.x = startPoint.x;
			_arrowSprite.y = startPoint.y;
			_arrowSprite.followPath( _testPath,300,FlxObject.PATH_FORWARD,true );
		}
		
		private function initMapData( mapString:String ):void
		{
			var rowsArray:Array = mapString.split("\n");
			var rowIndex:int = 0;
			for each( var rowData:String in rowsArray )
			{
				var colIndex:int = 0;
				var colArray:Array = rowData.split(",");
				
				var rowArray:Array = new Array();
				for each( var colData:String in colArray )
				{
					rowArray.push( int(colData) );
				}
				_mapData.push( rowArray );
			}
			
			var overFunc:Boolean = false;
		}
		
		private function updateMap( xPos:int, yPos:int ):void
		{
			var colNumber:int = xPos / _showWidth;
			var rowNumber:int = yPos / _showHeight;
			if ( rowNumber < _mapData.length )
			{
				var columnArray:Array = _mapData[rowNumber];
				if ( columnArray.length > colNumber )
				{
					columnArray[colNumber] = 1;
				}
				else
				{
					columnArray = new Array();
					_mapData.push( columnArray );
					updateColumn( columnArray,rowNumber, rowNumber, colNumber );
				}
			}
			else
			{
				var mapRowLength:int = _mapData.length;
				for ( var generateRowIndex:int = 0; generateRowIndex <= rowNumber; generateRowIndex++ )
				{
					var columnArrayNew:Array = null;
					if ( generateRowIndex >= mapRowLength )
					{
						columnArrayNew = new Array();
						_mapData.push( columnArrayNew );
					}
					else
					{
						columnArrayNew = _mapData[generateRowIndex];
					}
					updateColumn( columnArrayNew, generateRowIndex, rowNumber, colNumber );
				}
			}
		}
		private function updateColumn( columnArray:Array, generateRowIndex:int, rowNumber:int, colNumber:int ):void
		{
			var columnLength:int = columnArray.length;
			for ( var generateColIndex:int = 0; generateColIndex <= colNumber; generateColIndex++ )
			{
				if ( generateColIndex >= columnLength )
				{
					columnArray.push( 0 );
				}
				else
				{
				}
				if ( generateColIndex == colNumber && rowNumber == generateRowIndex )
				{
					columnArray[generateColIndex] = 1;
				}
			}
		}
		private function writeMapToFile():void
		{
			var wholeData:String = "";
			for each( var _rowArray:Array in _mapData )
			{
				var _rowData:String = "";
				for each( var _columnDataValue:int in _rowArray )
				{
					_rowData = _rowData + _columnDataValue.toString() + ",";
				}
				var _writeString:String =  _rowData.substr( 0, _rowData.length - 1 );
				_writeString = _writeString + "\n";
				wholeData = wholeData + _writeString;
			}
			if ( wholeData.length > 0 )
			{
				wholeData =  wholeData.substr( 0, wholeData.length - 1 );	
			}
			
			var kagResPath:KagTxtResourcePath = new KagTxtResourcePath("default_write");
			var filePathString:String = kagResPath.resourcePath;
			
			var writeFile:KagResourceDataWrite = new KagResourceDataWrite();
			writeFile.writeDataToFile( filePathString, wholeData );
			
			_systemNotify.text = _systemText + "map update";
		}
		private function playerNocollideTile( flxObj1:FlxObject, flxObj2:FlxObject ):void
		{
			player.drag.x = 300;
			_playerCollide = false;
		}
		private function playerCollideTile( flxObj1:FlxObject, flxObj2:FlxObject ):void
		{
			player.drag.x = 0;
			
			var playerPosCenterX:Number = player.x + _playerWidthHalf;
			var playerPosCenterY:Number = player.y + _playerHeightHalf
			
			var collidePosCenterX:Number = flxObj2.x + flxObj2.width / 2;
			var collidePosCenterY:Number = flxObj2.y + flxObj2.height / 2;
			
			var xDiff:Number = playerPosCenterX - collidePosCenterX;
			var yDiff:Number = playerPosCenterY - collidePosCenterY;
			var rLength:Number = Math.sqrt( xDiff * xDiff + yDiff * yDiff );
			
			var powerValue:Number = 500;
			flxObj1.velocity.x = xDiff / rLength * powerValue;
			flxObj1.velocity.y = yDiff / rLength * powerValue;
			
			_playerCollide = true;
			
		}
		private var dnum:Number = 300;
		private var _rotateBlock:Boolean = true;
		private function onBlockCollideTile( flxobj1:FlxObject, flxobj2:FlxObject ):void
		{
			_blockSprite.acceleration.y = _blockSprite.acceleration.y + 100;
			dnum = dnum - 50;
			if ( dnum < 0 )
			{
				dnum = 0;
				_rotateBlock = false;
				_blockSprite.acceleration.y = 0;
				_blockSprite.velocity.y = 0;	
			}
			else
			{
				_blockSprite.velocity.y = -dnum;	
			}
		}
		private function arrowCollideTile( flxObj1:FlxObject, flxObj2:FlxObject ):void
		{
			//flxObj1.velocity.y = -200;
			_arrowSprite.stopFollowingPath( );
			_arrowSprite.velocity.x = 0;
			_arrowSprite.velocity.y = 0;
			_explosionSprite1.revive();
			_explosionSprite1.x = _arrowSprite.x + _arrowSprite.width / 2 - _explosionSprite1.width / 2 ;
			_explosionSprite1.y = _arrowSprite.y + _arrowSprite.height / 2  ;
			_explosionSprite1.play("exp");
		}
		private function exploded():void
		{
			var posx:Number = _arrowSprite.x + _arrowSprite.width * 0.5;
			var posy:Number = _arrowSprite.y + _arrowSprite.height * 0.5;
		}
		
		override public function update():void
		{
			if ( _rotateBlock )
			{
				_blockSprite.angle = _blockSprite.angle + 5;	
			}
			// Tilemaps can be collided just like any other FlxObject, and flixel
			// automatically collides each individual tile with the object.
			var overLap:Boolean = FlxG.overlap(player, _expGroup, playerCollideTile);
			if ( overLap == false )
			{
				FlxG.collide( player, tileNoGroup, playerNocollideTile );	
			}
			FlxG.collide( _arrowSprite, tileNoGroup, arrowCollideTile );
			
			FlxG.collide( _blockTileGroup, tileNoGroup, onBlockCollideTile );
						
			var hightLightPoint:FlxPoint = getHightLightBoxPoint();
			highlightBox.x = hightLightPoint.x;
			highlightBox.y = hightLightPoint.y;
			
			if (FlxG.mouse.pressed())
			{
				//_mapGenerate.generateTile( auto_tiles, hightLightPoint.x, hightLightPoint.y );
				//updateMap( hightLightPoint.x, hightLightPoint.y );
				fireSprite( player.x, player.y, FlxG.mouse.x, FlxG.mouse.y );
			}
			
			updatePlayer();
			super.update();
		}
		private function getHightLightBoxPoint():FlxPoint
		{
			var flxPoint:FlxPoint = new FlxPoint();
			flxPoint.x = Math.floor(FlxG.mouse.x / _showWidth) * _showWidth;
			flxPoint.y = Math.floor(FlxG.mouse.y / _showHeight) * _showHeight;
			return flxPoint;
		}
		public override function draw():void
		{
			super.draw();
			highlightBox.drawDebug();
		}
		private function setupText():void
		{
			_textNotify = new FlxText( 0, 200, 200, "Press J to save data." );
			add( _textNotify );
			_systemNotify = new FlxText( 0, 220, 200, _systemText );
			add( _systemNotify );
		}
		private function setupPlayer():void
		{
			player = new FlxSprite(64, 100);
			player.loadGraphic(ImgSpaceman, true, true, 16);
			//player.blend = BlendMode.SUBTRACT;
			
			lineDraw = new FlxSprite( 0, 0 );
			lineDraw.makeGraphic(320, 240, 0x000000 );
			add(lineDraw);
			
			//bounding box tweaks
			player.width = 14;
			player.height = 14;
			player.offset.x = 1;
			player.offset.y = 1;
			
			//basic player physics
			//player.drag.x = 640;
			player.acceleration.y = 300;
			player.maxVelocity.x = 80;
			player.maxVelocity.y = 160;
			
			//animations
			player.addAnimation("idle", [0]);
			player.addAnimation("run", [1, 2, 3, 0], 12);
			player.addAnimation("jump", [4]);
			
			add(player);
			
			_playerWidthHalf = player.width / 2;
			_playerHeightHalf = player.height / 2;
		}
		
		private function updatePlayer():void
		{
			wrap(player);
			
			if ( FlxG.mouse.x > player.x )
			{
				player.facing = FlxObject.RIGHT;
			}
			else
			{
				player.facing = FlxObject.LEFT;
			}
			
			lineDraw.fill( 0x000000 );
			lineDraw.drawLine( player.x + 8 , player.y + 8, FlxG.mouse.x,  FlxG.mouse.y, 0xff0000 );
			lineDraw.drawLine( player.x + 9 , player.y + 8, FlxG.mouse.x + 1,  FlxG.mouse.y, 0xff0000 );
			lineDraw.drawLine( player.x + 10 , player.y + 8, FlxG.mouse.x + 2,  FlxG.mouse.y, 0xff0000 );
			
			if ( FlxG.keys.justPressed("H") )
			{
				//fireSprite( player.x, player.y, FlxG.mouse.x, FlxG.mouse.y );
			}
			//MOVEMENT
			player.acceleration.x = 0;
			if(FlxG.keys.pressed("A"))
			{
				//player.facing = FlxObject.LEFT;
				//player.acceleration.x -= player.drag.x;
				if ( _playerCollide )
				{
					player.acceleration.x -= 100;
				}
				else
				{
					player.acceleration.x -= 300;
				}
			}
			else if(FlxG.keys.pressed("D"))
			{
				//player.facing = FlxObject.RIGHT;
				//player.acceleration.x += player.drag.x;
				if ( _playerCollide )
				{
					player.acceleration.x += 100;
				}
				else
				{
					player.acceleration.x += 300;
				}
			}
			else
			{
				if ( _playerCollide == false )
				{
					player.velocity.x = 0;	
				}
			}
			if(FlxG.keys.justPressed("W") && player.velocity.y == 0)
			{
				//player.y -= 1;
				player.velocity.y = -100;
			}
			
			if ( FlxG.keys.justReleased("J" ) )
			{
				//writeMapToFile();
				
				//_explosionSprite1.play( "exp" );
			}
			
			//ANIMATION
			if(player.velocity.y != 0)
			{
				player.play("jump");
			}
			else if(player.velocity.x == 0)
			{
				player.play("idle");
			}
			else
			{
				player.play("run");
			}
		}
		
		private function wrap(obj:FlxObject):void
		{
			obj.x = (obj.x + obj.width / 2 + FlxG.width) % FlxG.width - obj.width / 2;
			obj.y = (obj.y + obj.height / 2) % FlxG.height - obj.height / 2;
		}
	}
}
