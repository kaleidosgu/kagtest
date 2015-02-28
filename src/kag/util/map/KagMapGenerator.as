package kag.util.map 
{
	import org.flixel.FlxGroup;
	import org.flixel.FlxTileblock;
	/**
	 * ...
	 * @author kaleidos
	 */
	public class KagMapGenerator 
	{
		
		private var _tileWidth:int 	= 0;
		private var _tileHeight:int = 0;
		private var _tileGroup:FlxGroup = null;
		private var _drawGroup:FlxGroup = null;
		private var _scaleFact:int = 1;
		public function KagMapGenerator( tileWidth:int, tileHeight:int, tileGroup:FlxGroup, drawGroup:FlxGroup, scaleFact:int = 1 ) 
		{
			_tileWidth 	= tileWidth;
			_tileHeight	= tileHeight;
			_tileGroup 	= tileGroup;
			_drawGroup  = drawGroup;
			_scaleFact	= scaleFact;
		}
		
		public function generateMap( MapData:String,auto_tiles:Class ):void
		{
			var rowsArray:Array = MapData.split("\n");
			var rowIndex:int = 0;
			for each( var rowData:String in rowsArray )
			{
				var colIndex:int = 0;
				var colArray:Array = rowData.split(",");
				for each( var colData:String in colArray )
				{
					if ( colData != "0" && colData.length != 0 )
					{
						var xPos:int = rowIndex * _tileWidth * _scaleFact ;
						var yPos:int = colIndex * _tileHeight * _scaleFact;
						generateTile( auto_tiles, xPos, yPos,null );
					}
					colIndex++;
				}
				rowIndex++;
			}
		}
		
		public function generateTile( auto_tiles:Class, xPos:int, yPos:int,collideGroup:FlxGroup ):void
		{
			var tileGenerated:FlxTileblock = new FlxTileblock( xPos, yPos, _tileWidth, _tileHeight );
			tileGenerated.loadGraphic( auto_tiles, true, true, _tileWidth, _tileHeight );
			tileGenerated.frame = 3 * _tileWidth * _scaleFact;
			
			_scaleTile( tileGenerated );
			_drawGroup.add( tileGenerated );
			collideGroup.add( tileGenerated );
		}
		private function _scaleTile( tileGenerated:FlxTileblock ):void
		{
			tileGenerated.scale.x = _scaleFact;
			tileGenerated.scale.y = _scaleFact;
			tileGenerated.width = _tileWidth * _scaleFact;
			tileGenerated.height = _tileHeight * _scaleFact;
			tileGenerated.offset.x = -(_tileWidth / _scaleFact);
			tileGenerated.offset.y = -(_tileHeight / _scaleFact);
		}
		
	}

}