//  OpenCVWrapper.mm
// Source Used (isImageBlurry,convertUIImageToCVMat): https://stackoverflow.com/a/40589477/10498067


//  Description: This file contains all of our function implementations for OpenCV
// openCVVersionString - used to display OpenCV Version
// isImageBlurry - passs a UIImage into the function to produce a "blur" value

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  10/25/2018 - Created
//  11/21/2018 - Added Comments to code

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>

// Display OpenCV version in Console
// Input: NULL
// Output: OpenCV Version on Console Log
@implementation OpenCVWrapper
+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

// Convert UIImage (Swift) to Mat (OpenCV Image Matrix)
// Input: UIImage
// Output: Mat (OpenCV image matrix)
- (cv::Mat)convertUIImageToCVMat:(UIImage *)image {
    // Determine colour space, width,and height of input UIImage
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    // Declare OpenCV Matrix object
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    // Convert UIImage to Mat
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

// Determine the amount of "blur" in image
// Input: UIImage
// Output: Pixel variance of image
- (double) isImageBlurry:(UIImage *) image {
    // converting UIImage to OpenCV format - Mat
    cv::Mat matImage = [self convertUIImageToCVMat:image];
    cv::Mat matImageGrey;
    // converting image's color space (RGB) to grayscale
    cv::cvtColor(matImage, matImageGrey, cv::COLOR_BGR2GRAY);
    
    cv::Mat dst2 = [self convertUIImageToCVMat:image];
    cv::Mat laplacianImage;
    //dst2.convertTo(laplacianImage, CV_8UC1);
    
    // applying Laplacian operator to the image
    //CMPT275
    Laplacian(matImageGrey, laplacianImage, CV_64F);
    cv::Scalar mean, stddev; //0:1st channel, 1:2nd channel and 2:3rd channel
    meanStdDev(laplacianImage, mean, stddev, cv::Mat());
    // Calculate Variance of greyscale pixels
    double variance = stddev.val[0] * stddev.val[0];
    //CMPT275
    cv::Mat laplacianImage8bit;
    laplacianImage.convertTo(laplacianImage8bit, CV_8UC1);
    
    unsigned char *pixels = laplacianImage8bit.data;
    
    // 16777216 = 256*256*256
    double maxLap = -16777216;
    for (int i = 0; i < ( laplacianImage8bit.elemSize()*laplacianImage8bit.total()); i++) {
        if (pixels[i] > maxLap) {
            maxLap = pixels[i];
        }
    }
    
    return variance;
}
@end
