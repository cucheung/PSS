//  OpenCVWrapper.h

//  Description: This header file contains all of our functions for OpenCV
// openCVVersionString - used to display OpenCV Version
// isImageBlurry - passs a UIImage into the function to produce a "blur" value

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  10/25/2018 - Created

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
+ (NSString *)openCVVersionString;
- (double) isImageBlurry:(UIImage *) image;

@end




NS_ASSUME_NONNULL_END
