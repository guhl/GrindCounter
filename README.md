# Grind Counter

## Description
Counts the grinding motions when using a manual coffee grinder.

Tested with watch on the left wrist with the grinder in the left hand and the crank lever in the right.

In principle it counts circular movements in the X-Y plane but uses only the X-accelerator data to detect the motion.
In testing the frequency was about on circular motion per second.

Changes in Version 1.1.0:
- Settings for Count Target - press Menu-Button and select Settings or press Select-Button and select Settings
- View changes to progress indicator when grinding starts - press Back-Button if you want to see the Main-View
- Vibrates and plays success tone when target is reached

## Usage
Start the App and start grinding -> the counter will increase.
Press Menu or Select and select Settings to set the Target

### Button Back
On Progress View -> Go back to Main-View
On Main-View -> Exit App and save activity data

### Start/Stop Button
Shows a menu with the following options:
- Exit: exit immediately and discard all information
- Save & Exit: store the activity data (including the counts over time and in total but it does not store the pure acceleration data)
- Resume: go back to counting

## Permissions

This App requires access to:

- FIT files (activity recordings)
- Record additional information into activity files
- Sensor data (i.e., ANT+, heart rate, compass)
- Heart rate, barometer, temperature, and altitude history
- Record high resolution sensor data to a FIT file (may dramatically increase activity file size)


