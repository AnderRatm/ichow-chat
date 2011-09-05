package
{
	import com.bit101.components.Style;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.CSSLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.XMLLoader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import flash.text.StyleSheet;
	import org.ichow.eelive.managers.FormManager;
	import org.ichow.eelive.managers.SparkManager;
	import org.ichow.eelive.managers.tools.ToolsManager
	import org.ichow.eelive.utils.ChatStyle;
	
	/**
	 * ...
	 * @author ichow
	 */
	//[Frame( factoryClass="Preloader" )]
	[SWF( width="500",height="600" )]
	
	public class Main extends Sprite
	{
		//默认配置
		private var def_config : Object = { 
											autologin: "false" , 
											password: "iccc" , 
											username: "iccc" , 
											server: "localhost" , 
											domain: "ichow" , 
											port: "5222" , 
											location: "" , 
											useexternalauth: false , 
											connectiontype: "def" , 
											resource: "eelive" 
										};
		
		private var _config : Object;
		private var _forms : Object;
		private var _xml : XML;
		private var _headXML : XML;
		private var _facesXML : XML;
		private var _skin : SWFLoader;
		private var _css : StyleSheet;
		private var canvas : Sprite;
		
		public function Main() : void
		{
			if ( stage )
				init();
			else
				addEventListener( Event.ADDED_TO_STAGE , init );
		}
		
		private function init( e : Event = null ) : void
		{
			removeEventListener( Event.ADDED_TO_STAGE , init );
			VersionInfo.init( this );
			Security.allowDomain( "*" );
			Security.allowInsecureDomain( "*" );
			//get parameters
			if ( stage.loaderInfo.parameters != null )
			{
				var obj : Object = stage.loaderInfo.parameters;
				_config = obj;
			}
			//load config xml
			LoaderMax.activate([ CSSLoader , SWFLoader , XMLLoader , ImageLoader ] );
			canvas = new Sprite();
			addChild( canvas );
			var url : String = "assets/xml/config.xml";
			var path : String = stage.loaderInfo.url;
			path = path.substr( 0 , path.lastIndexOf( "ichoweelive.swf" ) );
			_config[ "path" ] = path;
			var l : XMLLoader = new XMLLoader( path + url , { name: "config" , onComplete: onConfigComplete } );
			l.load( true );
			stage.addEventListener( Event.RESIZE , onResize );
			onResize();
		}
		
		/**
		 * 屏幕变化
		 * @param	e
		 */
		private function onResize( e : Event = null ) : void
		{
			var w : int = Math.floor( stage.stageWidth );
			var h : int = Math.floor( stage.stageHeight );
			canvas.graphics.clear();
			canvas.graphics.beginFill( 0xFFFFFF , .2 );
			canvas.graphics.drawRect( w / -2 , h / -2 , w , h );
			canvas.graphics.endFill();
		}
		
		/**
		 * 初始化窗口
		 */
		private function initForms() : void
		{
			_forms = new Object();
			SparkManager.configProvider = getConfigValueForKey;
			FormManager.init( canvas , _xml );
		}
		
		/**
		 * 素材加载完成
		 * @param	e
		 */
		private function onConfigComplete( e : LoaderEvent ) : void
		{
			//获取素材
			_xml = new XML( LoaderMax.getContent( "config" ).composition );
			_skin = LoaderMax.getLoader( "skinSWF" );
			_css = LoaderMax.getContent( "skinCSS" );
			_headXML = new XML( LoaderMax.getContent( "head" ) );
			_facesXML = new XML( LoaderMax.getContent( "faces" ) );
			//图标
			ToolsManager.vcardManager.loadItems( _headXML );
			ToolsManager.facesManager.loadItems( _facesXML );
			//样式
			ChatStyle.instance.setFormat( "system" , { text: "$content" , head: "【系统】" } );
			ChatStyle.instance.setFormat( "chat" , { text: "$self  $time $content" , head: "【聊天】" } );
			//设置素材
			//Style.cssStyle = _css;
			//Style.skinSwf = _skin;
			Style.embedFonts = false;
			Style.fontName = "微软雅黑";
			Style.fontSize = 12;
			//初始框架
			initForms();
		}
		
		/**
		 * 获取配置属性
		 * @param	key
		 * @return
		 */
		private function getConfigValueForKey( key : String ) : String
		{
			return _config[ key ] != null ? _config[ key ] : def_config[ key ] != null ? def_config[ key ] : "";
		}
	}

}