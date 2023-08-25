import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Timer;
import Toybox.Application.Properties;
import Toybox.Lang;
import Toybox.Graphics;

const DEFAULT_TARGET as Number = 86;
const DEFAULT_TIMEOUT as Number = 500;
var g_cnt_target as Number = 0;
var g_timeout_target as Number = 0;

var g_exit as Boolean = false; 
var g_started as Boolean = false;
var g_save as Boolean = false;
var g_currentView as Number = 0;

class GrindCounterView extends WatchUi.View {

    private var _labelCount as Text?;
    private var _labelTarget as Text?;
    private var _labelRemaining as Text?;
    private var _grindCounter as GrindCounterProcess;

	// Timeout variables
	private var _timer as Timer.Timer?;
	private var _timeout_count as Number = 0;

    public function initialize() {
        View.initialize();
    	$.g_timeout_target = Properties.getValue("timeoutTarget") == null? DEFAULT_TIMEOUT : Properties.getValue("timeoutTarget");
        _grindCounter = new $.GrindCounterProcess();
        $.g_exit = false;
        $.g_started = false;
        $.g_save = false;
        $.g_currentView = 0;
    }

    // Load your resources here
    public function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _labelCount = View.findDrawableById("id_grind_count") as Text;
        _labelTarget = View.findDrawableById("id_grind_target") as Text;
        _labelRemaining = View.findDrawableById("id_grind_remaining") as Text;
        _timer = new Timer.Timer();
        _timer.start(method(:timeout_callback), 1000, true);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    public function onShow() as Void {
        $.g_currentView = 0;
    	if (!$.g_exit && !$.g_started) {
        	_grindCounter.onStart();
        	$.g_started = true;
        }
        if ($.g_exit) {
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // Update the view
    public function onUpdate(dc as Dc) as Void {
        if (_labelCount != null) {
            _labelCount.setText("Count: " + _grindCounter.getCount());
        }
        if (_labelTarget != null) {
            _labelTarget.setText("Target: " + _grindCounter.getTarget());
        }
        if (_labelRemaining != null) {
            _labelRemaining.setText("Remaining: " + _grindCounter.getRemaining());
        }
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    public function onHide() as Void {
    	if ($.g_exit) {
        	_grindCounter.onStop();
        }
    }
    
	// Callback for timeout timer
    function timeout_callback() as Void {
    	if ($.g_started && _grindCounter.getCount() >= 1) {
        	_timeout_count += 1;
        }
 		System.println( Lang.format("_timeout_count = $1$", [_timeout_count]) );
 		if (_timeout_count >= $.g_timeout_target && $.g_timeout_target > 0) {
	 		System.println( "Timeout reached" );
        	$.g_exit = true;
        	$.g_save = false;
			WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
 		}
    }
     

}