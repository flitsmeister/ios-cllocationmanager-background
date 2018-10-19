# ios-cllocationmanager-background
Sample code to demonstrate iOS 12 CLLocationManager background issues and help to understand and explain the problem with Apple.

## Purpose demo app
The demo app just launches an CLLocationManager and keep this running in the background. While running on the background we keep track of it by logging it. The problem is that the app get terminated by iOS. The demo app is created to demonstrate this problem.

### DESCRIPTION OF PROBLEM
Starting from iOS 12 the CLLocationManager doesn't run endless anymore in the background. The app get's suspended without a crashlog at random times. This was working fine before iOS 12.

Result:
- app send to suspended mode without any reason after random time.

Expected: If an app uses background mode location updates it should run in the background until:
A- app crashes
B- app stops the cllocationmanager
C- iOS kills the app due memory
D- it keeps running


### STEPS TO REPRODUCE
We've created a sample app to demonstrate the problem. Code available on Github:
https://github.com/flitsmeister/ios-cllocationmanager-background

1. Run the app on the device 
2. Grand access to locationmanager
3. Put the app to the background
4. Wait for 1-48hours 
5. The app is suspended

Expected result:
5. The app is still running.

## Carthage
We use Carthage to get CocoaLumberJack which is used by the demo app to do file based logging.

## Feedback from apple

Location updates will run indefinitely in the background, if, and only if, startUpdatingLocation() is called while the app is in the foreground (assuming all necessary location manager settings are correct.

Once the updates are started in the foreground, like you have stated, the updates will run in the background until:
- app is force quit
- device is rebooted
- app stops location updates
- app releases the CLLocationManager object
- app crashes
- iOS terminates the app due to memory shortage,

Assuming you are not force quitting the app or rebooting the phone. Assuming the sample project is reproducing this error - and I don’t see you stopping the updates; what remains is:
- the locationManager object is released, overreleased, or overwritten. You should make sure that your view controller is not being instantiated, which then resets the locationController class. If that happens when the app is in the background, you will restart updates, which will cause the app to be eventually suspended. You should make sure the locationController is a singleton.
- app is crashing. Check to see if there are crash logs on the device you are testing
- iOS is terminating the app due to memory shortage. In this case, you will find JetsamEvent logs on the device that shows your app being terminated. You can check the timestamps and locate the one that is around the time your app stopped working.


## Other help

Report of what looks like the same issue:
https://stackoverflow.com/questions/52533884/ios12-background-location-service-stopping

Some help with memory and Jetsam events:
https://www.quora.com/What-is-the-iOS-jetsam-and-how-does-it-exactly-work#nsgHFq
