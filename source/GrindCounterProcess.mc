using Toybox.WatchUi;
using Toybox.Sensor;
using Toybox.Math;
using Toybox.SensorLogging;
using Toybox.ActivityRecording;
using Toybox.System as Sy;
using Toybox.FitContributor;
using Toybox.Application.Properties as Prop;
using Toybox.Attention as Attn;

// --- High level detection threshold
const HIGH_THR = 0.25f;

// --- Distance between low and high
const DIST_THR = 0.8f;

// --- Min duration between grinds, [samples]
const TIME_PTC = 7;

const CURR_GRIND_COUNT_FIELD_ID = 0;
const TOTAL_GRIND_COUNT_FIELD_ID = 1;

const VIBRATE_DUTY_CYCLE = 100;
const VIBRATE_LENGTH = 2000;

const DEFAULT_TARGET = 86;

var min_x = 0;
var max_x = 0;
var cnt_target = 0;

// Grind counter class
class GrindCounterProcess {

    var mX = [0];
    var mY = [0];
    var mZ = [0];
    var mFilter;
    var mGrindCount = 0;
    var mLogger;
	var mSession;
    var mSampleCount = 0;
    var mLastSampleCount = 0;
    // FIT Contributions variables
    hidden var mCurrentGrindCountField = null;
    hidden var mTotalGrindCountField = null;
    
    var reachedGoal;
    
    var progressBar;
    var progressStarted;
	var progressValue = 0.0;

    // Return min of two values
    hidden function min(a, b) {
        if(a < b) {
            return a;
        }
        else {
            return b;
        }
    }

    // Return max of two values
    hidden function max(a, b) {
        if(a > b) {
            return a;
        }
        else {
            return b;
        }
    }

    // Constructor
    function initialize() {
    	// read our settings
    	cnt_target = Prop.getValue("countTarget") == null? DEFAULT_TARGET : Prop.getValue("countTarget");
    	reachedGoal = false;
    	progressStarted = false;
        // initialize FIR filter
        var options = {:coefficients => [ -0.0278f, 0.9444f, -0.0278f ], :gain => 0.001f};
        try {
            mFilter = new Math.FirFilter(options);
            mLogger = new SensorLogging.SensorLogger({:enableAccelerometer => true});
        }
        catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    // Callback to receive accel data
    function accel_callback(sensorData) {
        mX = mFilter.apply(sensorData.accelerometerData.x);
        mY = sensorData.accelerometerData.y;
        mZ = sensorData.accelerometerData.z;
        onAccelData();
    }

    // Start grind counter
    function onStart() {
        // initialize accelerometer
        var options = {:period => 1, :sampleRate => 25, :enableAccelerometer => true};
        if (mSession == null) {
	        try {
//	            mSession = ActivityRecording.createSession({:name=>"GrindCounter", :sport=>ActivityRecording.SPORT_GENERIC, :sensorLogger => mLogger});
	            mSession = ActivityRecording.createSession({:name=>"GrindCounter", :sport=>ActivityRecording.SPORT_GENERIC});
	            Sensor.registerSensorDataListener(method(:accel_callback), options);
		    	// create 
		        mCurrentGrindCountField = mSession.createField("currGrindCount", CURR_GRIND_COUNT_FIELD_ID, FitContributor.DATA_TYPE_UINT16, { :nativeNum=>54, :mesgType=>FitContributor.MESG_TYPE_RECORD, :units=>"CT" });
		        mCurrentGrindCountField.setData(0);
        		mTotalGrindCountField = mSession.createField("totalGrindCount", TOTAL_GRIND_COUNT_FIELD_ID, FitContributor.DATA_TYPE_UINT16, { :nativeNum=>95, :mesgType=>FitContributor.MESG_TYPE_SESSION, :units=>"CT" });
		        mTotalGrindCountField.setData(0);
	            mSession.start();
	        }
	        catch(e) {
	            System.println(e.getErrorMessage());
	        }
        }
    }

    // Stop grind counter
    function onStop() {
    	Sensor.unregisterSensorDataListener();
    	mSession.stop();
    	if (!mSave) {
        	System.println("discarding session onStop");
        	mSession.discard();
    	} else {
        	System.println("saving session onStop");
        	mSession.save();        
    	}
	}

    // Return current grind count
    function getCount() {
        return mGrindCount;
    }

    // Return current grind count
    function getSamples() {
        return mLogger.getStats().sampleCount;
    }

    // Return current grind count
    function getPeriod() {
        return mLogger.getStats().samplePeriod;
    }

    // Return target grind count
    function getTarget() {
        return cnt_target;
    }

    // Return remaining grind count
    function getRemaining() {
    	if (mGrindCount < cnt_target ) {
    		return ( cnt_target - mGrindCount );
    	} else {
    		return 0;
    	}
    }
    
    function stopProgress() {
    }    

    // Process new accel data
    function onAccelData() {
        var cur_acc_x = 0;
        var cur_acc_y = 0;
        var cur_acc_z = 0;
        var time = 0;

        for(var i = 0; i < mX.size(); ++i) {
        
        	if ( mX[i] < -1.0 || mX[i] > 1 ) {
        		cur_acc_x = 0;
        	} else {
        		cur_acc_x = mX[i];
        		mSampleCount++;
            }
            cur_acc_y = mY[i];
            cur_acc_z = mZ[i];


            min_x = min(min_x, cur_acc_x);
            max_x = max(max_x, cur_acc_x);

            // System.println( Lang.format("mX[$1$] = $2$; min_x = $3$; cur_acc_x = $4$; dist = $5$; mSampleCount = $6$", [i, mX[i], min_x, cur_acc_x, (cur_acc_x-min_x), mSampleCount]) );
            
            // --- Grinding motion?
            if( ( cur_acc_x > HIGH_THR && (cur_acc_x-min_x) > DIST_THR ) && (mSampleCount-mLastSampleCount) > TIME_PTC ) {
            	mGrindCount++;
        		mCurrentGrindCountField.setData(mGrindCount);
				mTotalGrindCountField.setData(mGrindCount);
        		// System.println( Lang.format("mGrindCount = $1$", [mGrindCount]) );
            	// set min_x to high value
            	min_x = 1.0;
            	mLastSampleCount = mSampleCount;

	            if (!progressStarted && mGrindCount > 0) {
	            	progressStarted = true;
	            	progressBar = new WatchUi.ProgressBar("Grinding", null);
	            	mCurrentView = 2;
	            	WatchUi.pushView( progressBar, new GrindProgressDelegate(method(:stopProgress)), WatchUi.SLIDE_DOWN );
	            }
	            if (!reachedGoal && mGrindCount >= cnt_target) {
	            	reachedGoal = true;
	            	reachedGoalAlert();
	            	if ( mCurrentView == 2 ) {
	            		WatchUi.popView( WatchUi.SLIDE_UP );
	            	}
	            }
	            if (progressStarted && mGrindCount > 0) {
	            	progressValue = ( mGrindCount.toDouble() / cnt_target.toDouble() ) * 100.0;
//        			System.println(progressValue);
	            	progressBar.setProgress( progressValue );
	            	progressBar.setDisplayString( mGrindCount.toString() );
	            }
            }
            time++;
        }
        WatchUi.requestUpdate();
    }
    
    function reachedGoalAlert() {
    	if (Sy.getDeviceSettings().vibrateOn) {
    		Attn.vibrate([new Attn.VibeProfile(VIBRATE_DUTY_CYCLE, VIBRATE_LENGTH)]);
    	}
    	if (Attn has :playTone && Sy.getDeviceSettings().tonesOn) {
    		Attn.playTone(Attn.TONE_SUCCESS);
    	}
    }
}