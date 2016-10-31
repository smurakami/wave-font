//
//  SpeechAPI.m
//  WaveType
//
//  Created by 村上晋太郎 on 2016/10/25.
//  Copyright © 2016年 S. Murakami. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "SpeechAPI.h"


#define GOOGLE_SPEECH_API_KEY @"AIzaSyAgeieog6096EiamsexzDnFk4OE0SnGe_g"

@interface SpeechAPI () <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) void (^callback)(NSString * _Nonnull string);
@property (nonatomic, strong) NSString * str;

@end

@implementation SpeechAPI

- (id) init
{
    self = [super init];
    
    return self;
}

#pragma mark - NSURLDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _str = @"";
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *jsonError = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    if ([jsonData[@"result"] count] > 0) {
        
        NSArray *resultList = jsonData[@"result"];
        NSDictionary *dic = resultList[0];
        NSArray *alternativeList = dic[@"alternative"];
        
        NSLog(@"google result:%@", alternativeList[0][@"transcript"]);
        
        _str = [NSString stringWithFormat:@"%@", alternativeList[0][@"transcript"]];
    } else {
        NSLog(@"google result is null");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSAlert * alert = [[NSAlert alloc] init];
    [alert setMessageText:@"ネット接続エラーです..."];
    [alert runModal];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.callback) {
        self.callback(_str);
    }
    self.callback = nil;
    _str = @"";
}

#pragma mark - Google Speech API

//- (void)callGoogleRecognizeApi:(nonnull NSURL *)voiceURL
- (void)recognize: (nonnull NSURL *)voiceURL callback: (nullable void (^)(NSString * _Nonnull  string))callback
{
    self.callback = callback;
    NSData *data = [NSData dataWithContentsOfURL:voiceURL];
    
    NSString *urlStr = [NSString stringWithFormat:@"https://www.google.com/speech-api/v2/recognize?lang=ja-jp&key=%@", GOOGLE_SPEECH_API_KEY];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"audio/l16; rate=16000" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"chromium" forHTTPHeaderField:@"client"];
    
    [request setHTTPBody:data];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (NSString *)makeFilePath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"%@.wav", [formatter stringFromDate:[NSDate date]]];
    
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}
@end
