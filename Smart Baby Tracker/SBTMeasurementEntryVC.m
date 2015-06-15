//
//  SBTMeasurementEntryVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 6/12/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTMeasurementEntryVC.h"
#import "SBTUnitsConvertor.h"

#define SUPINE 0
#define STANDING 1

@interface SBTMeasurementEntryVC ()<UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statureMethodControl;

@property (strong, nonatomic) NSArray *pickComps;

@property (strong, nonatomic) NSArray *digits09;
@property (strong, nonatomic) NSArray *digits17;
@property (strong, nonatomic) NSArray *digits02;
@property (strong, nonatomic) NSArray *digits05;
@property (strong, nonatomic) NSArray *decimal;

@end

@implementation SBTMeasurementEntryVC

#pragma mark - Lazy instantiation

-(NSArray *)decimal{
    if (!_decimal){
        _decimal = @[@"."];
    }
    return _decimal;
}

-(NSArray *)digits02{
    if (!_digits02){
        _digits02 = @[@"0", @"1", @"2"];
    }
    return _digits02;
}

-(NSArray *)digits05{
    if (!_digits05){
        _digits05 = @[@"0", @"5"];
    }
    return _digits02;
}

-(NSArray *)digits09{
    if (!_digits09){
        _digits09 = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    }
    return _digits09;
}

-(NSArray *)digits17{
    if (!_digits17){
        _digits17 = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7"];
    }
    return _digits17;
}

#pragma mark - Target/Action

- (IBAction)unitsChanged:(UISegmentedControl *)sender {
    
}
- (IBAction)changeStatureMeasurementMethod:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case SUPINE:
            self.parameter = SBTLength;
            break;
        case STANDING:
            self.parameter = SBTStature;
            break;
        default:
            break;
    }
}

- (IBAction)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    [self.delegate measurementReturnDelegate:self returnedMeasurement:self.measure forParameter:self.parameter];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPickerViewDatSource, UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return [self.pickComps count];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickComps[component] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickComps[component][row];
}

#pragma mark - View Life Cycle

-(void)setUpWeight{
    self.titleLabel.text = NSLocalizedString(@"Weight", @"Title for weight entry");
    [self.unitsControl setTitle:@"kg" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"lbs oz" forSegmentAtIndex:1];
    [self.unitsControl setTitle:@"lbs" forSegmentAtIndex:2];
    self.pickComps = @[self.digits02, self.digits09, self.digits09, self.decimal, self.digits09];
    [self.statureMethodControl setHidden:YES];
}

-(void)setUpStature{
    self.titleLabel.text = NSLocalizedString(@"Height/Length", @"Title for height/length entry");
    [self.unitsControl setTitle:@"cm" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"inch" forSegmentAtIndex:1];
    [self.unitsControl setTitle:@"ft in" forSegmentAtIndex:2];
}

-(void)setUpHC{
    self.titleLabel.text = NSLocalizedString(@"Head Circumference", @"Title for HC entry");
    [self.unitsControl setTitle:@"cm" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"inch" forSegmentAtIndex:1];
    [self.unitsControl setTitle:@"ft in" forSegmentAtIndex:2];
    [self.unitsControl setEnabled:NO forSegmentAtIndex:2];
    [self.statureMethodControl setHidden:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    switch (self.parameter) {
        case SBTWeight:
            [self setUpWeight];
            break;
        case SBTStature:
        case SBTLength:
            [self setUpStature];
            break;
        case SBTHeadCircumference:
            [self setUpHC];
            break;
        default:
            break;
    }
    [self.picker reloadAllComponents];
}

@end
