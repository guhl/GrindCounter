using Toybox.WatchUi;
using Toybox.Application;

var mExit; 
var mStarted;
var mSave;
var mCurrentView;

class GrindCounterView extends WatchUi.View {

    var mLabelCount;
    var mLabelTarget;
    var mLabelRemaining;
    var mGrindCounter;

    function initialize() {
        View.initialize();
        mGrindCounter = new GrindCounterProcess();
        mExit = false;
        mStarted = false;
        mSave = false;
        mCurrentView = 0;
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        mLabelCount = View.findDrawableById("id_grind_count");
        mLabelTarget = View.findDrawableById("id_grind_target");
        mLabelRemaining = View.findDrawableById("id_grind_remaining");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        mCurrentView = 0;
    	if (!mExit && !mStarted) {
        	mGrindCounter.onStart();
        	mStarted = true;
        }
        if (mExit) {
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // Update the view
    function onUpdate(dc) {
        mLabelCount.setText("Count: " + mGrindCounter.getCount().toString());
        mLabelTarget.setText("Target: " + mGrindCounter.getTarget().toString());
        mLabelRemaining.setText("Remaining: " + mGrindCounter.getRemaining().toString());
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	if (mExit) {
        	mGrindCounter.onStop();
        }
    }

}