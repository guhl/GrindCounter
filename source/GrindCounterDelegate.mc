
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class GrindCounterDelegate extends WatchUi.BehaviorDelegate {

    public function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onMenu() as Boolean {
        return false; // allow InputDelegate function to be called
        // return true;
    }
    
    // Detect Menu button input
    public function onKey(keyEvent as KeyEvent) as Boolean {
        System.println(keyEvent.getKey().toString()); // e.g. KEY_MENU = 7
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) { 
        	System.println("Enter pressed -> showing Menu");
	        // Generate a new Menu with a drawable Title
	        var menu = new WatchUi.Menu2({:title=>"GrindCounter"});
        	// Add menu items for demonstrating toggles, checkbox and icon menu items
        	menu.addItem(new WatchUi.MenuItem("Exit", null, "exit", null));
        	menu.addItem(new WatchUi.MenuItem("Save & Exit", null, "save_exit", null));
        	menu.addItem(new WatchUi.MenuItem("Resume", null, "resume", null));
        	menu.addItem(new WatchUi.MenuItem("Count Target", null, "settings_count", null));
        	menu.addItem(new WatchUi.MenuItem("Timeout", null, "settings_timeout", null));
        	WatchUi.pushView(menu, new $.GrindCounterMenu2Delegate(), WatchUi.SLIDE_UP );
        	$.g_currentView = 1;
        	return true;
        } 
        if (keyEvent.getKey() == WatchUi.KEY_MENU) {
	        var menu = new WatchUi.Menu2({:title=>"GrindCounter"});
        	// Add menu items for demonstrating toggles, checkbox and icon menu items
        	menu.addItem(new WatchUi.MenuItem("Count Target", null, "settings_count", null));
        	menu.addItem(new WatchUi.MenuItem("Timeout", null, "settings_timeout", null));
        	WatchUi.pushView(menu, new $.GrindCounterMenu2Delegate(), WatchUi.SLIDE_UP );
        	$.g_currentView = 1;
        	return true;        
        }
        return false;
    }
    
    public function onBack() as Boolean  {
    	$.g_save = false;
    	if ($.g_currentView == 0) {
    		$.g_exit = true;
    	}
    	return false;
    }
    
}