import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Properties;
import Toybox.Application;

class GrindCounterSettingsCountView extends WatchUi.View {

    private var _labelCountTarget as Text?;
    private var _labelCountTargetText as Text?;
    
    public function initialize() {
        View.initialize();
    }

    // Update the view
    public function onUpdate(dc as Dc) {
        $.g_cnt_target = Properties.getValue("countTarget") == null? DEFAULT_TARGET : Properties.getValue("countTarget");
        _labelCountTarget.setText($.g_cnt_target.toString());
        View.onUpdate(dc);
    }

    //! Load your resources here
    public function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.SettingsCountLayout(dc));
        _labelCountTarget = View.findDrawableById("id_count_target");
        _labelCountTargetText = View.findDrawableById("id_count_target_text");
        $.g_cnt_target = Properties.getValue("countTarget") == null? DEFAULT_TARGET : Properties.getValue("countTarget");
        _labelCountTarget.setText($.g_cnt_target.toString());
        _labelCountTargetText.setText("Count Target");
    }

}

class GrindCounterSettingsCountViewDelegate extends WatchUi.BehaviorDelegate {

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
    	var countTargetPicker = new CntPicker();
    	WatchUi.pushView( countTargetPicker, new CountTargetPickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class CountTargetPickerDelegate extends WatchUi.PickerDelegate {

    public function initialize() {
        PickerDelegate.initialize();
    }

    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }

    public function onAccept(values as Array) as Boolean {
        $.g_cnt_target = values[0].toLong();
        Properties.setValue("countTarget", $.g_cnt_target);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class CntPicker extends WatchUi.Picker {

    public function initialize() {
        var title = new WatchUi.Text({:text=>Rez.Strings.CountTargetPickerTitle, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new NumberFactory(1,299,1, {:font=>Graphics.FONT_NUMBER_MILD});
        var defaults = new[1];
        var default_index = $.g_cnt_target - 1;
        if ($.g_cnt_target != null) {
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
