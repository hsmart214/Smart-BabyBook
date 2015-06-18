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
@property (strong, nonatomic) NSArray *ounces;

@property (strong, nonatomic) NSString *displayUnitKey;

@property (strong, nonatomic) NSNumberFormatter *nf;

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

-(NSArray *)ounces{
    if (!_ounces){
        _ounces = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15"];
    }
    return _ounces;
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
    NSString *key;
    switch (self.parameter) {
        case SBTWeight:
            key = MASS_UNIT_KEY;
            break;
        case SBTStature:
        case SBTLength:
            key = LENGTH_UNIT_KEY;
        case SBTHeadCircumference:
            key = HC_UNIT_KEY;
        default:
            break;
    }
    double retVal = [SBTUnitsConvertor convertMeasure:[self pickerValue] toMetricForKey:key];
    [self.delegate measurementReturnDelegate:self returnedMeasurement:retVal forParameter:self.parameter];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (double)pickerValue{
    NSMutableString *s = [NSMutableString new];
    for (int i = 0; i < [self.pickComps count]; i++){
        NSInteger idx = [self.picker selectedRowInComponent:i];
        [s appendString:self.pickComps[i][idx]];
    }
    return [s doubleValue];
}

-(void)setPickerToValue:(NSString *)measRep{
    NSMutableArray *digs = [NSMutableArray new];
    for (int i = 0; i < [measRep length]; i++){
        unichar c = [measRep characterAtIndex:i];
        [digs addObject: [NSString stringWithCharacters:&c length:1]];
    }
    if ([digs count] <= [self.pickComps count]){
        for (int i = 0; i < [digs count]; i++){
            NSInteger d = [digs[i] integerValue];  // this works for the decimal point as well!
            [self.picker selectRow:d inComponent:i animated:YES];
        }
    }
    [self.picker reloadAllComponents];
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
        [self.statureMethodControl setHidden:YES];
    //figure out the current preferred units
    double measureInPrefUnits = [SBTUnitsConvertor displayUnitsOf:self.measure forKey:MASS_UNIT_KEY];
    NSString *unit = [SBTUnitsConvertor preferredUnitForKey:MASS_UNIT_KEY];
    NSString *measRep;
    if ([unit isEqualToString:K_KILOGRAMS]){
        [self.unitsControl setSelectedSegmentIndex:0];
        //set the picker to the value
        if (self.isInfant){
            self.pickComps = @[self.digits09, self.digits09, self.decimal, self.digits09, self.digits09, @[@"kg"]];
            measRep = [NSString stringWithFormat:@"%05.2f", measureInPrefUnits];
        }else{
            self.pickComps = @[self.digits02, self.digits09, self.digits09, self.decimal, self.digits09, @[@"kg"]];
            measRep = [NSString stringWithFormat:@"%05.1f", measureInPrefUnits];
        }
        
    }else{// must be pounds or pounds/ounces
        NSInteger ord = (int)measureInPrefUnits;
        double dec = measureInPrefUnits - ord;
        if (self.isInfant){  //use pounds and ounces for infants by default
            // set up the picker
            [self.unitsControl setSelectedSegmentIndex:1];
            self.pickComps = @[self.digits02, self.digits09, @[@"lbs"], self.ounces, self.decimal, self.digits05, @[@"oz"]];
            NSString *ouncesRep = [NSString stringWithFormat:@"%03.1f", dec * 16];
            NSUInteger length = [ouncesRep length];
            NSUInteger decPlace;
            for (decPlace = 0; decPlace < length; decPlace++) {
                if ([ouncesRep characterAtIndex:decPlace] == '.'){
                    break;
                }
            }
        }else{// use deciml pounds
            [self.unitsControl setSelectedSegmentIndex:2];
            self.pickComps = @[self.digits02, self.digits09, self.digits09, self.decimal, self.digits09, @[@"lbs"]];
            measRep = [NSString stringWithFormat:@"%05.1f", measureInPrefUnits];
        }
    }
    //get the display digits for the measurement and set the picker
    [self setPickerToValue:measRep];
}

-(void)setUpStature{
    self.titleLabel.text = NSLocalizedString(@"Height/Length", @"Title for height/length entry");
    [self.unitsControl setTitle:@"cm" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"inch" forSegmentAtIndex:1];
    [self.unitsControl setTitle:@"ft in" forSegmentAtIndex:2];
    [self.unitsControl setEnabled:NO forSegmentAtIndex:2];
    //figure out the current preferred units
    double measureInPrefUnits = [SBTUnitsConvertor displayUnitsOf:self.measure forKey:LENGTH_UNIT_KEY];
    NSString *unit = [SBTUnitsConvertor preferredUnitForKey:LENGTH_UNIT_KEY];
    NSString *measRep;
    if ([unit isEqualToString:K_CENTIMETERS]){
        [self.unitsControl setSelectedSegmentIndex:0];
        self.pickComps = @[self.digits02, self.digits09, self.digits09, self.decimal, self.digits09, @[@"cm"]];
        measRep = [NSString stringWithFormat:@"%05.1f", measureInPrefUnits];
    }else{ // must be inches
        [self.unitsControl setSelectedSegmentIndex:1];
        self.pickComps = @[self.digits09, self.digits09, self.decimal, self.digits09, @[@"in"]];
        measRep = [NSString stringWithFormat:@"%04.1f", measureInPrefUnits];
    }
    //get the display digits for the measurement and set the picker
    [self setPickerToValue:measRep];
}

-(void)setUpHC{
    self.titleLabel.text = NSLocalizedString(@"Head Circumference", @"Title for HC entry");
    [self.unitsControl setTitle:@"cm" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"inch" forSegmentAtIndex:1];
    [self.unitsControl setTitle:@"ft in" forSegmentAtIndex:2];
    [self.unitsControl setEnabled:NO forSegmentAtIndex:2];
    [self.statureMethodControl setHidden:YES];
    //figure out the current preferred units
    double measureInPrefUnits = [SBTUnitsConvertor displayUnitsOf:self.measure forKey:HC_UNIT_KEY];
    NSString *unit = [SBTUnitsConvertor preferredUnitForKey:HC_UNIT_KEY];
    NSString *measRep;
    if ([unit isEqualToString:K_CENTIMETERS]){
        [self.unitsControl setSelectedSegmentIndex:0];
        self.pickComps = @[self.digits09, self.digits09, self.decimal, self.digits09, @[@"cm"]];
    }else{ // must be inches
        [self.unitsControl setSelectedSegmentIndex:1];
        self.pickComps = @[self.digits02, self.digits09, self.decimal, self.digits09, @[@"in"]];
    }
    measRep = [NSString stringWithFormat:@"%04.1f", measureInPrefUnits];
    //get the display digits for the measurement and set the picker
    [self setPickerToValue:measRep];
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

-(void)viewDidLoad{
    [super viewDidLoad];
    self.nf = [[NSNumberFormatter alloc] init];
}

-(void)dealloc{
    self.nf = nil;
    self.displayUnitKey = nil;
    self.pickComps = nil;
    self.digits02 = nil;
    self.digits05 = nil;
    self.digits09 = nil;
    self.digits17 = nil;
    self.decimal = nil;
    self.ounces = nil;
}

@end
