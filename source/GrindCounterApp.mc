import Toybox.Application;
import Toybox.WatchUi;
import Toybox.Lang;

class GrindCounterApp extends Application.AppBase {

    public function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    public function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    public function onStop(state as Dictionary?)  as Void {
    }

	public function getSettingsCountView() {
        return [new GrindCounterSettingsCountView(),new GrindCounterSettingsCountViewDelegate()];
    } 

	public function getSettingsTimeoutView() {
        return [new GrindCounterSettingsTimeoutView(),new GrindCounterSettingsTimeoutViewDelegate()];
    } 

    // Return the initial view of your application here
    public function getInitialView() as Array<Views or InputDelegates>? {
        return [ new GrindCounterView(), new GrindCounterDelegate() ];
    }

}