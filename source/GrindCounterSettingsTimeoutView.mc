import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Application;

class GrindCounterSettingsTimeoutView extends WatchUi.View {

    private var _labelTimeoutTarget as Text?;
    private var _labelTimeoutTargetText as Text?;
    
    public function initialize() {
        View.initialize();
    }

    // Update the view
    public function onUpdate(dc as Dc) {
        $.g_timeout_target = Properties.getValue("timeoutTarget") == null? DEFAULT_TIMEOUT : Properties.getValue("timeoutTarget");
        _labelTimeoutTarget.setText($.g_timeout_target.toString());
        View.onUpdate(dc);
    }

    //! Load your resources here
    public function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.SettingsTimeoutLayout(dc));
        _labelTimeoutTarget = View.findDrawableById("id_timeout_target");
        _labelTimeoutTargetText = View.findDrawableById("id_timeout_target_text");
        $.g_timeout_target = Properties.getValue("timeoutTarget") == null? DEFAULT_TIMEOUT : Properties.getValue("timeoutTarget");
        _labelTimeoutTarget.setText($.g_timeout_target.toString());
        _labelTimeoutTargetText.setText("Timeout Target");
    }

}

class GrindCounterSettingsTimeoutViewDelegate extends WatchUi.BehaviorDelegate {

    public function initialize() {
        BehaviorDelegate.initialize();
    }

    public function onKey(evt as KeyEvent) as Boolean {
        var key = evt.getKey();
        if (WatchUi.KEY_START == key || WatchUi.KEY_ENTER == key) {
            return onSelect();
        }
        return false;

    }
    public function onSelect() as Boolean {
        return pushPicker();
    }

    public function pushPicker() as Boolean {
    	var timeoutTargetPicker = new TimeoutPicker();
    	WatchUi.pushView( timeoutTargetPicker, new TimeoutTargetPickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class TimeoutTargetPickerDelegate extends WatchUi.PickerDelegate {

    public function initialize() {
        PickerDelegate.initialize();
    }

    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    public function onAccept(values as Array) as Boolean {
        $.g_timeout_target = values[0].toLong();
        Properties.setValue("timeoutTarget", $.g_timeout_target);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class TimeoutPicker extends WatchUi.Picker {

    public function initialize() {
        var title = new WatchUi.Text({:text=>Rez.Strings.TimeoutTargetPickerTitle, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new NumberFactory(0,999,1, {:font=>Graphics.FONT_NUMBER_MILD});
        var defaults = new[1];
        var default_index = $.g_timeout_target;
        if ($.g_timeout_target != null) {
        	defaults[0] = default_index.toLong();
        }
        Picker.initialize({:title=>title, :pattern=>[factory], :defaults=>defaults});
    }

    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
    
}
