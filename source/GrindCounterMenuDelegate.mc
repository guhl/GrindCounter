using Toybox.WatchUi;
using Toybox.Graphics;

// This is the menu input delegate for the main menu of the application
class GrindCounterMenu2Delegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        if( item.getId().equals("save_exit") ) {
        	System.println("save_exit selected");
        	mExit = true;
        	mSave = true;
        	WatchUi.popView(WatchUi.SLIDE_DOWN);  
        } else if ( item.getId().equals("exit") ) {
        	System.println("exit selected");
        	mExit = true;
        	mSave = false;
        	WatchUi.popView(WatchUi.SLIDE_DOWN);  
        } else if ( item.getId().equals("resume") ) {
        	System.println("resume selected");
        	mExit = false;
        	mSave = false;
			WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else {
            WatchUi.requestUpdate();
        }
           
    }

    function onBack() {
    	mSave = false;
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

