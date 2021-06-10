using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application.Properties as Prop;
using Toybox.Application;

class GrindCounterSettingsView extends WatchUi.View {

    var mLabelCountTarget;
    var mLabelCountTargetText;
    
    function initialize() {
        View.initialize();
    }

    // Update the view
    function onUpdate(dc) {
//        mLabelCountTarget = View.findDrawableById("id_count_target");
//        mLabelCountTargetText = View.findDrawableById("id_count_target_text");
        cnt_target = Prop.getValue("countTarget") == null? DEFAULT_TARGET : Prop.getValue("countTarget");
        mLabelCountTarget.setText(cnt_target.toString());
        View.onUpdate(dc);
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.SettingsLayout(dc));
        mLabelCountTarget = View.findDrawableById("id_count_target");
        mLabelCountTargetText = View.findDrawableById("id_count_target_text");
        cnt_target = Prop.getValue("countTarget") == null? DEFAULT_TARGET : Prop.getValue("countTarget");
        mLabelCountTarget.setText(cnt_target.toString());
        mLabelCountTargetText.setText("Count Target");
    }

}

class GrindCounterSettingsViewDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(evt) {
        var key = evt.getKey();
        if (WatchUi.KEY_START == key || WatchUi.KEY_ENTER == key) {
            return onSelect();
        }
        return false;

    }
    function onSelect() {
        return pushPicker();
    }

    function pushPicker() {
    	var countTargetPicker = new CntPicker();
    	WatchUi.pushView( countTargetPicker, new CountTargetPickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class CountTargetPickerDelegate extends WatchUi.PickerDelegate {

    function initialize() {
        PickerDelegate.initialize();
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onAccept(values) {
        cnt_target = values[0].toLong();
        Prop.setValue("countTarget", cnt_target);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class CntPicker extends WatchUi.Picker {

    function initialize() {
        var title = new WatchUi.Text({:text=>Rez.Strings.CountTargetPickerTitle, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new NumberFactory(1,100,1, {:font=>Graphics.FONT_NUMBER_MEDIUM});
        var defaults = new[1];
        var default_index = cnt_target - 1;
        if (cnt_target != null) {
        	defaults[0] = default_index.toLong();
        }
        Picker.initialize({:title=>title, :pattern=>[factory], :defaults=>defaults});
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
    
}
