//
//  Helpers.m
//  Collidor
//
//  Created by Guarana Technologies on 2014-04-17.
//  Copyright (c) 2014 Guarana Technologies. All rights reserved.
//

#import "Helpers.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "NSString+Utilities.h"
#import "JoystickMemoryAppDelegate.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "Reachability.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import "NYXImagesKit.h"
#import "UIAlertView+Blocks.h"
#import "SVProgressHUD.h"
#import "float.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "UIButton+Position.h"

@implementation Helpers

//singleton
+ (id)instance {
    static Helpers *myInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myInstance = [[self alloc] init];
    });
    return myInstance;
}

-(id)init {
    if (self = [super init]) {
    }
    return self;
}

/*-(void)dealloc {

    [super dealloc];
}*/

-(void) setupGoogleAnalyticsForView:(NSString*)viewName {
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    //can be null
    if(!tracker)
        return;
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:viewName];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) sendGoogleAnalyticsEventWithView:(NSString*)viewName andEvent:(NSString*)eventName {
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    //can be null
    if(!tracker)
        return;

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:viewName    // Event category (required)
                                                          action:eventName  // Event action (required)
                                                           label:@""         // Event label
                                                           value:nil] build]];    // Event value
}

-(void) sendGoogleAnalyticsEventWithCategory:(NSString*)category andAction:(NSString*)action andLabel:(NSString*)label  {
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    //can be null
    if(!tracker)
        return;

    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category    // Event category (required)
                                                          action:action  // Event action (required)
                                                           label:label        // Event label
                                                           value:nil] build]];    // Event value
}


-(void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message {
        UIAlertView *alert = [[UIAlertView alloc]
                                     initWithTitle:title
                                     message:message
                                     delegate:self
                                     cancelButtonTitle:LOCALIZED(@"kStringOK")
                                     otherButtonTitles:nil];
        [alert show];
}


-(void) setupHud {

    //old colors
    //[[SVProgressHUD appearance] setHudBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    //[[SVProgressHUD appearance] setHudForegroundColor:[UIColor whiteColor]];
}

-(void) dismissHud {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

-(void) showErrorHud:(NSString*)error {

    NSLog(@"showErrorHud: %@", error);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showErrorWithStatus:error];
        //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    });

    
    //after delay
    float secs = kHudWaitDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissHud];
    });

}

/*-(void) showMessageHudDark:(NSString*)message {
    
    NSLog(@"showMessageHudDark: %@", message);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeClear];
        //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    });
    
}*/

-(void) showMessageHud:(NSString*)message {
        
    [self showMessageHud:message blockUI:YES];
    
}

-(void) showMessageHud:(NSString*)message blockUI:(BOOL)blockUI {
    
    NSLog(@"showMessageHud: %@", message);
/*
    enum {
    SVProgressHUDMaskTypeNone = 1, // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear, // don't allow
    SVProgressHUDMaskTypeBlack, // don't allow and dim the UI in the back of the HUD
    SVProgressHUDMaskTypeGradient // don't allow and dim the UI with a a-la-alert-view bg gradient
};
*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if(blockUI)
            [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeClear];
        else
            [SVProgressHUD showWithStatus:message ];
    });
    
}


-(void) showSuccessHud:(NSString*)message {

    NSLog(@"showSuccessHud: %@", message);

    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:message ];
        //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    });
    
    //after delay
    float secs = kHudWaitDuration;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self dismissHud];
    });

}

-(BOOL) checkOnline {
    //force
    //return YES;
    
    BOOL tempOnline = YES;
    
    if(![self hasConnection])
        tempOnline = NO;
    
    return tempOnline;
}

-(BOOL) hasConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];    
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus == NotReachable) 
    {
        return false;
    }
    else
    {
        return true;
    }
}

-(void) textFieldOffset:(UITextField*)textField withWidth:(int)paddingWidth{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingWidth, textField.frame.size.height)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

-(void) textFieldChangePlaceholderColor:(UITextField*)textField withColor:(UIColor*)newColor {
    if ([textField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: newColor}];
    } else {
        NSLog(@"Cannot set placeholder text's color, because deployment target is earlier than iOS 6.0");
    }
}

-(BOOL) isIpad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}

-(BOOL) isIphone
{
    return ![self isIpad];
}

- (BOOL) isRetina
{
   if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) 
    {
      // Retina display
      return YES;
    }
    else 
    {
        return NO;
    }
}

-(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                               color.CGColor);
    CGContextFillRect(context, rect);

    img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

/*-(CGSize)parallaxSize:(CGSize)size
{
    float mult = (kParallaxWidth/kNoParallaxWidth);

    CGSize newSize;
    newSize.width = round(size.width * mult);
    newSize.height = round(size.height * mult);
    
    return newSize;
}*/

/*-(UIImage*)imageByScalingForParallax:(UIImage*)sourceImage
{
    //disabled
    return sourceImage;
    
    if(!sourceImage)
        return nil;
    
    UIImage *output = sourceImage;
    CGSize targetSize = sourceImage.size;
    //float targetWidth = 372.0f;
    //float targetWidth = 340.0f;
    float mult = kParallaxWidth / sourceImage.size.width;

    targetSize.width = round(targetSize.width * mult);
    targetSize.height = round(targetSize.height * mult);

    output = [output scaleToSize:targetSize usingMode:NYXResizeModeAspectFill];
    //output = [output cropToSize:targetSize usingMode:NYXCropModeCenter];
    
    return output;

}*/

-(UIImage*)imageByScalingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImage
{
    if(!sourceImage)
        return nil;
    
    UIImage *output = sourceImage;
    
    output = [output scaleToSize:targetSize usingMode:NYXResizeModeAspectFill];
    
    return output;
}

-(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage*)sourceImage withCenter:(BOOL)center
{
    //return sourceImage;
    
    if(!sourceImage)
        return nil;

    UIImage *output = sourceImage;

    output = [output scaleToSize:targetSize usingMode:NYXResizeModeAspectFill];

    //memory leak?
    /*if(center)
        output = [output cropToSize:targetSize usingMode:NYXCropModeCenter];
    else
        output = [output cropToSize:targetSize usingMode:NYXCropModeTopLeft];*/

    return output;

}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return img;
}

-(UIImage*)imageWithImage: (UIImage*)sourceImage scaleToWidth:(float)inWidth resizeIfSmaller:(BOOL)resize
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = inWidth / oldWidth;
    
    //dont resize if smaller
    if(!resize && (oldWidth < inWidth) )
        return sourceImage;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL) isDebug
{
#ifdef DEBUG
    return YES;
#else
    return NO;
#endif
}

-(BOOL) isSimulator
{

#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif

}

- (NSString*)getVersionString
{
    NSString *debugString = [NSString stringWithFormat:@"%@", [self isDebug]?@" (debug)":@""]; //add debug string
    NSString *output = [NSString stringWithFormat:@"%@%@",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], debugString];
	
	return output;
}
- (NSString*)getVersionString2
{
    NSString *debugString = [NSString stringWithFormat:@"%@", [self isDebug]?@" (debug)":@""]; //add debug string
	NSString *output = [NSString stringWithFormat:@"%@ (%@)%@",
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ,
						[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
						debugString];
    
	return output;
}

- (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (Global)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (Global)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (GSM)";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina (GSM)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

//https://gist.github.com/1323251
- (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}


//to test parallax
-(BOOL) isIpadBig {
    
    if([[self platform] isEqualToString:@"iPad1,1"] ||
        [[self platform] isEqualToString:@"iPad2,1"] ||
        [[self platform] isEqualToString:@"iPad2,2"] ||
        [[self platform] isEqualToString:@"iPad2,3"] ||
        [[self platform] isEqualToString:@"iPad2,4"] ||
        [[self platform] isEqualToString:@"iPad3,1"] ||
        [[self platform] isEqualToString:@"iPad3,2"] ||
        [[self platform] isEqualToString:@"iPad3,3"] ||
        [[self platform] isEqualToString:@"iPad3,4"] ||
        [[self platform] isEqualToString:@"iPad3,5"] ||
        [[self platform] isEqualToString:@"iPad3,6"] ||
        [[self platform] isEqualToString:@"iPad4,1"] ||
        [[self platform] isEqualToString:@"iPad4,2"] )
        return YES;
    else
        return NO;
}
-(BOOL) isIpadMini {
    
    if([[self platform] isEqualToString:@"iPad2,5"] ||
        [[self platform] isEqualToString:@"iPad2,6"] ||
        [[self platform] isEqualToString:@"iPad2,7"] ||
        [[self platform] isEqualToString:@"iPad4,4"] ||
        [[self platform] isEqualToString:@"iPad4,5"] )
        return YES;
    else
        return NO;
}




-(BOOL) canParallax {
    //force
    return NO;
    
    if([self isIphone4])
        return NO;
    else if([self isSimulator])
        return NO;
    
    return YES;
}

//to test parallax
-(BOOL) isIphone4 {
    if([[self platformString] isEqualToString:@"iPhone 4"])
        return YES;
    else if([[self platformString] isEqualToString:@"Verizon iPhone 4"])
        return YES;
    else
        return NO;
}

-(BOOL) isIphone5Size
{
   //if ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
    if([self doublesEqual:(double)[[UIScreen mainScreen] bounds].size.height second:(double)568])
    {
      // iphone 5
      return YES;
    }
    else 
    {
        return NO;
    }
}

-(void)listFonts {

    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
            
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

-(UIImageView*)getLogo {
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo.png"]];
    return logo;
}

-(UIButton*)getMenuButton {

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,0,26,16+10)]; //10px taller, for alignment
    
    [button setImage:[UIImage imageNamed:@"nav_menu.png"] forState:UIControlStateNormal];

    button.contentMode = UIViewContentModeScaleAspectFit;
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    
    return button;
}


-(float) getLatitude {
    float latitude = 0.0f; //kAppDelegate.locationManager.location.coordinate.latitude;
    return latitude;
}

-(float) getLongitude {
    float longitude = 0.0f; //kAppDelegate.locationManager.location.coordinate.longitude;
    return longitude;
}

-(double)randomFloatBetween:(double)smallNumber andBig:(double)bigNumber {
    double diff = bigNumber - smallNumber;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

-(BOOL)doublesEqual:(double)first second:(double)second {
    BOOL equal = NO;
    
    if ( fabs( first - second) < DBL_EPSILON2 )
        equal = YES;
    
    return equal;
}

-(void) startUpdatingLocation {
     //[kAppDelegate startUpdatingLocation];
}

//corners
-(NSArray *)getBoundingBox:(MKMapRect)mRect{
    CLLocationCoordinate2D bottomLeft = [self getSWCoordinate:mRect];
    CLLocationCoordinate2D topRight = [self getNECoordinate:mRect];
    return @[[NSNumber numberWithDouble:bottomLeft.latitude ],
             [NSNumber numberWithDouble:bottomLeft.longitude],
             [NSNumber numberWithDouble:topRight.latitude],
             [NSNumber numberWithDouble:topRight.longitude]];
}

-(CLLocationCoordinate2D)getCoordinateFromMapRectanglePoint:(double)x y:(double)y{
    MKMapPoint swMapPoint = MKMapPointMake(x, y);
    return MKCoordinateForMapPoint(swMapPoint);
}

-(CLLocationCoordinate2D)getNECoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:mRect.origin.y];
}
-(CLLocationCoordinate2D)getNWCoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMinX(mRect) y:mRect.origin.y];
}
-(CLLocationCoordinate2D)getSECoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:MKMapRectGetMaxX(mRect) y:MKMapRectGetMaxY(mRect)];
}
-(CLLocationCoordinate2D)getSWCoordinate:(MKMapRect)mRect{
    return [self getCoordinateFromMapRectanglePoint:mRect.origin.x y:MKMapRectGetMaxY(mRect)];
}

//size the mapView region to fit its annotations
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapViewParam animated:(BOOL)animated
{
    NSMutableArray *zoomAnnotations = [[NSMutableArray alloc] initWithArray:[mapViewParam annotations]];
    
    if(!zoomAnnotations || [zoomAnnotations count] == 0)
        return;
    
    //remove current
    id userLocation = [mapViewParam userLocation];
    if (userLocation != nil ) {
        [zoomAnnotations removeObject:userLocation]; // avoid removing user location off the map
    }
    
    //check again
    if(!zoomAnnotations || [zoomAnnotations count] == 0)
        return;

    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;

    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;

    for(MKPointAnnotation *annotation in zoomAnnotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);

        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }

    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4; // Add a little extra space on the sides

    region = [mapViewParam regionThatFits:region];
    [mapViewParam setRegion:region animated:animated];
}

-(NSString*) cleanupErrorString:(NSString*)string {
    
    if(!string)
        return nil;
    
    NSString *newString = string;
    
    NSString *remove = @"<strong>ERROR</strong>: ";
    
    newString = [newString stringByReplacingOccurrencesOfString:remove withString:@""];
    
    return newString;
}


-(NSString*) unixTimestamp:(NSDate*)date {

    //if(date == nil)
    //    return @"";
    
    NSDate *newDate = date;
    
    if(newDate == nil)
        newDate = [NSDate date];
    
    NSString * output = [NSString stringWithFormat:@"%ld", (long)[newDate timeIntervalSince1970]];
    //NSLog(@”Time Stamp Value == %@”, timeStampValue);
    
    return output;
}


-(NSString*) randomString{

    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

-(NSString*) addRandomParameterToUrl:(NSString*)url {
    NSString *output = url;
    output = [output stringByAppendingString:@"?random="];
    //output = [output stringByAppendingString:[self randomString]];
    output = [output stringByAppendingString:[self unixTimestamp:nil]];
    return output;
}

-(NSString*) addTimestampParameterToUrl:(NSString*)url withDate:(NSDate*)date {
    NSString *output = url;
    output = [output stringByAppendingString:@"&timestamp="];
    output = [output stringByAppendingString:[self unixTimestamp:date]];
    return output;
}

-(NSString*) stripHTML:(NSString*)string {
    
    if (!string || [string isEqual:[NSNull null]])
        return nil;
    
    NSString *newString = string;
    
    NSString *remove = @"<p>";
    newString = [newString stringByReplacingOccurrencesOfString:remove withString:@""];
    
    remove = @"</p>";
    newString = [newString stringByReplacingOccurrencesOfString:remove withString:@""];
    
    remove = @"\n";
    newString = [newString stringByReplacingOccurrencesOfString:remove withString:@""];

    remove = @"\r";
    newString = [newString stringByReplacingOccurrencesOfString:remove withString:@""];
    
    
    newString = [self stringByDecodingXMLEntities:newString];
    
    return newString;
}

-(NSString *)stringByDecodingXMLEntities:(NSString*)string {
    NSUInteger myLength = [string length];
    NSUInteger ampIndex = [string rangeOfString:@"&" options:NSLiteralSearch].location;

    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return string;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];

    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:string];

    [scanner setCharactersToBeSkipped:nil];

    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];

    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";

            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }

            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];

                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";

                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];


                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];

                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);

            }

        }
        else {
            NSString *amp;

            [scanner scanString:@"&" intoString:&amp];  //an isolated & symbol
            [result appendString:amp];

            /*
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
            NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
             */
        }

    }
    while (![scanner isAtEnd]);

finish:
    return result;
}


-(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}


- (void) emptyFileCache {
    
    //disabled
    return;
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                          NSUserDomainMask,
                                                          YES) lastObject];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:path error:&error];
    for (NSString *file in cacheFiles) {
        error = nil;
        [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];

        if(error) {
            NSLog(@"emptyFileCache error");
        }
    }

}

- (void)saveImage:(UIImage *)image withName:(NSString *)name {
    //NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* path = NSTemporaryDirectory();

    //CGSize size = image.size;
    NSString *newName = name;
    
    //retina
    if([self isRetina]) {
        newName = [newName stringByAppendingString:@"@2x"];
    }
    
    //extension
    newName = [newName stringByAppendingString:@".png"];
    
    //NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSData *data = UIImagePNGRepresentation(image);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fullPath = [path stringByAppendingPathComponent:newName];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
}

- (UIImage *)loadImage:(NSString *)name {
    NSString *newName = name;
    
    //retina
    if([self isRetina]) {
        newName = [newName stringByAppendingString:@"@2x"];
    }
    
    //extension
    newName = [newName stringByAppendingString:@".png"];

    //NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString* path = NSTemporaryDirectory();


    NSString *fullPath = [path stringByAppendingPathComponent:newName];
    UIImage *img = [UIImage imageWithContentsOfFile:fullPath];
    
    /*CGSize size;
    if(img) {
        size = img.size;
    }*/
    
    return img;
}

- (CGRect) getScreenRect;
{
    CGRect tempRect1 = [[UIScreen mainScreen] bounds];
    //CGRect tempRect2 = [[UIScreen mainScreen] applicationFrame];
    CGRect tempRect = CGRectMake(0,0,tempRect1.size.width, tempRect1.size.height);
    
    return tempRect;
}

-(BOOL) validateURL:(NSString*)url {
    
    if(url == nil || [url isEqual:[NSNull null]] || url.length == 0) {
        NSLog(@"Invalid URL: %@", url);
        return NO;
    }
    
    /*NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx]; 
    if(![urlTest evaluateWithObject:url]) {
        NSLog(@"Invalid URL: %@", url);
        return NO;
    }*/

    return YES;
    
}

-(BOOL) validateEmail:(NSString*)email {
    //Email: Yes standard checking

    if(email == nil || email.length == 0)
        return NO;
    
    //no spaces
    if ([email contains:@" "])
        return NO;
    
    //no ampersand
    if ([email contains:@"&"])
        return NO;
    
    //no %
    if ([email contains:@"%%"])
        return NO;
    
    //http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios/3638271#3638271
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if(![emailTest evaluateWithObject:email])
        return NO;
    
    return YES;
}

-(BOOL) validateFullName:(NSString*)username {

    if(username == nil)
        return NO;
    
     if(username.length < 1 || username.length > 100)
        return NO;

    //no ampersand
    if ([username contains:@"&"])
        return NO;
    
    //no @
    if ([username contains:@"@"])
        return NO;
    
    //no %
    if ([username contains:@"%%"])
        return NO;
    
    return YES;
}

-(BOOL) validateUsername:(NSString*)username {

    //Username: No spaces, numbers are allowed
    
    if(username == nil)
        return NO;
    
     if(username.length < 1 || username.length > 20)
        return NO;

    //no spaces
    if ([username contains:@" "])
        return NO;
    
    //no ampersand
    if ([username contains:@"&"])
        return NO;
    
    //no @
    if ([username contains:@"@"])
        return NO;

    //no %
    if ([username contains:@"%%"])
        return NO;
    
    return YES;
}

-(BOOL) validatePassword:(NSString*)password showError:(BOOL)showError {

    //disabled
    //return YES;
    
    if(password == nil) {
        if(showError)
            [kHelpers showAlertWithTitle:LOCALIZED(@"kStringError") andMessage:LOCALIZED(@"kStringErrorValidatePasswordGeneric")];

        return NO;
    }
    
    if(password.length < 6 || password.length > 100) {
        if(showError)
            [kHelpers showAlertWithTitle:LOCALIZED(@"kStringError") andMessage:LOCALIZED(@"kStringErrorValidatePasswordShort")];
        
        return NO;
    }
    
    //no spaces
    if ([password contains:@" "]) {
        if(showError)
            [kHelpers showAlertWithTitle:LOCALIZED(@"kStringError") andMessage:LOCALIZED(@"kStringErrorValidatePasswordInvalidCharacters")];

        return NO;
    }
    
    //no ampersand
    if ([password contains:@"&"]) {
        if(showError)
            [kHelpers showAlertWithTitle:LOCALIZED(@"kStringError") andMessage:LOCALIZED(@"kStringErrorValidatePasswordInvalidCharacters")];

        return NO;
    }
    
    //no %
    if ([password contains:@"%%"]) {
        if(showError)
            [kHelpers showAlertWithTitle:LOCALIZED(@"kStringError") andMessage:LOCALIZED(@"kStringErrorValidatePasswordInvalidCharacters")];

        return NO;
    }
    
    return YES;
}

- (BOOL)isLocationAvailable
{
    //system level
    if(![CLLocationManager locationServicesEnabled])
        return NO;
    
    //app level
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
       return NO;
    
    //still 0,0
    //if( [kHelpers doublesEqual:[kHelpers getLatitude] second:0.0f] || [kHelpers doublesEqual:[kHelpers getLongitude] second:0.0f])
    //    return NO;

    return YES;
}

@end




