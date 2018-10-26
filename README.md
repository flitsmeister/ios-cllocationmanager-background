# ios-cllocationmanager-background
Sample code to demonstrate iOS 12 CLLocationManager background issues and help to understand and explain the problem with Apple.

Issue on stackoverflow: https://stackoverflow.com/questions/53005174/ios-12-terminates-apps-in-the-background-for-no-reason

### DESCRIPTION OF PROBLEM
Starting from iOS 12 the CLLocationManager doesn't run endless anymore in the background. The app get's terminated without a crashlog at random times. This was working fine before iOS 12.

This demo app just launches an CLLocationManager and keep this running in the background. While running on the background we keep track of it by logging it. The problem is that the app get terminated by iOS. The demo app is created to demonstrate this problem.

**Steps to reproduce**

1. Run the app on the device 
2. Grand access to locationmanager
3. Put the app to the background
4. Wait for 1-48hours 

**Result:**

5. The app is terminated

App is terminated without any reason after random time.

**Expected result:**

5. The app is still running.

**How it should work**

*This is confirmed by an Apple engineer:*

Once the CLLocationManager updates are started in the foreground and you did all the work to have it running in the background, the location updates should run endless in the background until:


- app is force quit
- device is rebooted
- app stops location updates
- app releases the CLLocationManager object
- app crashes
- iOS terminates the app due to memory shortage,
- the locationManager object is released, overreleased, or overwritten. You should make sure that your view controller is not being instantiated, which then resets the locationController class. If that happens when the app is in the background, you will restart updates, which will cause the app to be eventually suspended. You should make sure the locationController is a singleton.
- app is crashing. Check to see if there are crash logs on the device you are testing
- iOS is terminating the app due to memory shortage. In this case, you will find JetsamEvent logs on the device that shows your app being terminated. You can check the timestamps and locate the one that is around the time your app stopped working.


## Carthage
We use Carthage to get CocoaLumberJack which is used by the demo app to do file based logging.

## Other help

Some help with memory and Jetsam events:
https://www.quora.com/What-is-the-iOS-jetsam-and-how-does-it-exactly-work#nsgHFq
