//
//  Helpers.h
//  Collidor
//
//  Created by Guarana Technologies on 2014-04-17.
//  Copyright (c) 2014 Guarana Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FacebookSDK/FacebookSDK.h>
//#import <MessageUI/MessageUI.h>
//#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>
//#import "MKMapView+ZoomLevel.h"

//singleton
#define kHelpers [Helpers instance]

//System Versioning Preprocessor Macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kIsIOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")
#define kIsIOS7_1 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.1")

#define kAppDelegate ((JoystickMemoryAppDelegate *)[[UIApplication sharedApplication] delegate])

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

#define kBackgroundQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//#define kBlockAfterDelayCurrent(dly, block)     dispatch_after(dispatch_time(DISPATCH_TIME_NOW,dly*100000),dispatch_get_current_queue(), ^{ block })

//math
#define DBL_EPSILON2 0.00000001f

//color
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

//strings
#define LOCALIZED(x) NSLocalizedString((x), nil)

//log
#define LogRect(RECT) NSLog(@"%s: (%0.0f, %0.0f) %0.0f x %0.0f", #RECT, RECT.origin.x, RECT.origin.y, RECT.size.width, RECT.size.height)

//rect
#define CGRectSetPos( r, x, y ) CGRectMake( x, y, r.size.width, r.size.height )


//cleanup
//find . -type d -name '.svn' -print0 | xargs -0 rm -rdf
//find . -type d -name '.git' -print0 | xargs -0 rm -rdf
//find . -name ".DS_Store" -depth -exec rm {} \;

@interface Helpers : NSObject

+(id)instance;

//UI
-(void) textFieldOffset:(UITextField*)textField withWidth:(int)paddingWidth;
-(void) textFieldChangePlaceholderColor:(UITextField*)textField withColor:(UIColor*)newColor;
-(BOOL) isIphone5Size;
-(BOOL) isIphone4;
-(BOOL) isSimulator;
-(BOOL) isDebug;
-(BOOL) canParallax;
- (NSString *) platform;
- (NSString *) platformString;
- (NSString*) getVersionString;
- (NSString*) getVersionString2;
-(void)listFonts;
-(UIButton*)getLogo;

//analytics
-(void) setupGoogleAnalyticsForView:(NSString*)viewName;
-(void) sendGoogleAnalyticsEventWithView:(NSString*)viewName andEvent:(NSString*)eventName;
-(void) sendGoogleAnalyticsEventWithCategory:(NSString*)category andAction:(NSString*)action andLabel:(NSString*)label;

//alerts
-(void) showAlertWithTitle:(NSString*)title andMessage:(NSString*)message;
-(void) showErrorHud:(NSString*)error;
-(void) setupHud;
-(void) dismissHud;
-(void) showSuccessHud:(NSString*)message;
-(void) showMessageHud:(NSString*)message;
-(void) showMessageHud:(NSString*)message blockUI:(BOOL)blockUI;

//validate
-(BOOL) validateURL:(NSString*)url;
-(BOOL) validateEmail:(NSString*)email;
-(BOOL) validateUsername:(NSString*)username;
-(BOOL) validatePassword:(NSString*)password showError:(BOOL)showError;
-(BOOL) validateFullName:(NSString*)username;

//system
-(BOOL) isIpad;
-(BOOL) isIphone;
-(BOOL) isIpadBig;
-(BOOL) isIpadMini;
-(BOOL) checkOnline;
- (BOOL)isRetina;
- (CGRect) getScreenRect;
- (BOOL)isLocationAvailable;

//files
-(void)saveImage:(UIImage *)image withName:(NSString *)name;
-(UIImage *)loadImage:(NSString *)name;
- (void) emptyFileCache;

//image
-(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
-(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImage withCenter:(BOOL)center;
-(UIImage*)imageByScalingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImage;
//-(UIImage*)imageByScalingForParallax:(UIImage*)sourceImage;
//-(CGSize)parallaxSize:(CGSize)size;
-(UIImage*)imageWithImage: (UIImage*)sourceImage scaleToWidth:(float)inWidth resizeIfSmaller:(BOOL)resize;
-(UIImage *) imageWithView:(UIView *)view;

//location
-(float) getLatitude;
-(float) getLongitude;
-(void) startUpdatingLocation;
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapViewParam animated:(BOOL)animated;

//location, corners
-(NSArray *)getBoundingBox:(MKMapRect)mRect;
-(CLLocationCoordinate2D)getCoordinateFromMapRectanglePoint:(double)x y:(double)y;
-(CLLocationCoordinate2D)getNECoordinate:(MKMapRect)mRect;
-(CLLocationCoordinate2D)getNWCoordinate:(MKMapRect)mRect;
-(CLLocationCoordinate2D)getSECoordinate:(MKMapRect)mRect;
-(CLLocationCoordinate2D)getSWCoordinate:(MKMapRect)mRect;

//strings
-(NSString*) cleanupErrorString:(NSString*)string;
-(NSString*) stripHTML:(NSString*)string;
-(NSString*) randomString;
-(NSString*) unixTimestamp:(NSDate*)date;
-(NSString*) addRandomParameterToUrl:(NSString*)url;
-(NSString*) addTimestampParameterToUrl:(NSString*)url withDate:(NSDate*)date;

//math
-(double)randomFloatBetween:(double)smallNumber andBig:(double)bigNumber;
-(BOOL)doublesEqual:(double)first second:(double)second;

//date
-(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end
