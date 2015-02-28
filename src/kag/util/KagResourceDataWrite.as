package kag.util 
{
	/**
	 * ...
	 * @author kaleidos
	 */
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	public class KagResourceDataWrite 
	{
		
		public function KagResourceDataWrite() 
		{
			
		}
		
		public function writeDataToFile( filePath:String, data:String ):void
		{
			var fileOpen:File = new File( filePath );
			//if ( fileOpen.exists )
			{
				var fileStream:FileStream = new FileStream();
				fileStream.open( fileOpen, FileMode.WRITE );
				fileStream.writeUTFBytes(data);
				fileStream.close();
			}
		}
		
	}

}