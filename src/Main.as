package
{
	import org.flixel.*;
	[SWF(width="320", height="240", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class Main extends FlxGame
	{
		public function Main()
		{
			var indexCounts:int = 0;
			for ( var ind:int = 0; ind < 5; ind++ )
			{
				if ( ind == 1 )
				{
					continue;
				}
				indexCounts++;
			}
			super(320, 240, PlayState, 1, 20, 20);
		}
	}
}
