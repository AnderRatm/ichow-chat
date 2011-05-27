package  
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import org.ichow.eelive.draw.Draw;
	
	/**
	 * ...
	 * @author ichow
	 */
	[SWF(backgroundColor="0xCCCCCC")]
	public class Test extends Sprite 
	{
		
		public function Test() 
		{
			var d:Draw = new Draw(new Rectangle(0, 0, 300, 300));
			addChild(d);
		}
		
	}

}