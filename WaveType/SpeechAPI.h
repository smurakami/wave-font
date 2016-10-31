//
//  SpeechAPI.h
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/25.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeechAPI : NSObject
- (void)recognize: (nonnull NSURL *)voiceURL callback: (nullable void (^)( NSString * _Nonnull  string))callback;
@end

