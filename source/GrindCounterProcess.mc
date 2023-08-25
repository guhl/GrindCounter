import Toybox.WatchUi;
import Toybox.Sensor;
import Toybox.Math;
import Toybox.SensorLogging;
import Toybox.ActivityRecording;
import Toybox.System;
import Toybox.FitContributor;
import Toybox.Application.Properties;
import Toybox.Attention;
import Toybox.Lang;

// Grind counter class
class GrindCounterProcess {

    // --- High level detection threshold
    private const HIGH_THR = 0.25f;
    // --- Distance between low and high
    private const DIST_THR = 0.8f;
    // --- Min duration between grinds, [samples]
    private const TIME_PTC = 7;
    private const CURR_GRIND_COUNT_FIELD_ID = 0;
    private const TOTAL_GRIND_COUNT_FIELD_ID = 1;
    private const VIBRATE_DUTY_CYCLE = 100;
    private const VIBRATE_LENGTH = 2000;

    private var _x as Array<Float> = [0.0] as Array<Float>;
//    private var _y as Array<Number> = [0] as Array<Number>;
//    private var _z as Array<Number> = [0] as Array<Number>;
    private var _filter as FirFilter?;
    private var _grindCount as Number = 0;
    private var _logger as SensorLogger?;
	private var _session as Session?;
    private var _sampleCount as Number = 0;
    private var _lastSampleCount as Number = 0;
    // FIT Contributions variables
    private var _currentGrindCountField = null;
    private var _totalGrindCountField = null;
    
    private var _reachedGoal;
    
    private var _progressBar;
    private var _progressStarted;
	private var _progressValue = 0.0;
	
    private var min_x = 0;
    private var max_x = 0;

    // Return min of two values
    private function min(a as Float or Number, b as Float or Number) as Float or Number {
        if(a < b) {
            return a;
        }
        else {
            return b;
        }
    }

    // Return max of two values
    private function max(a as Float or Number, b as Float or Number) as Float or Number {
        if(a > b) {
            return a;
        }
        else {
            return b;
        }
    }

    // Constructor
    public function initialize() {
    	// read our settings
    	$.g_cnt_target = Properties.getValue("countTarget") == null? DEFAULT_TARGET : Properties.getValue("countTarget");
    	_reachedGoal = false;
    	_progressStarted = false;
        // initialize FIR filter
        var options = {:coefficients => [ -0.0278f, 0.9444f, -0.0278f ] as Array<Float>, :gain => 0.001f};
        try {
            _filter = new Math.FirFilter(options);
            _logger = new SensorLogging.SensorLogger({:enableAccelerometer => true});
            _session = ActivityRecording.createSession({:name=>"GrindCounter", :sport=>ActivityRecording.SPORT_GENERIC});
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    // Callback to receive accel data
    public function accel_callback(sensorData as SensorData) as Void {
        var accelData = sensorData.accelerometerData;
        if (accelData != null) {
            if (_filter != null) {
                _x = _filter.apply(accelData.x);
            }
//            _y = accelData.y;
//            _z = accelData.z;
            onAccelData();
        }
    }
	
    // Start grind counter
    public function onStart() as Void {
        // initialize accelerometer
        var options = {:period => 1, :sampleRate => 25, :enableAccelerometer => true};
        try {
            Sensor.registerSensorDataListener(method(:accel_callback), options);
            if (_session != null) {
                _session.start();
                // create Fields
                _currentGrindCountField = _session.createField("currGrindCount", CURR_GRIND_COUNT_FIELD_ID, FitContributor.DATA_TYPE_UINT16, { :nativeNum=>54, :mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"CT" });
                _currentGrindCountField.setData(0);
                _totalGrindCountField = _session.createField("totalGrindCount", TOTAL_GRIND_COUNT_FIELD_ID, FitContributor.DATA_TYPE_UINT16, { :nativeNum=>95, :mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"CT" });
                _totalGrindCountField.setData(0);
            }
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    // Stop grind counter
    public function onStop() as Void {
    	Sensor.unregisterSensorDataListener();
        if (_session != null) {
            _session.stop();
        }
    	if (!$.g_save) {
        	System.println("discarding session onStop");
        	_session.discard();
    	} else {
        	System.println("saving session onStop");
        	_session.save();        
    	}
	}

    // Return current grind count
    function getCount() as Number {
        return _grindCount;
    }

    // Return current grind count
    public function getSamples() as Number? {
        if (_logger != null) {
            var stats = _logger.getStats();
            if (stats != null) {
                return stats.sampleCount;
            }
        }
        return null;
    }

    // Return current grind count
    public function getPeriod() as Number? {
        if (_logger != null) {
            var stats = _logger.getStats();
            if (stats != null) {
                return stats.samplePeriod;
            }
        }
        return null;
    }

    // Return target grind count
    public function getTarget() as Number {
        return $.g_cnt_target;
    }

    // Return remaining grind count
    public function getRemaining() as Number {
    	if (_grindCount < $.g_cnt_target ) {
    		return ( $.g_cnt_target - _grindCount );
    	} else {
    		return 0;
    	}
    }
    
    public function stopProgress() as Void {
    }    

    // Process new accel data
    private function onAccelData() {
        var cur_acc_x = 0;
//        var cur_acc_y = 0;
//        var cur_acc_z = 0;
        var time = 0;

        for(var i = 0; i < _x.size(); ++i) {
        
        	if ( _x[i] < -1.0 || _x[i] > 1 ) {
        		cur_acc_x = 0;
        	} else {
        		cur_acc_x = _x[i];
        		_sampleCount++;
            }
//            cur_acc_y = _y[i];
//            cur_acc_z = _z[i];

            min_x = min(min_x, cur_acc_x);
            max_x = max(max_x, cur_acc_x);

            // System.println( Lang.format("_x[$1$] = $2$; min_x = $3$; cur_acc_x = $4$; dist = $5$; _sampleCount = $6$", [i, _x[i], min_x, cur_acc_x, (cur_acc_x-min_x), _sampleCount]) );
            
            // --- Grinding motion?
            if( ( cur_acc_x > HIGH_THR && (cur_acc_x-min_x) > DIST_THR ) && (_sampleCount-_lastSampleCount) > TIME_PTC ) {
            	_grindCount++;
        		_currentGrindCountField.setData(_grindCount);
				_totalGrindCountField.setData(_grindCount);
        		// System.println( Lang.format("_grindCount = $1$", [_grindCount]) );
            	// set min_x to high value
            	min_x = 1.0;
            	_lastSampleCount = _sampleCount;

	            if (!_progressStarted && _grindCount > 0) {
	            	_progressStarted = true;
	            	_progressBar = new WatchUi.ProgressBar("Grinding", null);
	            	$.g_currentView = 2;
	            	WatchUi.pushView( _progressBar, new GrindProgressDelegate(method(:stopProgress)), WatchUi.SLIDE_DOWN );
	            }
	            if (!_reachedGoal && _grindCount >= $.g_cnt_target) {
	            	_reachedGoal = true;
	            	reachedGoalAlert();
	            	if ( $.g_currentView == 2 ) {
	            		WatchUi.popView( WatchUi.SLIDE_UP );
	            	}
	            }
	            if (_progressStarted && _grindCount > 0) {
	            	_progressValue = ( _grindCount.toDouble() / $.g_cnt_target.toDouble() ) * 100.0;
//        			System.println(_progressValue);
	            	_progressBar.setProgress( _progressValue );
	            	_progressBar.setDisplayString( _grindCount.toString() );
	            }
            }
            time++;
        }
        WatchUi.requestUpdate();
    }
    
    private function reachedGoalAlert() as Void {
    	if (System.getDeviceSettings().vibrateOn) {
    		Attention.vibrate([new Attention.VibeProfile(VIBRATE_DUTY_CYCLE, VIBRATE_LENGTH)]);
    	}
    	if (Attention has :playTone && System.getDeviceSettings().tonesOn) {
    		Attention.playTone(Attention.TONE_SUCCESS);
    	}
    }
}