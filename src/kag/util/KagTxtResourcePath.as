package kag.util 
{
	/**
	 * ...
	 * @author kaleidos
	 */
	import kag.util.KagResourceType;
	public class KagTxtResourcePath extends KagResourcePath 
	{
		
		public function KagTxtResourcePath( resFileName:String ) 
		{
			super(resFileName);
			_pathType = KagResourceType.KAG_TYPE_TXT;
		}
		
		protected override function _subPathString():String
		{
			return "mapdata\\";
		}
		protected override function _fileAffix():String
		{
			return ".txt";
		}
	}

}