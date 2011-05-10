package org.ichow.eelive.core
{
	import org.igniterealtime.xiff.events.BookmarkChangedEvent;
	
	public class OpenFireRoomEssentials
	{
		public function OpenFireRoomEssentials(){
			
			
		}
		
		private var _isPublic:Boolean;
		
		public function get isPublic():Boolean{
			
	       return _isPublic;
	       
     	}
	    
	    public function set isPublic(value:Boolean):void {
	    	
	        _isPublic = value;   
	                     
	    } 
		
		private var _isModerated:Boolean;
		
		public function get isModerated():Boolean{
			
	       return _isModerated;
	       
     	}
	    
	    public function set isModerated(value:Boolean):void {
	    	
	        _isModerated = value;   
	                     
	    } 
	    
	    private var _isPersistent:Boolean;
		
		public function get isPersistent():Boolean{
			
	       return _isPersistent;
	       
     	}
	    
	    public function set isPersistent(value:Boolean):void {
	    	
	        _isPersistent = value;   
	                     
	    } 
		
		private var _isMembersOnly:Boolean;
		
		public function get isMembersOnly():Boolean{
			
	       return _isMembersOnly;
	       
     	}
	    
	    public function set isMembersOnly(value:Boolean):void {
	    	
	        _isMembersOnly = value;   
	                     
	    } 
	    
	    private var _name:String;
		
		public function get name():String {
	       
	       return _name;
     	
     	}
	    
	    public function set name(value:String):void {
	    	
	        _name = value;   
	                     
	    }
	    
	    private var _type:String;
		
		public function get type():String {
	       
	       return _type;
     	
     	}
	    
	    public function set type(value:String):void {
	    	
	        _type = value;   
	                     
	    }
	    
	    private var _category:String;
		
		public function get category():String {
	       
	       return _category;
     	
     	}
	    
	    public function set category(value:String):void {
	    	
	        _category = value;   
	                     
	    }
	    
	    private var _details:ServiceDetails;
		
		public function get details():ServiceDetails{
			
			return _details;
			
		}
		
		public function set details(value:ServiceDetails):void{
			
			_details = value;
			
		}

	}
}