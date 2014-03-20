
/*
 
	ABSTRACT:
	This example demonstrates how to use the DiracAudioFile player class to process and play back
	an MPMediaItem from the user's iPod library in real time (high quality setting)
 
 */

//
//  DiracAudioPlayerExampleViewController.m
//  DiracAudioPlayerExample
//
//  Created by Stephan on 22.11.2012.
//  Copyright 2012 The DSP Dimension. All rights reserved.
//

#import "DiracAudioPlayerExampleViewController.h"
#import <AVFoundation/AVFoundation.h>

#if (TARGET_IPHONE_SIMULATOR)
	#error "This project can only be run on a real device, it does not work with the simulator because Apple does not support MPMediaPickerController on the simulator"
#endif



@implementation DiracAudioPlayerExampleViewController

@synthesize wfvA, wfvB;

// ---------------------------------------------------------------------------------------------------------------------------------------------

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/
// ---------------------------------------------------------------------------------------------------------------------------------------------

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/
- (void)diracPlayerDidFinishPlaying:(DiracAudioPlayerBase *)player successfully:(BOOL)flag
{
	NSLog(@"Dirac player instance (0x%lx) is done playing", (long)player);
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	
	[super viewDidLoad];
    statusA = 0; // status = not playing
    statusB = 0; // status = not playing
	mUseVarispeed = NO;
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiDurationSliderMovedA:(UISlider *)sender;
{
    [wfvA changeDuration:sender.value];
	uiDurationLabelA.text = [NSString stringWithFormat:@"%3.2f", sender.value];

    /*
	[mDiracAudioPlayerA changeDuration:sender.value];
	uiDurationLabelA.text = [NSString stringWithFormat:@"%3.2f", sender.value];
	
	if (mUseVarispeed) {
		float val = 1.f/sender.value;
		uiPitchSlider.value = (int)12.f*log2f(val);
		uiPitchLabel.text = [NSString stringWithFormat:@"%d", (int)uiPitchSlider.value];
		[mDiracAudioPlayerA changePitch:val];
	}
     */
	
}

-(IBAction)uiDurationSliderMovedB:(UISlider *)sender;
{
    [wfvB changeDuration:sender.value];
	uiDurationLabelB.text = [NSString stringWithFormat:@"%3.2f", sender.value];
    /*
	[mDiracAudioPlayerB changeDuration:sender.value];
	uiDurationLabelB.text = [NSString stringWithFormat:@"%3.2f", sender.value];
	
	if (mUseVarispeed) {
		float val = 1.f/sender.value;
		uiPitchSlider.value = (int)12.f*log2f(val);
		uiPitchLabel.text = [NSString stringWithFormat:@"%d", (int)uiPitchSlider.value];
		[mDiracAudioPlayerB changePitch:val];
	}
	*/
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

-(IBAction)uiPitchSliderMoved:(UISlider *)sender;
{
	/*
     [mDiracAudioPlayerA changePitch:powf(2.f, (int)sender.value / 12.f)];
	uiPitchLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
     */
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

// LOAD button
-(IBAction)uiStartButtonTappedA:(UIButton *)sender;
{
    delegateAB = 1; // A
	MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
	
	[picker setDelegate: self];
	[picker setAllowsPickingMultipleItems: NO];
	picker.prompt = @"Choose song A";

	[self presentModalViewController: picker animated: YES];
	[picker release];
}

// LOAD button
-(IBAction)uiStartButtonTappedB:(UIButton *)sender;
{
    delegateAB = 2; // B
	MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
	
	[picker setDelegate: self];
	[picker setAllowsPickingMultipleItems: NO];
	picker.prompt = @"Choose song B";
	[self presentModalViewController: picker animated: YES];
	[picker release];
}


// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker
   didPickMediaItems:(MPMediaItemCollection *)collection
{
    MPMediaItem *mediaItem = [collection.items objectAtIndex:0];
	NSURL *inUrl = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];	
    
    
    // set up an AVAssetReader to read from the iPod Library
    AVURLAsset *songAsset =
    [AVURLAsset URLAssetWithURL:inUrl options:nil];
    
    NSError *assetError = nil;
    AVAssetReader *assetReader =
    [[AVAssetReader assetReaderWithAsset:songAsset
                                   error:&assetError]
     retain];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }

    AVAssetReaderOutput *assetReaderOutput =
	[[AVAssetReaderAudioMixOutput
	  assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
      audioSettings: nil]
     retain];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return;
    }
    [assetReader addOutput: assetReaderOutput];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [[documentsDirectoryPath
                             stringByAppendingPathComponent:@"sampleA.caf"]
                            retain];
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath
                                                   error:nil];
    }
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter =
	[[AVAssetWriter assetWriterWithURL:exportURL
                              fileType:AVFileTypeCoreAudioFormat
                                 error:&assetError]
     retain];
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
     [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
     [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
     [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)],
     AVChannelLayoutKey,
     [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
     [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
     [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
     nil];
    
    AVAssetWriterInput *assetWriterInput =
	[[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                        outputSettings:outputSettings]
     retain];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return;
    }
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    
    [assetWriter startWriting];
    [assetReader startReading];
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    dispatch_queue_t mediaInputQueue =
	dispatch_queue_create("mediaInputQueue", NULL);

    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
        {
            while (assetWriterInput.readyForMoreMediaData) {
                CMSampleBufferRef nextBuffer =
                    [assetReaderOutput copyNextSampleBuffer];
                if (nextBuffer) {
                    // append buffer
                    [assetWriterInput appendSampleBuffer: nextBuffer];
                    // update ui
                    convertedByteCount +=
                    CMSampleBufferGetTotalSampleSize (nextBuffer);
                    NSNumber *convertedByteCountNumber =
                    [NSNumber numberWithLong:convertedByteCount];
                    /*
                    [self performSelectorOnMainThread:@selector(updateSizeLabel:)
                                           withObject:convertedByteCountNumber
                                        waitUntilDone:NO];
                     */
                } else {
                    // done!
                    [assetWriterInput markAsFinished];
                    [assetWriter finishWriting];
                    [assetReader cancelReading];
                    NSDictionary *outputFileAttributes =
                    [[NSFileManager defaultManager]
                     attributesOfItemAtPath:exportPath
                     error:nil];
                    NSLog (@"Done. file size is %ld",
                           [outputFileAttributes fileSize]);
                    NSNumber *doneFileSize = [NSNumber numberWithLong:
                                              [outputFileAttributes fileSize]];
                    /*
                    [self performSelectorOnMainThread:@selector(updateCompletedSizeLabel:)
                                           withObject:doneFileSize
                                        waitUntilDone:NO];
                     */
                    // release a lot of stuff
                    [assetReader release];
                    [assetReaderOutput release];
                    [assetWriter release];
                    [assetWriterInput release];
                    [exportPath release];
                    
                    // display the waveform
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"sampleA.caf" ofType:nil];
                    if([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
                        NSLog(@"sample file exists");
                        NSURL *songURL = [NSURL fileURLWithPath:exportPath];
                        if (delegateAB == 1)
                            [wfvA openAudioURL:songURL];
                        
                        else if (delegateAB == 2)
                            [wfvB openAudioURL:songURL];
                    }
                    NSLog (@"export path:",exportPath);
                    NSLog(@"path of sample = %@", path);
                    break;
                }
             }
        }];
	NSLog (@"bottom of convertTapped:");
    
    
    
	NSLog(@"path = %@", inUrl);
    [self dismissViewControllerAnimated:YES completion:nil];
	
}


// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

// CUE button
-(IBAction)uiStopButtonTappedA:(UIButton *)sender;
{
    [wfvA cueAudio];
    /*
    if ( statusA == 1) { // playing so stop
        [mDiracAudioPlayerA stop];
        statusA = 0; // set status
    } else { // not playing so start
        [mDiracAudioPlayerA play];
        statusA = 1; // set status
    }
     */
}
// CUE button
-(IBAction)uiStopButtonTappedB:(UIButton *)sender;
{
    [wfvB cueAudio];
    /*
    if ( statusB == 1) { // playing so stop
        [mDiracAudioPlayerB stop];
        statusB = 0; // set status
    } else { // not playing so start
        [mDiracAudioPlayerB play];
        statusB = 1; // set status
    }
     */
}




// ---------------------------------------------------------------------------------------------------------------------------------------------

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [self setWfv:nil];
}

// ---------------------------------------------------------------------------------------------------------------------------------------------

- (void)dealloc {
	/*[mDiracAudioPlayerA release];
	[mDiracAudioPlayerB release];
     */
    [wfvA release];
    [wfvB release];
    [super dealloc];
}

// ---------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------------------------------------------------------------




@end
