import Toybox.WatchUi;
import Toybox.Lang;

class GrindProgressDelegate extends WatchUi.BehaviorDelegate
{
//    private var _callback as Method() as Void;

    //! Constructor
    //! @param callback Callback function
    public function initialize(callback as Method() as Void) {
        BehaviorDelegate.initialize();
//        _callback = callback;
    }

    function onBack() as Boolean {
		$.g_exit = false;
        return true;
    }
}