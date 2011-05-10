package org.ichow.eelive.core
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import org.ichow.eelive.events.HashTableEvent
	/**
	 * ...
	 * @author iChow http://www.shootarea.com/iChow/blog
	 */
	public class HashTable extends EventDispatcher
	{
		
		protected var table:Dictionary;
		protected var duplicates:Dictionary;
		protected var lookUp:Dictionary;
		
		private const MIN_TABLE_SIZE:int = 5;
		
		private var initSize:int;
		private var maxSize:int;
		private var currentSize:int;
		
		private var first:HashItem;
		private var last:HashItem;
		private var current:HashItem;
		
		public function HashTable(size:int = 500){
			
			table = new Dictionary(true);
			duplicates = new Dictionary(true);
			lookUp = new Dictionary(true);
			
			initSize = maxSize = Math.max(MIN_TABLE_SIZE, size);
			currentSize = 0;
			
			var item:HashItem = new HashItem();

			first = last = item;

			var k:int = initSize + 1;

			for (var i:int = 0; i < k; i++){

				item.next = new HashItem();
				item = item.next;

			}

			last = item;
			
		}
		
		public function insert(key:*, obj:*):Boolean{
			
			var duplicate:Boolean;
			
			if (key == null)  return false;
			if (obj == null)  return false;
			
			if (table[key]){
				this.dispatchEvent(new HashTableEvent(HashTableEvent.DUPLICATE_ADDED, new Pair(key, obj)));
				duplicate = true;
			} 
			
			if (currentSize++ == maxSize){
				var k:int = (maxSize += initSize) + 1;
				for (var i:int = 0; i < k; i++)	{
					last.next = new HashItem();
					last = last.next;
				}
				this.dispatchEvent(new HashTableEvent(HashTableEvent.SIZE_INCREASED, new Pair(key, obj)));
			}
			
			var item:HashItem = first;
			
			item.name = key;
			item.value = obj;

			first = first.next;

			/* item.name = key;
			item.value = obj; */

			item.next = current;

			if (current) item.previous = current;

			current = item;
			
			if(duplicate){
				duplicates[key] = item;
				currentSize--;
			}else{
				table[key] = item;
			}
			//trace(currentSize)
			lookUp[obj] ? lookUp[obj]++ : lookUp[obj] = 1;
			
			return true;
			
		}
		
		public function find(key:*):*{

			var item:HashItem = table[key];
			var duplicate:HashItem = duplicates[key];
				
			if(duplicate){
				//dispatchEvent(new HashTableEvent(HashTableEvent.KEY_FOUND_IN_DUPLICATES, new Pair(key, duplicate.value)));
			}
			
			if(item){
				return item.value;
			}else{
				return null;
			}

		}
		
		public function getKeys():Array {
			
			var list:Array = [];
			
			for(var key:* in table) {
				
				list.push(key);
				
			}
			
			return list
		}
		
		public function remove(key:*):*	{
			var item:HashItem = table[key];
			if (item){
				var obj:* = item.value;
				delete table[key];
				if (item.previous) item.previous.next = item.next;
				if (item.next) item.next.previous = item.previous;
				if (item == current) current = item.next;
				item.previous = null;
				item.next = null;
				last.next = item;
				last = item;
				if (--lookUp[obj] <= 0){
					delete lookUp[obj];
					
				}
				if (--currentSize <= (maxSize - initSize)){
					var k:int = (maxSize -= initSize) + 1;
					for (var i:int = 0; i < k; i++){
						first = first.next;
						
					}
				}
				return obj;
			}
			return null;
		}
		
		public function get size():int{
			return currentSize;
		}

		public function isEmpty():Boolean{
			return currentSize == 0;
		}
		
		public function contains(obj:*):Boolean{
			return lookUp[obj] > 0;
		}
		
		public function get firstItem():*{
			return first.next;
		}
		
		public function get lastItem():*{
			return last.previous;
		}
		
		public function dump():String{
			var s:String = "HashTable:\n";
			for each (var p:HashItem in table){
				s += "[key: " + p.name + ", val:" + p.value + "]\n";
				
			}
			return s;
		}
		
	}

}