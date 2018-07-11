//
//  NSString+Utilities.h
//  Collidor
//
//  Created by Guarana Technologies on 2014-01-30.
//  Copyright (c) 2014 Guarana Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMNSString+HTML.h"

@interface NSString (Utilities)
- (BOOL) isNumeric;
- (BOOL) contains:(NSString*)toCheck;
- (BOOL) isEqualToStringInsensitive:(NSString*)toCheck;
- (NSString *) stringFromTruncateTail:(int)atLength;
- (NSString *) stringFromRemoveAccents;
- (NSString *)stringCutByWordsToMaxLength:(int)lenght;
- (NSString *) stringFromCleanupHTML;

@end