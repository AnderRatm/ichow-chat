package org.ichow.eelive.utils 
{
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class ChatStyle 
	{
		private static var _instance:ChatStyle;
		private var formatObj:Object;
		
		public var contentColor:String = "ffffff";//内容颜色
        public var selfColor:String = "0074E7";//说话者颜色
        public var youColor:String = "66ccff";//听者颜色
        public var systemColor:String = "ff0000";//系统颜色
        public var asideColor:String = "ffffff";//旁白颜色
        public var headColor:String = "ff0000";//头部颜色
		
		
		public function ChatStyle() 
		{
			formatObj = new Object();
		}
		//添加记录，参数项：content，system，self，you
        public function addRecord(_format:String,parameter:Object):String{
            if(formatObj[_format]){
                var formatObj:Object = formatObj[_format];
                var formatStr:String = formatObj.text;
				//formatStr = formatObj.head + formatStr;
                formatStr = color(headColor,formatObj.head) + formatStr;
                if(formatStr.indexOf("$content") != -1) formatStr = formatStr.replace(/\$content/g,(parameter.content));
                if(formatStr.indexOf("$system") != -1) formatStr = formatStr.replace(/\$system/g,(parameter.system));
                if (formatStr.indexOf("$self") != -1) formatStr = formatStr.replace(/\$self/g, color(selfColor, event(parameter.self)));
                if (formatStr.indexOf("$you") != -1) formatStr = formatStr.replace(/\$you/g, color(youColor, event(parameter.you)));
				if (formatStr.indexOf("$time") != -1) formatStr = formatStr.replace(/\$time/g, color(selfColor, parameter.time));
                //formatStr = last(formatStr);
                formatObj = null;
				return formatStr;
            }else{
                throw new Error("找不到 " + _format + " 格式！");
            }
			return "";
			
        }
		
		//添加格式，Object格式：{text:"$self对$you说：$content",head:"【说话】"}
		public function setFormat(mark:String,_format:Object):void{
            formatObj[mark] = _format;
        }
		
		public function clear():void{
            formatObj = null;
        }
		
		public function color(_color:String,str:String):String{
            return "<font color=\"#" + _color + "\">" + str + "</font>";
        }
		
		public function event(_event:String):String{
            return "<a href=\"event:" + _event + "\">" + _event + "</a>"
        }
        
        public function last(str:String):String{
            return "<p>" + color(asideColor,str) + "</p>";
        }
		
		public static function get instance():ChatStyle {
			if (!_instance) {
				_instance = new ChatStyle();
			}
			return _instance;
		}
		
	}

}