package {
	import com.bit101.components.ComboBox;
	import com.bit101.components.PushButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.si.sion.SiONData;
	import org.si.sion.SiONDriver;
	import org.si.sion.SiONVoice;
	import org.si.sion.utils.SiONPresetVoice;
	/**
	 * ...
	 * @author ichow
	 */
	[SWF(backgroundColor="0xCCCCCC")]
	public class Test extends Sprite {
		private var _driver:SiONDriver;
		private var _s1:SiONData;
		private var _s2:SiONData;

		private var _presets:SiONPresetVoice;
		private var _categories:ComboBox;
		private var _voices:ComboBox;

		public function Test(){
			_driver = new SiONDriver();
			_s1 = _driver.compile('10 uigvhj786');
			_s2 = _driver.compile('l8 o6co5bagfedc');
			_driver.play();
			addSoundButtons();

			onVoice();

		}

		private function onVoice():void {
			_presets = new SiONPresetVoice();
			_categories = new ComboBox(this, 0, 0, "Select a category");

			_voices = new ComboBox(this, _categories.width + _categories.x + 5, 0, "Select a voice");

			populateCategories();

			_categories.addEventListener(Event.SELECT, populateVoices);
		}

		private function populateCategories():void {
			for each (var cat:Array in _presets.categolies)
				_categories.addItem(cat.name);
		}

		private function populateVoices(e:Event = null):void {
			_voices.removeAll();
			_voices.selectedIndex = 0;
			var voices:Array = _presets[_categories.selectedItem];
			for (var i:int = 0; i < voices.length; i++)
				_voices.addItem(voices[i].name);
		}

		public function get voice():SiONVoice {
			if (_categories.selectedItem)
				return _presets[_categories.selectedItem][_voices.selectedIndex];
			else
				return null;
		}

		private function addSoundButtons():void {
			var b1:PushButton = new PushButton(this, 10, 10, "Play sound 1", onPlaySound);
			var b2:PushButton = new PushButton(this, b1.x + b1.width + 5, 10, "Play sound 2", onPlaySound);

			function onPlaySound(e:Event):void {
				if (e.target == b1){
					_driver.sequenceOff(1);
					_driver.sequenceOn(_s1, voice, 0, 0, 1, 1);
				}
				if (e.target == b2){
					_driver.sequenceOff(2);
					_driver.sequenceOn(_s2, voice, 0, 0, 1, 2);
				}
			}
		}


	}

}