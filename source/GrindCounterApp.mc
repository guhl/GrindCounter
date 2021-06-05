using Toybox.Application;
using Toybox.WatchUi;

class GrindCounterApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

	function getSettingsView() {
        return [new GrindCounterSettingsView(),new GrindCounterSettingsViewDelegate()];
    } 
    // Return the initial view of your application here
    function getInitialView() {
        return [ new GrindCounterView(), new GrindCounterDelegate() ];
    }

}
