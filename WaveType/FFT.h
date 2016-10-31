//
//  FFT.h
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/29.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFT : NSObject
+ (void)fft:(const float*)data real:(float *) real imag:(float *) imag length:(int)length;
+ (void)ifft:(const float*)data real:(float *) real imag:(float *) imag length:(int)length;
+ (void)fft:(const float*)data real:(float *) real imag:(float *) imag length:(int)length inverse:(BOOL)inverse;
+ (void)autoCorr:(const float*)data output: (float *) output length:(int) length;
+(float)pitch:(const float *)data length:(int)length;
@end
