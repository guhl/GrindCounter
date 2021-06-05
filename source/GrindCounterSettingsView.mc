using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application.Properties as Prop;

var mCountTarget = 0;

class GrindCounterSettingsView extends WatchUi.View {

    var mLabelCountTarget;
    
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.SettingsLayout(dc));
        mLabelCountTarget = View.findDrawableById("id_count_target");
        mCountTarget = Prop.getValue("countTarget") == null? DEFAULT_TARGET : Prop.getValue("countTarget");
        mLabelCountTarget.setText(mCountTarget);
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
    	var countTargetPicker = new WatchUi.NumberPicker(WatchUi.NUMBER_PICKER_DISTANCE, mCountTarget);
    	WatchUi.pushView( countTargetPicker, new CountTargetPickerDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class CountTargetPickerDelegate extends WatchUi.NumberPickerDelegate {
    function initialize() {
        NumberPickerDelegate.initialize();
    }

    function onNumberPicked(value) {
        mCountTarget = value; // e.g. 1000f
        Prop.setValue("countTarget", value);
    }
}
