/**
 * ScrollBar.as
 * Keith Peters
 * version 0.9.9
 * 
 * Base class for HScrollBar and VScrollBar
 * 
 * Copyright (c) 2011 Keith Peters
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package org.ichow.components
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;

	[Event(name="change", type="flash.events.Event")]
	public class ScrollBar extends Component
	{
		protected const DELAY_TIME:int = 500;
		protected const REPEAT_TIME:int = 100; 
		protected const UP:String = "up";
		protected const DOWN:String = "down";

        protected var _autoHide:Boolean = false;
		protected var _upButton:PushButton;
		protected var _downButton:PushButton;
		protected var _scrollSlider:ScrollSlider;
		protected var _orientation:String;
		protected var _lineSize:int = 1;
		protected var _delayTimer:Timer;
		protected var _repeatTimer:Timer;
		protected var _direction:String;
		protected var _shouldRepeat:Boolean = false;
		
		/**
		 * Constructor
		 * @param orientation Whether this is a vertical or horizontal slider.
		 * @param parent The parent DisplayObjectContainer on which to add this Slider.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
		 */
		public function ScrollBar(orientation:String, 
								  parent:DisplayObjectContainer = null, 
								  xpos:Number = 0, ypos:Number = 0, 
								  defaultHandler:Function = null,
								  skins:Dictionary=null
								  )
		{
			
			_skins = skins||Style.VERTICAL_SCROLL_BAR_SKIN;
			_orientation = orientation;
			super(parent, xpos, ypos);
			if(defaultHandler != null)
			{
				addEventListener(Event.CHANGE, defaultHandler);
			}
		}
		
		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void
		{
			
			_scrollSlider = new ScrollSlider(_orientation, this, 0, 10, onChange, _skins[_orientation + "_slider"]);
			_upButton = new PushButton(this, 0, 0, "", null, _skins[_orientation + "_up"]);
			_upButton.addEventListener(MouseEvent.MOUSE_DOWN, onUpClick);
			_upButton.setSize(15, 14);
			
			_downButton = new PushButton(this, 0, 0, "", null, _skins[_orientation + "_down"]);
			_downButton.addEventListener(MouseEvent.MOUSE_DOWN, onDownClick);
			_downButton.setSize(15, 14);
			
		}
		
		/**
		 * Initializes the component.
		 */
		protected override function init():void
		{
			super.init();
			if(_orientation == Slider.HORIZONTAL)
			{
				setSize(100, 15);
			}
			else
			{
				setSize(15, 100);
			}
			_delayTimer = new Timer(DELAY_TIME, 1);
			_delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onDelayComplete);
			_repeatTimer = new Timer(REPEAT_TIME);
			_repeatTimer.addEventListener(TimerEvent.TIMER, onRepeat);
		}
		
		
		
		///////////////////////////////////
		// public methods
		///////////////////////////////////
		
		/**
		 * Convenience method to set the three main parameters in one shot.
		 * @param min The minimum value of the slider.
		 * @param max The maximum value of the slider.
		 * @param value The value of the slider.
		 */
		public function setSliderParams(min:Number, max:Number, value:Number):void
		{
			_scrollSlider.setSliderParams(min, max, value);
		}
		
		/**
		 * Sets the percentage of the size of the thumb button.
		 */
		public function setThumbPercent(value:Number):void
		{
			_scrollSlider.setThumbPercent(value);
		}
		
		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void
		{
			super.draw();
			if(_orientation == Slider.VERTICAL)
			{
				_scrollSlider.x = 0;
				_scrollSlider.y = 14;
				_scrollSlider.width = _upButton.width;
				_scrollSlider.height = _height - 28;
				_downButton.x = 0;
				_downButton.y = _height - 14;
			}
			else
			{
				_scrollSlider.x = 10;
				_scrollSlider.y = 0;
				_scrollSlider.width = _width - 20;
				_scrollSlider.height = 10;
				_downButton.x = _width - 10;
				_downButton.y = 0;
			}
			_scrollSlider.draw();
            if(_autoHide)
            {
                visible = _scrollSlider.thumbPercent < 1.0;
            }
            else
            {
                visible = true;
            }
		}

		
		
		
		
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////

        /**
         * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
         */
        public function set autoHide(value:Boolean):void
        {
            _autoHide = value;
            invalidate();
        }
        public function get autoHide():Boolean
        {
            return _autoHide;
        }

		/**
		 * Sets / gets the current value of this scroll bar.
		 */
		public function set value(v:Number):void
		{
			_scrollSlider.value = v;
		}
		public function get value():Number
		{
			return _scrollSlider.value;
		}
		
		/**
		 * Sets / gets the minimum value of this scroll bar.
		 */
		public function set minimum(v:Number):void
		{
			_scrollSlider.minimum = v;
		}
		public function get minimum():Number
		{
			return _scrollSlider.minimum;
		}
		
		/**
		 * Sets / gets the maximum value of this scroll bar.
		 */
		public function set maximum(v:Number):void
		{
			_scrollSlider.maximum = v;
		}
		public function get maximum():Number
		{
			return _scrollSlider.maximum;
		}
		
		/**
		 * Sets / gets the amount the value will change when up or down buttons are pressed.
		 */
		public function set lineSize(value:int):void
		{
			_lineSize = value;
		}
		public function get lineSize():int
		{
			return _lineSize;
		}
		
		/**
		 * Sets / gets the amount the value will change when the back is clicked.
		 */
		public function set pageSize(value:int):void
		{
			_scrollSlider.pageSize = value;
			invalidate();
		}
		public function get pageSize():int
		{
			return _scrollSlider.pageSize;
		}
		

		
		
		
		
		///////////////////////////////////
		// event handlers
		///////////////////////////////////
		
		protected function onUpClick(event:MouseEvent):void
		{
			goUp();
			_shouldRepeat = true;
			_direction = UP;
			_delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
				
		protected function goUp():void
		{
			_scrollSlider.value -= _lineSize;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onDownClick(event:MouseEvent):void
		{
			goDown();
			_shouldRepeat = true;
			_direction = DOWN;
			_delayTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseGoUp);
		}
		
		protected function goDown():void
		{
			_scrollSlider.value += _lineSize;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		protected function onMouseGoUp(event:MouseEvent):void
		{
			_delayTimer.stop();
			_repeatTimer.stop();
			_shouldRepeat = false;
		}
		
		protected function onChange(event:Event):void
		{
			dispatchEvent(event);
		}
		
		protected function onDelayComplete(event:TimerEvent):void
		{
			if(_shouldRepeat)
			{
				_repeatTimer.start();
			}
		}
		
		protected function onRepeat(event:TimerEvent):void
		{
			if(_direction == UP)
			{
				goUp();
			}
			else
			{
				goDown();
			}
		}
		



	}
}



import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import org.ichow.components.Slider;
import org.ichow.components.Style;

/**
 * Helper class for the slider portion of the scroll bar.
 */
class ScrollSlider extends Slider
{
	protected var _thumbPercent:Number = 1.0;
	protected var _pageSize:int = 1;
	
	/**
	 * Constructor
	 * @param orientation Whether this is a vertical or horizontal slider.
	 * @param parent The parent DisplayObjectContainer on which to add this Slider.
	 * @param xpos The x position to place this component.
	 * @param ypos The y position to place this component.
	 * @param defaultHandler The event handling function to handle the default event for this component (change in this case).
	 */
	public function ScrollSlider(orientation:String, parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultHandler:Function = null,skins:Dictionary=null)
	{
		super(orientation, parent, xpos, ypos, null, skins);
		if(defaultHandler != null)
		{
			addEventListener(Event.CHANGE, defaultHandler);
		}
	}
	
	/**
	 * Initializes the component.
	 */
	protected override function init():void
	{
		super.init();
		setSliderParams(1, 1, 0);
		backClick = true;
	}
	
	/**
	 * Draws the handle of the slider.
	 */
	override protected function drawHandle() : void
	{
		var size:Number;
		_handle.graphics.clear();
		if(_orientation == HORIZONTAL)
		{
			size = Math.round(_width * _thumbPercent);
			size = Math.max(_height, size);

			_handle.width = size;
			_handle.height = _height;
		}
		else
		{
			size = Math.round(_height * _thumbPercent);
			size = Math.max(_width, size);
			
			_handle.width = _width;
			_handle.height = size;
		}
		_handle.graphics.endFill();
		positionHandle();
	}
	
	/**
	 * Adjusts position of handle when value, maximum or minimum have changed.
	 * TODO: Should also be called when slider is resized.
	 */
	protected override function positionHandle():void
	{
		var range:Number;
		if(_orientation == HORIZONTAL)
		{
			range = width - _handle.width;
			_handle.x = (_value - _min) / (_max - _min) * range;
		}
		else
		{
			range = height - _handle.height;
			_handle.y = (_value - _min) / (_max - _min) * range;
		}
	}
	
	
	
	///////////////////////////////////
	// public methods
	///////////////////////////////////
	
	/**
	 * Sets the percentage of the size of the thumb button.
	 */
	public function setThumbPercent(value:Number):void
	{
		_thumbPercent = Math.min(value, 1.0);
		invalidate();
	}
	
	
	
	
	
	///////////////////////////////////
	// event handlers
	///////////////////////////////////
	
	/**
	 * Handler called when user clicks the background of the slider, causing the handle to move to that point. Only active if backClick is true.
	 * @param event The MouseEvent passed by the system.
	 */
	protected override function onBackClick(event:MouseEvent):void
	{
		if(_orientation == HORIZONTAL)
		{
			if(mouseX < _handle.x)
			{
				if(_max > _min)
				{
					_value -= _pageSize;
				}
				else
				{
					_value += _pageSize;
				}
				correctValue();
			}
			else
			{
				if(_max > _min)
				{
					_value += _pageSize;
				}
				else
				{
					_value -= _pageSize;
				}
				correctValue();
			}
			positionHandle();
		}
		else
		{
			if(mouseY < _handle.y)
			{
				if(_max > _min)
				{
					_value -= _pageSize;
				}
				else
				{
					_value += _pageSize;
				}
				correctValue();
			}
			else
			{
				if(_max > _min)
				{
					_value += _pageSize;
				}
				else
				{
					_value -= _pageSize;
				}
				correctValue();
			}
			positionHandle();
		}
		dispatchEvent(new Event(Event.CHANGE));
		
	}
	
	/**
	 * Internal mouseDown handler. Starts dragging the handle.
	 * @param event The MouseEvent passed by the system.
	 */
	protected override function onDrag(event:MouseEvent):void
	{
		stage.addEventListener(MouseEvent.MOUSE_UP, onDrop);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onSlide);
		if(_orientation == HORIZONTAL)
		{
			_handle.startDrag(false, new Rectangle(0, 0, _width - _handle.width, 0));
		}
		else
		{
			_handle.startDrag(false, new Rectangle(0, 0, 0, _height - _handle.height));
		}
	}
	
	/**
	 * Internal mouseMove handler for when the handle is being moved.
	 * @param event The MouseEvent passed by the system.
	 */
	protected override function onSlide(event:MouseEvent):void
	{
		var oldValue:Number = _value;
		if(_orientation == HORIZONTAL)
		{
			if(_width == _handle.width)
			{
				_value = _min;
			}
			else
			{
				_value = _handle.x / (_width - _handle.width) * (_max - _min) + _min;
			}
		}
		else
		{
			if(_height == _handle.height)
			{
				_value = _min;
			}
			else
			{
				_value = _handle.y / (_height - _handle.height) * (_max - _min) + _min;
			}
		}
		if(_value != oldValue)
		{
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
	
	
	
	
	
	///////////////////////////////////
	// getter/setters
	///////////////////////////////////
		
	/**
	 * Sets / gets the amount the value will change when the back is clicked.
	 */
	public function set pageSize(value:int):void
	{
		_pageSize = value;
		invalidate();
	}
	public function get pageSize():int
	{
		return _pageSize;
	}

    public function get thumbPercent():Number
    {
        return _thumbPercent;
    }
}