//
//  Config.h
//

//cleanup
//find . -type d -name '.svn' -print0 | xargs -0 rm -rdf
//find . -type d -name 'Collidor.xccheckout' -print0 | xargs -0 rm -rdf
//find . -type d -name 'chris.xcuserdatad' -print0 | xargs -0 rm -rdf
//find . -type d -name '.git' -print0 | xargs -0 rm -rdf
//find . -name ".DS_Store" -depth -exec rm {} \;

//constants

#define kMusicVolumeMultiplier 0.6f
#define kMusicEnabled YES
#define kHudWaitDuration 1.0f
#define kJoystickRadius 30
#define kJoystickAngleOffset 44 //almost 90
#define kDefaultCoins 8
#define kIAPNumCoins 8
#define kPatternCountStart 3
#define kStreakIncPatternCount 5
#define kTimerStart 15 //99
#define kTimerMax 99
#define kTimerWin 5
#define kPauseFadeDuration 0.3f
#define kFadeDuration 0.3f
#define kFadeDurationLong 1.0f
#define kFadeColor RGBA(0,0,0, 1.0f) // RGBA(0,0,0, 0.9f) //RGBA(0,255,0, 1.0f)
#define kAlertStyle SIAlertViewTransitionStyleBounce //SIAlertViewTransitionStyleDropDown
#define kGoogleAnalyticsTrackingID @"???"
#define kLoadingFakeTime 4.0f

