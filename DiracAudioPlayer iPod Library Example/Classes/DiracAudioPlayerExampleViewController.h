//
//  DiracAudioPlayerExampleViewController.h
//  DiracAudioPlayerExample
//
//  Created by Stephan on 22.11.2012.
//  Copyright 2012 The DSP Dimension. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiracAudioPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WaveFormViewIOS.h"


@interface DiracAudioPlayerExampleViewController : UIViewController <MPMediaPickerControllerDelegate> {
    
    //IBOutlet WaveFormViewIOS *wfv;
    
	IBOutlet UIButton *uiStartButton;
	IBOutlet UIButton *uiStopButton;
	
	IBOutlet UISlider *uiDurationSliderA;
	IBOutlet UISlider *uiDurationSliderB;
	IBOutlet UISlider *uiPitchSlider;
	
	IBOutlet UILabel *uiDurationLabelA;
	IBOutlet UILabel *uiDurationLabelB;
	IBOutlet UILabel *uiPitchLabel;

	IBOutlet UISwitch *uiVarispeedSwitch;
	BOOL mUseVarispeed;
    
    int delegateAB;
    int statusA;
    int statusB;


	
	MPMediaPickerController *mPicker;
    MPMusicPlayerController *mPlayer;
    MPMediaQuery *mQuery;
    MPMediaPredicate *mPredicate;

	
}

@property (retain, nonatomic) IBOutlet WaveFormViewIOS *wfvA;
@property (retain, nonatomic) IBOutlet WaveFormViewIOS *wfvB;


-(IBAction)uiDurationSliderMoved:(UISlider *)sender;
-(IBAction)uiPitchSliderMoved:(UISlider *)sender;

-(IBAction)uiStartButtonTapped:(UIButton *)sender;
-(IBAction)uiStopButtonTapped:(UIButton *)sender;

-(IBAction)uiVarispeedSwitchTapped:(UISwitch *)sender;
- (IBAction)loadAudio:(id)sender;

@end

