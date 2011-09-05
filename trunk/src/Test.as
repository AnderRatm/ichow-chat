package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.engine.BreakOpportunity;
	import flashx.textLayout.container.ContainerController;
	import flashx.textLayout.container.ScrollPolicy;
	import flashx.textLayout.conversion.ConversionType;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.edit.EditManager;
	import flashx.textLayout.elements.DivElement;
	import flashx.textLayout.elements.TextFlow;
	import flashx.textLayout.events.CompositionCompleteEvent;
	import flashx.textLayout.events.StatusChangeEvent;
	
	/**
	 * ...
	 * @author ichow
	 */
	[SWF(backgroundColor = "0xCCCCCC")]
	public class Test extends Sprite
	{
		private var _canvas : Sprite;
		private var _controller : ContainerController;
		private var _flow : TextFlow;
		private var _manager : EditManager;
		
		public function Test(  )
		{
			
			_canvas = new Sprite();
			
			_controller = new ContainerController( _canvas , 300 , 300 );
			_controller.verticalScrollPolicy = ScrollPolicy.ON
			_controller.horizontalScrollPolicy = ScrollPolicy.AUTO;
			
			_flow = new TextFlow();
			_flow.breakOpportunity = BreakOpportunity.NONE;
			_flow.flowComposer.addController( _controller );
			_manager = new EditManager();
			_flow.interactionManager = _manager;
			updateFlow();
			
			_flow.addEventListener( StatusChangeEvent.INLINE_GRAPHIC_STATUS_CHANGE , graphicStatusChangeEvent );
			_flow.addEventListener( CompositionCompleteEvent.COMPOSITION_COMPLETE , composeListener );
			
			this.addEventListener(MouseEvent.CLICK , onMouseClick );
			this.addChild( _canvas );
		}
		
		private function onMouseClick(e:MouseEvent):void 
		{
			addFace("assets/face/02.swf");
		}
		
		private function updateFlow() : void
		{
			_flow.flowComposer.updateAllControllers();
		}
		
		private function graphicStatusChangeEvent( e : StatusChangeEvent ) : void
		{
			updateFlow();
		}
		
		private function composeListener( e : CompositionCompleteEvent ) : void
		{
			//draw();
		}
		
		/**
		 * add elments to flowtext
		 * @param	message		: String
		 */
		public function addMessage( message : String ) : void
		{
			trace( "addMessage: " + message );
			var div : DivElement = getElement( message );
			_flow.addChild( div );
			updateFlow();
		}
		
		 /**
			 * change html string to elements and return
			 * @param	message		: String
			 * @return	DivElement
			 */
			
			private function getElement( message : String ) : DivElement
		{
			//trace("getElement: " + message);
			var tf : TextFlow = TextConverter.importToFlow( message , TextConverter.TEXT_FIELD_HTML_FORMAT );
			var div : DivElement = new DivElement();
			var len : uint = tf.numChildren;
			for ( var i : uint = 0 ; i < len ; i++ )
			{
				div.addChild( tf.getChildAt( 0 ) );
			}
			return div;
		}
		
		/**
		 * get flow's text after escapeImg
		 * @return	获取HTML(处理图片)
		 */
		public function getMessage() : String
		{
			var html : String = TextConverter.export( _flow , TextConverter.TEXT_FIELD_HTML_FORMAT , ConversionType.STRING_TYPE ) as String;
			return html;
		}
		
		/**
		 * add a face image
		 * @param	url		: url
		 */
		public function addFace( url : String ) : void
		{
			( _manager as EditManager ).insertInlineGraphic( url , "auto" , "auto" );
			updateFlow()
		}
	
	}

}