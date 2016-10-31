//
//  FFT.m
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/29.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

#import "FFT.h"
#import <Accelerate/Accelerate.h>

@implementation FFT
+ (void)fft:(const float*)data real:(float *)real imag:(float *)imag  length:(int)length {
    [FFT fft:data real: real imag: imag length:length inverse:NO];
}

+ (void)ifft:(const float*)data real:(float *)real imag:(float *)imag  length:(int)length {
    [FFT fft:data real: real imag: imag length:length inverse:YES];
}

+ (void)fft:(const float*)data real:(float *)real imag:(float *)imag  length:(int)length inverse:(BOOL)inverse {
    // データ長を2のn乗の大きさにする
    unsigned int sizeLog2 = (int)(log(length)/log(2));
    unsigned int size = 1 << sizeLog2;
    
    // fftのセットアップ
    FFTSetup fftSetUp = vDSP_create_fftsetup(sizeLog2 + 1, FFT_RADIX2);
    
    // 窓関数の用意
    float* window = calloc(size, sizeof(float));
    float* windowedInput = calloc(size, sizeof(float));
    vDSP_hann_window(window, size, 0);
    
    // 窓関数を入力値に適用し、windewedInputへ
    vDSP_vmul(data, 1, window, 1, windowedInput, 1, size);
//    for (int i = 0; i < size; i++) {
//        windowedInput[i] = data[i];
//    }
    
    // 入力を複素数にする
    DSPSplitComplex splitComplex;
    splitComplex.realp = calloc(size, sizeof(float));
    splitComplex.imagp = calloc(size, sizeof(float));
    
    for (int i = 0; i < size; i++) {
        splitComplex.realp[i] = windowedInput[i];
        splitComplex.imagp[i] = 0.0f;
    }
    
    // FFTを計算する
    if (inverse) {
        vDSP_fft_zrip(fftSetUp, &splitComplex, 1, sizeLog2 + 1, FFT_INVERSE);
    } else {
        vDSP_fft_zrip(fftSetUp, &splitComplex, 1, sizeLog2 + 1, FFT_FORWARD);
    }
    
    // 結果を表示する
    for (int i = 0; i < size; i++) {
        real[i] = splitComplex.realp[i];
        imag[i] = splitComplex.imagp[i];
    }
    
    // メモリを開放する
    free(splitComplex.realp);
    free(splitComplex.imagp);
    free(window);
    free(windowedInput);
    vDSP_destroy_fftsetup(fftSetUp);
    
}

+ (void)autoCorr:(const float *)data output:(float *)output length:(int)length {
    for (int gap = 0; gap < length; gap++) {
        float val = 0;
        for (int i = 0; i < length; i++) {
            val += data[i] * data[(i + gap) % length];
        }
        val /= length;
        
        output[gap] = val;
    }
    
//    float * realp = calloc(length, sizeof(float));
//    float * imagp = calloc(length, sizeof(float));
//    float * specp = calloc(length, sizeof(float));
//    
//    [FFT fft:data real:realp imag:imagp length:length];
//    
//    for (int i = 0; i < length; i++) {
////        specp[i] = powf(realp[i], 2) + powf(imagp[i], 2);
//        specp[i] = powf(realp[i], 2) + powf(imagp[i], 2);
//    }
//    
//    printf("[ ");
//    
//    for (int i = 0; i < length; i++) {
//        printf("%f, ", realp[i]);
//    }
//    printf("] \n");
//    
//    
//    [FFT ifft:specp real:output imag:imagp length:length];
//    
////    for (int i = 0; i < length; i++) {
////        specp[i] = powf(realp[i], 2) + powf(imagp[i], 2);
////    }
//    free(specp);
//    free(realp);
//    free(imagp);
}

+(float)_pitch:(const float *)data length:(int)length {
    float * corr = calloc(length, sizeof(float));
    
    [FFT autoCorr:data output:corr length:length];
    
    BOOL flg = NO;
    int argmax = 0;
    float max = 0;
    for (int i = 0; i < length/2; i++) {
        float val = corr[i];
        if (val < 0) {
            flg = YES;
        }
        
        if (flg) {
            if (val > max) {
                max = val;
                argmax = i;
            }
        }
    
    }
    
    free(corr);
    
    if (argmax > 0) {
        float samplingRate = 16000.0;
        return samplingRate / argmax;
    } else {
        return 0;
    }
}

+(float)pitch:(const float *)data length:(int)length {
    
    int window = 1024;
    int valid_count = 0;
    float sum = 0;
    for (int i = 0; i < length - window; i += window/2) {
        
        float power = 0;
        const float * part = data + i;
        for (int j = 0; j < window; j++) {
            power += part[j] * part[j];
        }
        
        power /= window;
        
        float pitch = [FFT _pitch:part length:window];
        
        if ((pitch < 1000) && (pitch > 40)) {
            valid_count++;
            sum += pitch;
        }
    }
    
    if (valid_count > 0) {
        return sum / valid_count;
    } else {
        return 0;
    }
}

@end
