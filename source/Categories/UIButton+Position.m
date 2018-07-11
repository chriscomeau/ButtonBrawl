//
//  UIButton+Position.m
//  Outpost
//
//  Created by Guarana Technologies on 2014-01-30.
//  Copyright (c) 2014 Guarana Technologies. All rights reserved.
//

#import "UIButton+Position.h"
            
@implementation UIButton(ImageTitleCentering)

-(void) centerButtonAndImageWithSpacing:(CGFloat)spacing {
    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, spacing);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);
}

-(void) imageSpacing:(CGFloat)imageSpacing andTextSpacing:(CGFloat)textSpacing {
    self.imageEdgeInsets = UIEdgeInsetsMake(0, imageSpacing, 0, 5);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, imageSpacing + textSpacing, 0, 5);
}

@end