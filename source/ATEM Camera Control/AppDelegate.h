//
//  AppDelegate.h
//  ATEM Camera Control
//
//  Created by Nick Shaw on 04/05/2021.
//  Copyright © 2021 Nick Shaw. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BMDSwitcherAPI.h"
#import <list>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSButton *focusButton;
@property (weak) IBOutlet NSSlider *focusSliderValue;
@property (weak) IBOutlet NSTextField *focusFieldValue;
@property (weak) IBOutlet NSSlider *irisSliderValue;
@property (weak) IBOutlet NSTextField *irisFieldValue;
@property (weak) IBOutlet NSSlider *zoomSliderValue;
@property (weak) IBOutlet NSTextField *zoomFieldValue;
@property (weak) IBOutlet NSSlider *shutterSliderValue;
@property (weak) IBOutlet NSTextField *shutterFieldValue;
@property (weak) IBOutlet NSSlider *gainSliderValue;
@property (weak) IBOutlet NSTextField *gainFieldValue;
@property (weak) IBOutlet NSSlider *kelvinSliderValue;
@property (weak) IBOutlet NSTextField *kelvinFieldValue;
@property (weak) IBOutlet NSSlider *tintSliderValue;
@property (weak) IBOutlet NSTextField *tintFieldValue;
@property (weak) IBOutlet NSPopUpButton *lutSelect;
@property (weak) IBOutlet NSButton *lutEnable;
@property (weak) IBOutlet NSButton *assistEnable;
@property (weak) IBOutlet NSButton *falseEnable;
@property (weak) IBOutlet NSButton *zebraEnable;
@property (weak) IBOutlet NSButton *overlayEnable;
@property (weak) IBOutlet NSStepper *gainStepper;
@property (weak) IBOutlet NSSlider *zoomRocker;
@property (weak) IBOutlet NSButton *irisButton;
@property (weak) IBOutlet NSButton *memA;
@property (weak) IBOutlet NSButton *memB;
@property (weak) IBOutlet NSButton *memC;
@property (weak) IBOutlet NSButton *memD;
@property (weak) IBOutlet NSButton *memE;
@property (weak) IBOutlet NSWindow *switcherWindow;
@property (weak) IBOutlet NSTextField *switcherIpAddress;
@property (weak) IBOutlet NSWindow *gradingWindow;
@property (weak) IBOutlet NSTextField *gradeGainField;
@property (weak) IBOutlet NSSlider *gradeGainSlider;
@property (weak) IBOutlet NSTextField *gradeLiftField;
@property (weak) IBOutlet NSSlider *gradeLiftSlider;
@property (weak) IBOutlet NSTextField *gradeGammaField;
@property (weak) IBOutlet NSSlider *gradeGammaSlider;
@property (weak) IBOutlet NSTextField *gradeSatField;
@property (weak) IBOutlet NSSlider *gradeSatSlider;

- (IBAction)doFocus:(id)sender;
- (IBAction)doIris:(id)sender;
- (IBAction)focusSliderUpdate:(id)sender;
- (IBAction)focusFieldUpdate:(id)sender;
- (IBAction)irisSliderUpdate:(id)sender;
- (IBAction)irisFieldUpdate:(id)sender;
- (IBAction)zoomSliderUpdate:(id)sender;
- (IBAction)zoomFieldUpdate:(id)sender;
- (IBAction)shutterSliderUpdate:(id)sender;
- (IBAction)shutterFieldUpdate:(id)sender;
- (IBAction)gainSliderUpdate:(id)sender;
- (IBAction)gainFieldUpdate:(id)sender;
- (IBAction)kelvinSliderupdate:(id)sender;
- (IBAction)kelvinFieldUpdate:(id)sender;
- (IBAction)tintSliderUpdate:(id)sender;
- (IBAction)tintFieldUpdate:(id)sender;
- (IBAction)lutSelectUpdate:(id)sender;
- (IBAction)lutEnableUpdate:(id)sender;
- (IBAction)assistEnableUpdate:(id)sender;
- (IBAction)falseEnableUpdate:(id)sender;
- (IBAction)zebraEnableUpdate:(id)sender;
- (IBAction)overlayEnableUpdate:(id)sender;
- (IBAction)gainStepperUpdate:(id)sender;
- (IBAction)menuGainUp:(id)sender;
- (IBAction)menuGainDown:(id)sender;
- (IBAction)zoomRockerUpdate:(id)sender;
- (IBAction)doMemA:(id)sender;
- (IBAction)doMemB:(id)sender;
- (IBAction)doMemC:(id)sender;
- (IBAction)doMemD:(id)sender;
- (IBAction)doMemE:(id)sender;
- (IBAction)openSwitcherWindow:(id)sender;
- (IBAction)focusNearer:(id)sender;
- (IBAction)focusFurther:(id)sender;
- (IBAction)setIpAddress:(id)sender;
- (IBAction)openGradingWindow:(id)sender;
- (IBAction)gradeGainUpdate:(id)sender;
- (IBAction)gradeLiftUpdate:(id)sender;
- (IBAction)gradeGammaUpdate:(id)sender;
- (IBAction)gradeSatUpdate:(id)sender;
- (IBAction)runMacroZero:(id)sender;
- (IBAction)runMacroOne:(id)sender;
- (IBAction)runMacroTwo:(id)sender;
- (IBAction)runMacroThree:(id)sender;
- (IBAction)runMacroFour:(id)sender;
- (IBAction)runMacroFive:(id)sender;
- (IBAction)runMacroSix:(id)sender;
- (IBAction)runMacroSeven:(id)sender;
- (IBAction)runMacroNine:(id)sender;
- (IBAction)runMacroEight:(id)sender;


@end

