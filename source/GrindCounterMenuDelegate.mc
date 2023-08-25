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
        	$.g_exit = true;
        	$.g_save = true;
        	WatchUi.popView(WatchUi.SLIDE_DOWN);  
        } else if ( item.getId().equals("exit") ) {
        	System.println("exit selected");
        	$.g_exit = true;
        	$.g_save = false;
        	WatchUi.popView(WatchUi.SLIDE_DOWN);  
        } else if ( item.getId().equals("resume") ) {
        	System.println("resume selected");
        	$.g_exit = false;
        	$.g_save = false;
			WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if ( item.getId().equals("settings_count") ) {
        	System.println("settings selected");
           	WatchUi.pushView( new GrindCounterSettingsCountView(),new GrindCounterSettingsCountViewDelegate(), WatchUi.SLIDE_DOWN );
        } else if ( item.getId().equals("settings_timeout") ) {
        	System.println("settings selected");
           	WatchUi.pushView( new GrindCounterSettingsTimeoutView(),new GrindCounterSettingsTimeoutViewDelegate(), WatchUi.SLIDE_DOWN );
        } else {
            WatchUi.requestUpdate();
        }
           
    }

    function onBack() {
    	$.g_save = false;
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}