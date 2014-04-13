//
//  UIImage+Extentions.m
//  SponsorPay
//
//  Created by Alex Núñez on 12/04/14.
//  Copyright (c) 2014 Alex Franco. All rights reserved.
//

#import "UIImage+Extentions.h"

@implementation UIImage (Extentions)

- (UIImage *)imageWithRoundedCornersRadius:(float)radius
{
	// Begin a new image that will be the new image with the rounded corners
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
	
    // Add a clip before drawing anything, in the shape of an rounded rect
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
	
    // Draw your image
    [self drawInRect:rect];
	
    // Get the image, here setting the UIImageView image
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
	
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();

    return roundedImage;
}

@end
