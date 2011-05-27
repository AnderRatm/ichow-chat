package org.ichow.eelive.utils 
{
	/**
	 * ...
	 * @author ichow
	 */
	public class DateUtil 
	{
		
		public function DateUtil() 
		{
			
		}
		
		public static function getDate():String {
			var date:Date = new Date();
			return date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
		}
		
	}

}