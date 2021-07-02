//
//  AppDelegate.m
//  ATEM Camera Control
//
//  Created by Nick Shaw on 04/05/2021.
//  Copyright © 2021 Nick Shaw. All rights reserved.
//

#import "AppDelegate.h"

#include <pthread.h>
#include <libkern/OSAtomic.h>
#include <string>

static const uint8_t kCameraAddress = 1;    // Camera Number 1
IBMDSwitcher* switcher;
IBMDSwitcherCameraControl* cameraControl;
double focus = 0.35;
double iris = 0.0;
double zoom = 0.5;
int32_t shutter = 18000;
int8_t gain = 8;
int16_t kelvin = 5600;
int16_t tint = 10;
int8_t lut = 1;
int8_t lutEnabled = 1;
int8_t assistEnabled = 0;
int8_t falseEnabled = 0;
int8_t zebraEnabled = 0;
int16_t overlayEnabled = 0;
double gradeLift = 0.0;
double gradeGamma = 0.0;
double gradeGain = 1.0;
double gradeSat = 1.0;

double memASettings[] = {0.35, 0.0, 18000.0, 8.0, 5600.0, 10.0};
double memBSettings[] = {0.40, 0.0, 36000.0, 24.0, 3400.0, 0.0};
double memCSettings[] = {0.50, 0.0, 36000.0, 20.0, 3400.0, 0.0};
double memDSettings[] = {0.40, 0.0, 36000.0, 24.0, 3400.0, 0.0};
double memESettings[] = {0.40, 0.0, 36000.0, 24.0, 3400.0, 0.0};
int memATimer = 0.0;
int memBTimer = 0.0;
int memCTimer = 0.0;
int memDTimer = 0.0;
int memETimer = 0.0;
NSMutableString *switcherIP = [@"192.168.1.240" mutableCopy];


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self loadPrefs];
    // Create discovery instance
    IBMDSwitcherDiscovery* discovery = CreateBMDSwitcherDiscoveryInstance();
    if (! discovery)
    {
        NSRunAlertPanel(@"Discovery Failure", @"Oh dear!", @"Quit", nil, nil);
        [NSApp terminate:self];
    }
    else
    {
        // Use discovery instance to connect to switcher
        BMDSwitcherConnectToFailure connectToFailReason;
        HRESULT result = discovery->ConnectTo((__bridge CFStringRef)switcherIP, &switcher, &connectToFailReason);
        discovery->Release();
        if (result != S_OK)
        {
            NSRunAlertPanel(@"Connection Failure", @"Check IP Address then restart the app.", @"OK", nil, nil);
            [self.switcherWindow setIsVisible:YES];
        }
        else
        {
            NSLog(@"Connection success");
            // Get camera control interface from switcher object
            result = switcher->QueryInterface(IID_IBMDSwitcherCameraControl, (void**)&cameraControl);
            if (result != S_OK)
            {
                NSRunAlertPanel(@"Camera Failure", @"Too bad!", @"Quit", nil, nil);
                [NSApp terminate:self];
            }
            [_memA sendActionOn:NSEventMaskLeftMouseDown];
            [_memB sendActionOn:NSEventMaskLeftMouseDown];
            [_memC sendActionOn:NSEventMaskLeftMouseDown];
            [_memD sendActionOn:NSEventMaskLeftMouseDown];
            [_memE sendActionOn:NSEventMaskLeftMouseDown];
            [NSThread sleepForTimeInterval:0.5];
            [self updateAll];
        }
    }
}

- (void) loadPrefs {
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"settingsStored"] boolValue])
    {
        switcherIP = [[[NSUserDefaults standardUserDefaults] stringForKey:@"switcherIP"] mutableCopy];
        [self.switcherIpAddress setStringValue:switcherIP];
        focus = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:@"focus"] floatValue];
        iris = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:@"iris"] floatValue];
        zoom = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:@"zoom"] floatValue];
        shutter = (int32_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"shutter"] floatValue];
        gain = (int8_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"gain"] floatValue];
        kelvin = (int16_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"kelvin"] floatValue];
        tint = (int16_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"tint"] floatValue];
        lut = (int8_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"lut"] floatValue];
        lutEnabled = (int8_t)[[[NSUserDefaults standardUserDefaults] objectForKey:@"lutEnabled"] floatValue];
        for (int i=0; i < 6; i++) {
            memASettings[i] = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:[@"memA" stringByAppendingString:[@(i) stringValue]]] floatValue];
            memBSettings[i] = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:[@"memB" stringByAppendingString:[@(i) stringValue]]] floatValue];
            memCSettings[i] = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:[@"memC" stringByAppendingString:[@(i) stringValue]]] floatValue];
            memDSettings[i] = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:[@"memD" stringByAppendingString:[@(i) stringValue]]] floatValue];
            memESettings[i] = (double)[[[NSUserDefaults standardUserDefaults] objectForKey:[@"memE" stringByAppendingString:[@(i) stringValue]]] floatValue];
        }
    }
}

- (void) updateAll {
    [self.focusFieldValue setFloatValue:focus];
    [self.focusSliderValue setFloatValue:focus];
    [self focusUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self.irisFieldValue setFloatValue:iris];
    [self.irisSliderValue setFloatValue:iris];
    [self irisUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self.shutterFieldValue setFloatValue:shutter / 100];
    [self.shutterSliderValue setFloatValue:shutter / 100];
    [self shutterUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self.gainFieldValue setFloatValue:gain];
    [self.gainSliderValue setFloatValue:gain];
    [self.gainStepper setFloatValue:gain];
    [self gainUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self.kelvinFieldValue setFloatValue:kelvin];
    [self.kelvinSliderValue setFloatValue:kelvin];
    [self.tintFieldValue setFloatValue:tint];
    [self.tintSliderValue setFloatValue:tint];
    [self wbUpdate];
    [self.lutSelect setIntValue:lut];
    [self.lutEnable setIntValue:lutEnabled];
    [self lutUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self lutUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self assistUpdate];
    [NSThread sleepForTimeInterval:0.1];
    [self overlayUpdate];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"settingsStored"];
    [[NSUserDefaults standardUserDefaults] setObject:switcherIP forKey:@"switcherIP"];
    [[NSUserDefaults standardUserDefaults] setFloat:focus forKey:@"focus"];
    [[NSUserDefaults standardUserDefaults] setFloat:iris forKey:@"iris"];
    [[NSUserDefaults standardUserDefaults] setFloat:zoom forKey:@"zoom"];
    [[NSUserDefaults standardUserDefaults] setFloat:shutter forKey:@"shutter"];
    [[NSUserDefaults standardUserDefaults] setFloat:gain forKey:@"gain"];
    [[NSUserDefaults standardUserDefaults] setFloat:kelvin forKey:@"kelvin"];
    [[NSUserDefaults standardUserDefaults] setFloat:tint forKey:@"tint"];
    [[NSUserDefaults standardUserDefaults] setFloat:lut forKey:@"lut"];
    [[NSUserDefaults standardUserDefaults] setFloat:lutEnabled forKey:@"lutEnabled"];
    for (int i=0; i < 6; i++) {
        [[NSUserDefaults standardUserDefaults] setFloat:memASettings[i] forKey:[@"memA" stringByAppendingString:[@(i) stringValue]]];
        [[NSUserDefaults standardUserDefaults] setFloat:memBSettings[i] forKey:[@"memB" stringByAppendingString:[@(i) stringValue]]];
        [[NSUserDefaults standardUserDefaults] setFloat:memCSettings[i] forKey:[@"memC" stringByAppendingString:[@(i) stringValue]]];
        [[NSUserDefaults standardUserDefaults] setFloat:memDSettings[i] forKey:[@"memD" stringByAppendingString:[@(i) stringValue]]];
        [[NSUserDefaults standardUserDefaults] setFloat:memESettings[i] forKey:[@"memE" stringByAppendingString:[@(i) stringValue]]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}


- (IBAction)doFocus:(id)sender {
    // Send auto focus command to camera
    HRESULT result = cameraControl->SetFlags    (
                                         kCameraAddress,        // Camera number
                                         0,                    // Lens
                                         1,                    // Instantaneous autofocus
                                         0,                    // This command has no additional parameter
                                         NULL
                                         );
    if (result != S_OK)
    {
        NSLog(@"Failed to send focus");
    }
}

- (IBAction)doIris:(id)sender {
    HRESULT result = cameraControl->SetFlags    (
                                                 kCameraAddress,        // Camera number
                                                 0,                    // Lens
                                                 5,                    // Instantaneous auto iris
                                                 0,                    // This command has no additional parameter
                                                 NULL
                                                 );
    if (result != S_OK)
    {
        NSLog(@"Failed to send iris");
    }
}

- (IBAction)focusSliderUpdate:(id)sender {
    focus = [sender floatValue];
    [self.focusFieldValue setFloatValue:focus];
    [self focusUpdate];
}

- (IBAction)focusFieldUpdate:(id)sender {
    focus = [sender floatValue];
    [self.focusSliderValue setFloatValue:focus];
    [self focusUpdate];
}

- (IBAction)irisSliderUpdate:(id)sender {
    iris = [sender floatValue];
    [self.irisFieldValue setFloatValue:iris];
    [self irisUpdate];
}

- (IBAction)irisFieldUpdate:(id)sender {
    iris = [sender floatValue];
    [self.irisSliderValue setFloatValue:iris];
    [self irisUpdate];
}

- (IBAction)zoomSliderUpdate:(id)sender {
    zoom = [sender floatValue];
    [self.zoomFieldValue setFloatValue:zoom];
    [self zoomUpdate];
}

- (IBAction)zoomFieldUpdate:(id)sender {
    zoom = [sender floatValue];
    [self.zoomSliderValue setFloatValue:zoom];
    [self zoomUpdate];
}

- (IBAction)shutterSliderUpdate:(id)sender {
    shutter = (int32_t)[sender integerValue] * 100;
    [self.shutterFieldValue setIntegerValue:shutter / 100];
    [self shutterUpdate];
}

- (IBAction)shutterFieldUpdate:(id)sender {
    shutter = (int32_t)[sender integerValue] * 100;
    [self.shutterSliderValue setIntegerValue:shutter / 100];
    [self shutterUpdate];
}

- (IBAction)gainSliderUpdate:(id)sender {
    gain = [sender integerValue];
    [self.gainFieldValue setIntValue:gain];
    [self.gainStepper setIntValue:gain];
    [self gainUpdate];
}

- (IBAction)gainFieldUpdate:(id)sender {
    gain = [sender integerValue];
    [self.gainSliderValue setIntValue:gain];
    [self.gainStepper setIntValue:gain];
    [self gainUpdate];
}

- (IBAction)gainStepperUpdate:(id)sender {
    [self.gainFieldValue setStringValue:[sender stringValue]];
    [self.gainSliderValue setIntegerValue:[sender integerValue]];
    gain = [sender integerValue];
    [self gainUpdate];
}

- (IBAction)menuGainUp:(id)sender {
    gain += 2;
    if (gain > 32) {
        gain = 32;
    }
    [self.gainSliderValue setIntValue:gain];
    [self.gainFieldValue setIntValue:gain];
    [self.gainStepper setIntValue:gain];
    [self gainUpdate];
}

- (IBAction)menuGainDown:(id)sender {
    gain -= 2;
    if (gain < -12) {
        gain = -12;
    }
    [self.gainSliderValue setIntValue:gain];
    [self.gainFieldValue setIntValue:gain];
    [self.gainStepper setIntValue:gain];
    [self gainUpdate];
}

- (IBAction)kelvinSliderupdate:(id)sender {
    kelvin = (int16_t)[sender integerValue];
    [self.kelvinFieldValue setIntValue:kelvin];
    [self wbUpdate];
}

- (IBAction)kelvinFieldUpdate:(id)sender {
    kelvin = (int16_t)[sender integerValue];
    [self.kelvinSliderValue setIntValue:kelvin];
    [self wbUpdate];
}

- (IBAction)tintSliderUpdate:(id)sender {
    tint = (int16_t)[sender integerValue];
    [self.tintFieldValue setIntValue:tint];
    [self wbUpdate];
}

- (IBAction)tintFieldUpdate:(id)sender {
    tint = (int16_t)[sender integerValue];
    [self.tintSliderValue setIntValue:tint];
    [self wbUpdate];
}

- (IBAction)lutSelectUpdate:(id)sender {
    lut = [sender indexOfSelectedItem];
    [self lutUpdate];
}

- (IBAction)lutEnableUpdate:(id)sender {
    lutEnabled = [sender integerValue];
    [self lutUpdate];
}

- (IBAction)assistEnableUpdate:(id)sender {
    assistEnabled = [sender integerValue];
    [self assistUpdate];
}

- (IBAction)falseEnableUpdate:(id)sender {
    falseEnabled = [sender integerValue];
    [self assistUpdate];
}

- (IBAction)zebraEnableUpdate:(id)sender {
    zebraEnabled = [sender integerValue];
    [self assistUpdate];
}

- (IBAction)overlayEnableUpdate:(id)sender {
    overlayEnabled = [sender integerValue];
    [self overlayUpdate];
}

- (IBAction)zoomRockerUpdate:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    if (event.type == NSLeftMouseUp) {
        [sender setFloatValue:0.0];
    }

    double rockerValue = [sender floatValue];
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  0,                    // Group (Lens)
                                                  9,                    // Parameter (Zoom Speed)
                                                  1,                    // Array length
                                                  &rockerValue
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send zoom rocker");
    }
}

- (IBAction)doMemA:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];

    if (event.type == NSLeftMouseDown) {
        [_memA sendActionOn:NSEventMaskLeftMouseUp];
        memATimer = [NSDate timeIntervalSinceReferenceDate];
    }
    if (event.type == NSLeftMouseUp) {
        [_memA sendActionOn:NSEventMaskLeftMouseDown];
        memATimer = [NSDate timeIntervalSinceReferenceDate] - memATimer;
        if (memATimer < 3) {
            focus = memASettings[0];
            iris = memASettings[1];
            shutter = (int32_t)memASettings[2];
            gain = (int8_t)memASettings[3];
            kelvin = (int16_t)memASettings[4];
            tint = (int16_t)memASettings[5];
            [self updateAll];
        }
        else {
            memASettings[0] = focus;
            memASettings[1] = iris;
            memASettings[2] = shutter;
            memASettings[3] = gain;
            memASettings[4] = kelvin;
            memASettings[5] = tint;
        }
    }
}

- (IBAction)doMemB:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if (event.type == NSLeftMouseDown) {
        [_memB sendActionOn:NSEventMaskLeftMouseUp];
        memBTimer = [NSDate timeIntervalSinceReferenceDate];
    }
    if (event.type == NSLeftMouseUp) {
        [_memB sendActionOn:NSEventMaskLeftMouseDown];
        memBTimer = [NSDate timeIntervalSinceReferenceDate] - memBTimer;
        if (memBTimer < 3) {
            focus = memBSettings[0];
            iris = memBSettings[1];
            shutter = (int32_t)memBSettings[2];
            gain = (int8_t)memBSettings[3];
            kelvin = (int16_t)memBSettings[4];
            tint = (int16_t)memBSettings[5];
            [self updateAll];
        }
        else {
            memBSettings[0] = focus;
            memBSettings[1] = iris;
            memBSettings[2] = shutter;
            memBSettings[3] = gain;
            memBSettings[4] = kelvin;
            memBSettings[5] = tint;
        }
    }
}

- (IBAction)doMemC:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if (event.type == NSLeftMouseDown) {
        [_memC sendActionOn:NSEventMaskLeftMouseUp];
        memCTimer = [NSDate timeIntervalSinceReferenceDate];
    }
    if (event.type == NSLeftMouseUp) {
        [_memC sendActionOn:NSEventMaskLeftMouseDown];
        memCTimer = [NSDate timeIntervalSinceReferenceDate] - memCTimer;
        if (memCTimer < 3) {
            focus = memCSettings[0];
            iris = memCSettings[1];
            shutter = (int32_t)memCSettings[2];
            gain = (int8_t)memCSettings[3];
            kelvin = (int16_t)memCSettings[4];
            tint = (int16_t)memCSettings[5];
            [self updateAll];
        }
        else {
            memCSettings[0] = focus;
            memCSettings[1] = iris;
            memCSettings[2] = shutter;
            memCSettings[3] = gain;
            memCSettings[4] = kelvin;
            memCSettings[5] = tint;
        }
    }
}

- (IBAction)doMemD:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if (event.type == NSLeftMouseDown) {
        [_memD sendActionOn:NSEventMaskLeftMouseUp];
        memDTimer = [NSDate timeIntervalSinceReferenceDate];
    }
    if (event.type == NSLeftMouseUp) {
        [_memD sendActionOn:NSEventMaskLeftMouseDown];
        memDTimer = [NSDate timeIntervalSinceReferenceDate] - memDTimer;
        if (memDTimer < 3) {
            focus = memDSettings[0];
            iris = memDSettings[1];
            shutter = (int32_t)memDSettings[2];
            gain = (int8_t)memDSettings[3];
            kelvin = (int16_t)memDSettings[4];
            tint = (int16_t)memDSettings[5];
            [self updateAll];
        }
        else {
            memDSettings[0] = focus;
            memDSettings[1] = iris;
            memDSettings[2] = shutter;
            memDSettings[3] = gain;
            memDSettings[4] = kelvin;
            memDSettings[5] = tint;
        }
    }
}

- (IBAction)doMemE:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    
    if (event.type == NSLeftMouseDown) {
        [_memE sendActionOn:NSEventMaskLeftMouseUp];
        memETimer = [NSDate timeIntervalSinceReferenceDate];
    }
    if (event.type == NSLeftMouseUp) {
        [_memE sendActionOn:NSEventMaskLeftMouseDown];
        memETimer = [NSDate timeIntervalSinceReferenceDate] - memETimer;
        if (memETimer < 3) {
            focus = memESettings[0];
            iris = memESettings[1];
            shutter = (int32_t)memESettings[2];
            gain = (int8_t)memESettings[3];
            kelvin = (int16_t)memESettings[4];
            tint = (int16_t)memESettings[5];
            [self updateAll];
        }
        else {
            memESettings[0] = focus;
            memESettings[1] = iris;
            memESettings[2] = shutter;
            memESettings[3] = gain;
            memESettings[4] = kelvin;
            memESettings[5] = tint;
        }
    }
}

- (IBAction)openSwitcherWindow:(id)sender {
    [self.switcherWindow setIsVisible:YES];
}

- (IBAction)focusNearer:(id)sender {
    focus -= 0.01;
    if (focus < 0.0) {
        focus = 0.0;
    }
    [self.focusSliderValue setFloatValue:focus];
    [self.focusFieldValue setFloatValue:focus];
    [self focusUpdate];
}

- (IBAction)focusFurther:(id)sender {
    focus += 0.01;
    if (focus > 1.0) {
        focus = 1.0;
    }
    [self.focusSliderValue setFloatValue:focus];
    [self.focusFieldValue setFloatValue:focus];
    [self focusUpdate];
}

- (IBAction)setIpAddress:(id)sender {
    switcherIP = [[sender stringValue] mutableCopy];
    NSRunAlertPanel(@"Please relaunch", @"Application must be relaunched for new IP address.", @"OK", nil, nil);
}

- (IBAction)openGradingWindow:(id)sender {
    [self.gradingWindow setIsVisible:YES];
}

- (IBAction)gradeGainUpdate:(id)sender {
    gradeGain = [sender floatValue];
    [self.gradeGainField setFloatValue:gradeGain];
    [self.gradeGainSlider setFloatValue:gradeGain];
    [self sendGain];
}

- (IBAction)gradeLiftUpdate:(id)sender {
    gradeLift = [sender floatValue];
    [self.gradeLiftField setFloatValue:gradeLift];
    [self.gradeLiftSlider setFloatValue:gradeLift];
    [self sendLift];
}

- (IBAction)gradeGammaUpdate:(id)sender {
    gradeGamma = [sender floatValue];
    [self.gradeGammaField setFloatValue:gradeGamma];
    [self.gradeGammaSlider setFloatValue:gradeGamma];
    [self sendGamma];
}

- (IBAction)gradeSatUpdate:(id)sender {
    gradeSat = [sender floatValue];
    [self.gradeSatField setFloatValue:gradeSat];
    [self.gradeSatSlider setFloatValue:gradeSat];
    [self sendSat];
}

- (void) sendLift {
    double gradeLiftValues[] = {gradeLift, gradeLift, gradeLift, gradeLift};
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  8,                    // Group (Color Correction)
                                                  0,                    // Parameter (Lift)
                                                  4,                    // Array length
                                                  &gradeLiftValues[0]
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send grade lift");
    }
}

- (void) sendGamma {
    double gradeGammaValues[] = {gradeGamma, gradeGamma, gradeGamma, gradeGamma};
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  8,                    // Group (Color Correction)
                                                  1,                    // Parameter (Gamma)
                                                  4,                    // Array length
                                                  &gradeGammaValues[0]
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send grade gamma");
    }
}

- (void) sendGain {
    double gradeGainValues[] = {gradeGain, gradeGain, gradeGain, gradeGain};
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  8,                    // Group (Color Correction)
                                                  2,                    // Parameter (Gain)
                                                  4,                    // Array length
                                                  &gradeGainValues[0]
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send grade gain");
    }
}

- (void) sendSat {
    double gradeSatValues[] = {0.0, gradeSat};
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  8,                    // Group (Color Correction)
                                                  6,                    // Parameter (Color)
                                                  2,                    // Array length
                                                  &gradeSatValues[0]
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send grade sat");
    }
}

- (void) focusUpdate {
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  0,                    // Group (Lens)
                                                  0,                    // Parameter (Focus)
                                                  1,                    // Array length
                                                  &focus
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send focus");
    }
}


- (void) irisUpdate {
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  0,                    // Group (Lens)
                                                  3,                    // Parameter (Iris)
                                                  1,                    // Array length
                                                  &iris
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send iris");
    }
}

- (void) zoomUpdate {
    HRESULT result = cameraControl->SetFloats    (
                                                  kCameraAddress,       // Camera number
                                                  0,                    // Group (Lens)
                                                  8,                    // Parameter (Zoom)
                                                  1,                    // Array length
                                                  &zoom
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send zoom");
    }
}

- (void) shutterUpdate {
    HRESULT result = cameraControl->SetInt32s    (
                                                  kCameraAddress,       // Camera number
                                                  1,                    // Group (Video)
                                                  11,                   // Parameter (Shutter angle)
                                                  1,                    // Array length
                                                  &shutter
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send shutter");
    }
}

- (void) gainUpdate {
    HRESULT result = cameraControl->SetInt8s    (
                                                  kCameraAddress,       // Camera number
                                                  1,                    // Group (Video)
                                                  13,                   // Parameter (Gain)
                                                  1,                    // Array length
                                                  &gain
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send gain");
    }
}

- (void) wbUpdate {
    int16_t whiteBalance[] = {kelvin, tint};
    HRESULT result = cameraControl->SetInt16s    (
                                          kCameraAddress,       // Camera number
                                          1,                    // Group (Video)
                                          2,                    // Parameter (WB)
                                          2,                    // Array length
                                          &whiteBalance[0]
                                          );
    if (result != S_OK)
    {
        NSLog(@"Failed to send white balance");
    }
}

- (void) lutUpdate {
    int8_t lutValues[] = {lut, lutEnabled};
    HRESULT result = cameraControl->SetInt8s    (
                                                 kCameraAddress,       // Camera number
                                                 1,                    // Group (Video)
                                                 15,                   // Parameter (LUT)
                                                 2,                    // Array length
                                                 &lutValues[0]
                                                 );
    if (result != S_OK)
    {
        NSLog(@"Failed to send LUT");
    }
}

- (void) assistUpdate {
    int16_t assistValues = zebraEnabled + (assistEnabled * 2) + (falseEnabled * 4);
    HRESULT result = cameraControl->SetInt16s    (
                                                 kCameraAddress,       // Camera number
                                                 4,                    // Group (Display)
                                                 1,                    // Parameter (Assist Tools)
                                                 1,                    // Array length
                                                 &assistValues
                                                 );
    if (result != S_OK)
    {
        NSLog(@"Failed to send Assist");
    }
}

- (void) overlayUpdate {
    HRESULT result = cameraControl->SetInt16s    (
                                                  kCameraAddress,       // Camera number
                                                  3,                    // Group (Output)
                                                  0,                    // Parameter (Overlay)
                                                  1,                    // Array length
                                                  &overlayEnabled
                                                  );
    if (result != S_OK)
    {
        NSLog(@"Failed to send Overlay");
    }
}

@end
