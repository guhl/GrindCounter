using Toybox.WatchUi;

class GrindProgressDelegate extends WatchUi.BehaviorDelegate
{
    var mCallback;
    function initialize(callback) {
        mCallback = callback;
        BehaviorDelegate.initialize();
    }

    function onBack() {
//        mCallback.invoke();
		mExit = false;
        return true;
    }
}