//
//  OpenCV.m
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/25.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

#import "OpenCV.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui.hpp>
#import "NSImage+OpenCV.h"

#include <vector>
#include <iostream>


@implementation OpenCV

- (nonnull NSArray *)scanImage:(nonnull NSImage *)image {
    cv::Mat mat = [image CVMat];
    
    cv::cvtColor(mat, mat, CV_RGB2GRAY);
    cv::GaussianBlur(mat, mat, cv::Size(11, 11), 0);
    cv::threshold(mat, mat, 127, 255, CV_THRESH_BINARY_INV);
    
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    
    cv::findContours(mat, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_NONE);
    std::cout << contours.size() << std::endl;
    
    NSMutableArray * c = [NSMutableArray array];
    NSMutableArray * h = [NSMutableArray array];
    
    for (int i = 0; i < contours.size(); i++) {
        auto contour = contours[i];
        NSMutableArray * array = [NSMutableArray array];
        for (int j = 0; j < contour.size(); j++) {
            auto point = contour[j];
            NSPoint p;
            p.x = point.x;
            p.y = point.y;
            [array addObject: [NSValue valueWithPoint:p]];
        }
        [c addObject: array];
    }
    
    for (int i = 0; i < hierarchy.size(); i++) {
        auto elem = hierarchy[i];
        NSMutableArray * array = [NSMutableArray array];
        
        for (int j = 0; j < 4; j++) {
            [array addObject:[NSNumber numberWithInt:elem[j]]];
        }
        
        [h addObject: array];
    }
    
    return @[c, h];
}

@end
