
using Toybox.WatchUi;
using Toybox.Graphics;

class GrindCounterDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        return false; // allow InputDelegate function to be called
        // return true;
    }
    
    // Detect Menu button input
    function onKey(keyEvent) {
        System.println(keyEvent.getKey()); // e.g. KEY_MENU = 7
        if (keyEvent.getKey() == WatchUi.KEY_ENTER) { 
        	System.println("Enter pressed -> showing Menu");
	        // Generate a new Menu with a drawable Title
	        var menu = new WatchUi.Menu2({:title=>"GrindCounter"});
        	// Add menu items for demonstrating toggles, checkbox and icon menu items
        	menu.addItem(new WatchUi.MenuItem("Exit", null, "exit", null));
        	menu.addItem(new WatchUi.MenuItem("Save & Exit", null, "save_exit", null));
        	menu.addItem(new WatchUi.MenuItem("Resume", null, "resume", null));
        	WatchUi.pushView(menu, new GrindCounterMenu2Delegate(), WatchUi.SLIDE_UP );
        	mCurrentView = 1;
        	return true;
        } 
        return false;
    }
    
    function onBack() {
    	mSave = false;
    	if (mCurrentView == 0) {
    		mExit = true;
    	}
    	return false;
    }
    
}
