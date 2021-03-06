//
//  advtts.m
//  MEbook eXtra
//
//  Created by Lorenzo Chellini on 13/10/15.
//
//

#import "Advtts.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation Advtts


- (void)pluginInitialize
{
    if( !synthesizer ){
        synthesizer = [AVSpeechSynthesizer new];
        synthesizer.delegate = self;
        
        AVSpeechUtterance *bugWorkaroundUtterance = [AVSpeechUtterance speechUtteranceWithString:@" "];
        bugWorkaroundUtterance.rate = AVSpeechUtteranceMaximumSpeechRate;
        [synthesizer speakUtterance:bugWorkaroundUtterance];
        
        locale = @"it-IT";
    }
}


-(void)registerCallback:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [ result setKeepCallbackAsBool:YES ];
    regCallbackId = command.callbackId;
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId ];
}


-(void)setProp:(CDVInvokedUrlCommand*)command
{
    locale = [command.arguments objectAtIndex:0];
    if( locale.length == 2 )
        locale = [ NSString stringWithFormat:@"%@-%@", locale, locale.uppercaseString ];
    
    rate = [command.arguments[1] doubleValue];
    
    //Feedback result
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [ result setKeepCallbackAsBool:YES ];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId ];
}


-(void)speak:(CDVInvokedUrlCommand*)command
{
    NSLog(@"TTS SPEAK");
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    
    [self performSelector:@selector(play:) withObject:command afterDelay:0.5];
}


-(void)play:(CDVInvokedUrlCommand*)command
{
    NSLog(@"TTS PLAY");
    
    NSString* text = [command.arguments objectAtIndex:0];
    
    AVSpeechUtterance* utterance = [[AVSpeechUtterance new] initWithString:text];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:locale];
    
    if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") )
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rate *0.8;
    else {
        if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") )
            utterance.rate = 0.05;
        else
            utterance.rate = (AVSpeechUtteranceMinimumSpeechRate + AVSpeechUtteranceDefaultSpeechRate) / 3.0 * rate * rate;
    }
    /*
     int iOSv = floor(NSFoundationVersionNumber);
     int ios7 = NSFoundationVersionNumber_iOS_7_0;
     
     if( floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0 && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_8_4 )
     utterance.rate = 0.05;
     else
     utterance.rate = AVSpeechUtteranceDefaultSpeechRate *0.85* rate;
     */
    /*
     if( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0") )
     utterance.rate = AVSpeechUtteranceDefaultSpeechRate * rate;
     else
     utterance.rate = (AVSpeechUtteranceMinimumSpeechRate * 1.5 + AVSpeechUtteranceDefaultSpeechRate) / 2.5 * rate * rate;
     */
    utterance.pitchMultiplier = 1.2;
    [synthesizer speakUtterance:utterance];
    
    //Feedback result
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId ];
    if( regCallbackId ){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"startSpeak"];
        [ result setKeepCallbackAsBool:YES ];
        [self.commandDelegate sendPluginResult:result callbackId:regCallbackId];
    }
}


-(void)pause:(CDVInvokedUrlCommand*)command
{
    NSLog(@"TTS PAUSE");
    [ synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate ];
    //Feedback result
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId ];
    if( regCallbackId ){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"stopSpeak"];
        [ result setKeepCallbackAsBool:YES ];
        [self.commandDelegate sendPluginResult:result callbackId:regCallbackId];
    }
}


-(void)resume:(CDVInvokedUrlCommand*)command
{
    NSLog(@"TTS RESUME");
    [ synthesizer continueSpeaking ];
    //Feedback result
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId ];
    if( regCallbackId ){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"startSpeak"];
        [ result setKeepCallbackAsBool:YES ];
        [self.commandDelegate sendPluginResult:result callbackId:regCallbackId];
    }
}


-(void)ADV_method:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId ];
}


-(void)speechSynthesizer:(AVSpeechSynthesizer*)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance*)utterance
{
    NSLog(@"TTS FINISH");
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [ result setKeepCallbackAsBool:YES ];
    if( regCallbackId ){
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"stopSpeak"];
        [ result setKeepCallbackAsBool:YES ];
        [self.commandDelegate sendPluginResult:result callbackId:regCallbackId];
    }
}

@end
