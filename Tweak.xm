#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "MicProgressView.m"

#import <libactivator/libactivator.h>

#define VOICE_SEARCH_TITLE @"Voice Search"
#define VOICE_SEARCH_SPEECH_ERROR @"An error occured while recognizing your speech."
#define VOICE_SEARCH_CONNECTION_ERROR @"I was unable to contact the server. Please try again later."

/*

 To-Do:
    
    * Make it nicer.
    * Remove threats directed at Nolan  
    * Possibly fix alerts? 
    * Add cool graphix of some sort
    * Keep it away from Nolan.

*/
 

@interface SearchController : NSObject <LAListener, AVAudioRecorderDelegate, UIAlertViewDelegate> {
    
    
    MicProgressView* microphoneGague;
    UIAlertView* microphoneAlert;

    AVAudioRecorder *recorder;
    NSTimer* levelTimer;
    SystemSoundID* systemSoundID;
    AVAudioSession* audioSession;
    NSMutableData* returnData;
    NSString *finalResult;

}

-(void)beginListening;
-(void)submitSpeechToGoogle;
-(void)initializeStuff;

-(void)openURLWithString:(NSString*)herpes;

-(void)speak:(NSString*)meow;

@end

@implementation SearchController

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
    
    //NSLog(@"Hello there user, I'd just like to point out that this is indeed, a beta. If you complain about functionality, UI, or anything else.... Go fuck yourself. If you are testing this, do not leak it. THAT GOES FOR YOU NOLAN.");
    
    if ([[AVAudioSession sharedInstance] inputIsAvailable]) {
        
        [self initializeStuff];
        
        microphoneAlert = [[UIAlertView alloc] 
                           initWithTitle:@"Speak Now"
                           message:@"\n\n\n\n\n\n\nGoogle Search" 
                           delegate:self 
                           cancelButtonTitle:@"Cancel" 
                           otherButtonTitles:@"Done",nil];
        
        UIImageView *placeholderView = [[UIImageView alloc] initWithFrame:CGRectMake(115.0, 65.0, 60.0, 101.0)];
        
        placeholderView.image = [UIImage imageNamed:@"VSMic_Placeholder.png"];
        [microphoneAlert addSubview:placeholderView];
        
        microphoneGague = [[MicProgressView alloc] initWithFrame:CGRectMake(113.0, 79.0, 65.0, 34.0)]; //I think I'll replace this with a sexy microphone. Because it'll look sexy. Not ghey, like this. 
        microphoneGague.transform=CGAffineTransformMakeRotation(M_PI/-2);
        
        [microphoneAlert addSubview:microphoneGague];
        
        [microphoneAlert show];
        [microphoneAlert release];
        
        [self beginListening];
        
    }
    else {
        microphoneAlert = [[UIAlertView alloc] 
                           initWithTitle:VOICE_SEARCH_TITLE
                           message:@"A microphone was not detected. Please plug in a microphone and try again." 
                           delegate:nil
                           cancelButtonTitle:@"Okay" 
                           otherButtonTitles:nil];
        
        [microphoneAlert show];
        [microphoneAlert release];
        
    }
		
	[event setHandled: YES];
	
}

-(void)openURLWithString:(NSString*)herpes {
    
    NSURL *url = [NSURL URLWithString:herpes];
    
    [[UIApplication sharedApplication]applicationOpenURL:url];
    
}



-(void)beginListening {
    
    NSLog(@"Listen method called by system");
    
    NSError* error;
    if (recorder.recording)
    {
        
        /*
        NSString* recorderSound = [[NSBundle mainBundle] pathForResource:@"stop-rec" ofType:@"mp3"];
        NSURL *soundURL = [[NSURL alloc] initFileURLWithPath: recorderSound];
        AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [player setDelegate:self];
        [player prepareToPlay];
        [player play];
        [soundURL release];
         */
        
        [microphoneGague setProgress:0];
        
        [recorder stop];
        
        [self submitSpeechToGoogle];
        
    }
    else {
        
        /*
        CFBundleRef mainBundle= CFBundleGetMainBundle();
        CFURLRef soundFileURLRef;
        soundFileURLRef = CFBundleCopyResourceURL(mainBundle,(CFStringRef) @"start-rec", CFSTR ("mp3"), NULL);
        UInt32 soundID;
        AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
        AudioServicesPlaySystemSound(soundID);
        */
        
        [recorder record]; 
        
        //recorderSound = [[NSBundle mainBundle] pathForResource:@"start-rec" ofType:@"mp3"];
        return;
        
    }
    
    if (error) {
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:@"An Error Occured" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
        
        
    }
    
    /*
     NSFileManager *fm = [NSFileManager defaultManager];
     
     err = nil;
     [fm removeItemAtPath:[url path] error:&err];
     if(err)
     NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
     */
}

-(void)speak:(NSString *)meow {
    
    NSLog(@"MEOW!");
    
    NSObject* speaker = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];

    [speaker startSpeakingString:meow];
    
}

/*
 
 * Les delegate methods. Nothing fun goes on here. Except for the important stuff.
 
*/

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)mexican
{
    
    NSLog(@"Recording has finished... Yey.");
    
    /*
    if (flag) {
        [self submitSpeechToGoogle];
    }
    else {
        [self speak:@"Sorry, I didn't catch that. Try again?"];
    }
     */
    if (!mexican) {
        [self speak:@"An error occured while processing your speech. Try again?"];
        
        microphoneAlert = [[UIAlertView alloc] 
                           initWithTitle:VOICE_SEARCH_TITLE
                           message:VOICE_SEARCH_SPEECH_ERROR
                           delegate:nil
                           cancelButtonTitle:@"Okay" 
                           otherButtonTitles:nil];
        
        [microphoneAlert show];
        [microphoneAlert release];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:@"/var/mobile/VS-Temp.wav" error:nil];
        
    }
}

- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alert == microphoneAlert) {
        
        if (buttonIndex == 1) {
        
            NSLog(@"Searching...");
            [self beginListening];
        
        /*
         
         
         NSString *query = [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
         
         NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@", query]];
         
         [[UIApplication sharedApplication]applicationOpenURL:url];
         */
        
        }
        else {
            
            NSLog(@"Cancelled Voice Search");
            //[microphoneAlert release];
            
            if (recorder.recording) {
                [recorder stop];
            }
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm removeItemAtPath:@"/var/mobile/VS-Temp.wav" error:nil];
        }
    }
    //[microphoneGague release];
}

-(void)initializeStuff {
    
    NSLog(@"Initializing Recording session...");
    
    NSError *error;
    
    //Load Audio Session
    audioSession = [[AVAudioSession sharedInstance] retain];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    [audioSession setActive:YES error:&error];
    
    //Load Recorder
    NSURL *soundFileURL = [NSURL fileURLWithPath:@"/var/mobile/VS-Temp.wav"];
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey]; 
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
    recorder = [[AVAudioRecorder alloc]
                initWithURL:soundFileURL
                settings:recordSetting
                error:&error];
    
    recorder.meteringEnabled = YES;
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    
    levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
    
    
     UInt32 ASRoute = kAudioSessionOverrideAudioRoute_Speaker;
     AudioSessionSetProperty (
     kAudioSessionProperty_OverrideAudioRoute,
     sizeof (ASRoute),
     &ASRoute
     );
     
     
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        UIAlertView* recorderError = [[UIAlertView alloc] initWithTitle:@"An Error Occurred" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [recorderError show];
        [recorderError release];
        
    }  
    
}


- (void)levelTimerCallback:(NSTimer *)timer {
	
    if(recorder.isRecording)
    {        
        [recorder updateMeters];
        
		//float dBLevel = [recorder averagePowerForChannel:0];
        double avgPowerForChannel = pow(10, (0.05 * [recorder averagePowerForChannel:0]));
		[microphoneGague setProgress:avgPowerForChannel animated:YES];
        
        if (microphoneGague.progress <= 0.04) {
            [microphoneGague setProgress:0.09 animated:YES];
        }

    }
    
    
}

// ========================= GOOGLE SERVER CODE. ============================//
        //Move this to another class, for christ's sake. 

- (void) submitSpeechToGoogle {
    
    //[loadingIndicator startAnimating];
    
    microphoneAlert = [[UIAlertView alloc] 
                       initWithTitle:VOICE_SEARCH_TITLE
                       message:nil 
                       delegate:nil
                       cancelButtonTitle:nil
                       otherButtonTitles:nil];
    
    [microphoneAlert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.frame = CGRectMake(35.0, 60.0, 220.0, 25.0);
    [indicator startAnimating];
    [microphoneAlert addSubview:indicator];
    
    
    system("flac /var/mobile/VS-Temp.wav --sample-rate=16000 -o /var/mobile/VS-Temp.flac");
    
    NSString *recDir = @"/var/mobile";
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/VS-Temp.flac", recDir]];
    
    NSData *flacFile = [NSData dataWithContentsOfURL:url];
    //NSString *audio = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/recordTest.flac", recDir]];
    
    
    //NSString* languageCode = [NSString stringWithFormat:@"%@-%@",[[NSLocale preferredLanguages] objectAtIndex:0],[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
    
    NSString* languageCode = [NSString stringWithFormat:@"%@",[[NSLocale preferredLanguages] objectAtIndex:0]];
    
    NSLog(@"Current Language Code Set To: %@",languageCode);
    
    NSString* googleSpeechURL = [NSString stringWithFormat:@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=%@",languageCode];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] 
                                    initWithURL:[NSURL URLWithString:googleSpeechURL]];
    
    [request setHTTPMethod:@"POST"];
    
    //set headers
    
    [request addValue:@"Content-Type" forHTTPHeaderField:@"audio/x-flac; rate=16000"];
    
    [request addValue:@"audio/x-flac; rate=16000" forHTTPHeaderField:@"Content-Type"];
    
    //NSString *requestBody = [[NSString alloc] initWithFormat:@"Content=%@", flacFile];
    
    //[request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:flacFile];
    
    [request setValue:[NSString stringWithFormat:@"%d",[flacFile length]] forHTTPHeaderField:@"Content-length"];
    
    
    NSURLConnection *gConnect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [gConnect start];
    //[gConnect release];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    returnData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [returnData appendData:data];
}
- (void)connection:(NSURLConnection *)aConn didFailWithError:(NSError *)error {
    
    [microphoneAlert dismissWithClickedButtonIndex:0 animated:YES];
    [microphoneAlert release];
    
    [self speak:VOICE_SEARCH_CONNECTION_ERROR];
    
    microphoneAlert = [[UIAlertView alloc] 
                       initWithTitle:VOICE_SEARCH_TITLE
                       message:VOICE_SEARCH_CONNECTION_ERROR
                       delegate:nil
                       cancelButtonTitle:@"Okay" 
                       otherButtonTitles:nil];
    [microphoneAlert show];
    [microphoneAlert release];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    finalResult = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response from server: %@",finalResult);
    
    // Max hates the following........ Oh well.
    
    @try {
        NSRange range = [finalResult rangeOfString:@"{\"utterance\":\""];
        NSString* gspeechhalf = [finalResult substringFromIndex:range.location+14];
        NSRange range2 = [gspeechhalf rangeOfString:@"\",\"confidence"];
        NSString* gspeech = [gspeechhalf substringToIndex:range2.location];
        finalResult = gspeech;
        //Set the recognized speech, ready for action! :D
        
        NSLog(@"Recognized speech: %@",finalResult);
        
        NSString *query = [finalResult stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *query1 = [query stringByReplacingOccurrencesOfString:@"find+" withString:@""];
        NSString *query2 = [query1 stringByReplacingOccurrencesOfString:@"search+" withString:@""];
        NSString* query3 = [query2 stringByReplacingOccurrencesOfString:@"google+" withString:@""];
        
        NSString* searchURL = [NSString stringWithFormat:@"http://www.google.com/search?q=%@", query3];
        
        [microphoneAlert dismissWithClickedButtonIndex:0 animated:YES];
        [microphoneAlert release];
        
        [self openURLWithString:searchURL];
        
    }
    @catch (NSException *exception) {
        [self speak:VOICE_SEARCH_SPEECH_ERROR];
        
        [microphoneAlert dismissWithClickedButtonIndex:0 animated:YES];
        [microphoneAlert release];
        
        microphoneAlert = [[UIAlertView alloc] 
                           initWithTitle:VOICE_SEARCH_TITLE
                           message:@"An Error occured"
                           delegate:nil
                           cancelButtonTitle:@"Okay" 
                           otherButtonTitles:nil];
        [microphoneAlert show];
        [microphoneAlert release];
    }
    
    //[finalResult release];

    
    //[self addMessage:result]; DEBUG
    
    NSError* err = nil;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    
    [fm removeItemAtPath:@"/var/mobile/VS-Temp.flac" error:&err];
    [fm removeItemAtPath:@"/var/mobile/VS-Temp.wav" error:&err];
    
    if(err) {
        NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        
        /*
        UIAlertView* errorAlert = [[UIAlertView alloc]initWithTitle:@"An Error Occurred" message:[NSString stringWithFormat:@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [errorAlert show];
        [errorAlert release];
         */
    }
    else {
        NSLog(@"Deleted temp flac files successfully!");
    }
    
    [returnData release];
    //[microphoneAlert release];
}

                

//---------------------- Activator stuffz ------------------------//

+ (void)load
{
    [[LAActivator sharedInstance] registerListener:[self new] forName:@"com.gmoran.voicesearch"];
}


@end