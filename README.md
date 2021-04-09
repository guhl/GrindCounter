# Grind Counter

## Description
Counts the grinding motions when using a manual coffee grinder.

Tested with watch on the left wrist with the grinder in the left hand and the crank lever in the right.

In principle it counts circular movements in the X-Y plane but uses only the X-accelerator data to detect the motion.
In testing the frequency was about on circular motion per second.

## Usage
Start the App and start grinding -> the counter will increase.

### Button Back
The App will exit immidiately and discard all information

### Start/Stop Button
Shows a menu with the following options:
- Exit: exit immidiately and discard all information
- Save & Exit: store the activity data (including the counts over time and in total but it does not store the pure acceleration data)
- Resume: go back to counting

## Permissions

This app requires access to:

- FIT files (activity recordings)
- Record additional information into activity files
- Sensor data (i.e., ANT+, heart rate, compass)
- Heart rate, barometer, temperature, and altitude history
- Record high resolution sensor data to a FIT file (may dramatically increase activity file size)


