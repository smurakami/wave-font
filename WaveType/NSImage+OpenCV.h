//
//  NSImage+Opencv.h
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/26.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import <opencv2/opencv.hpp>

@interface NSImage (NSImage_OpenCV) {
    
}

+(NSImage*)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end
