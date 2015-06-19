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

#pragma mark - Convenience methods

-(NSInteger)hexValueOf:(char)c{
    NSAssert(c >= 'A' && c <= 'F', @"Invalid hex character");
    return 10 + c - 'A';
}

-(char)hexCharacterFor:(NSInteger)i{
    NSAssert(i > 9 && i < 16, @"Invalid hex digit");
    return 'A' + i - 10;
}

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
    return _digits05;
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
            self.parameter = self.statureMethodControl.selectedSegmentIndex ? SBTStature : SBTLength;
            break;
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
    if (self.parameter == SBTWeight && self.unitsControl.selectedSegmentIndex != 0){
        // using pounds and possibly ounces
        // picker looks like ###.#lbs#.#oz
        //                   01234 5 678
        NSMutableString *s = [NSMutableString new];
        for (int i = 0; i < 5; i++){
            NSInteger idx = [self.picker selectedRowInComponent:i];
            [s appendString:self.pickComps[i][idx]];
        }
        double lbs = [s doubleValue];
        s = [NSMutableString string];
        for (int i = 6; i < 9; i++){
            NSInteger idx = [self.picker selectedRowInComponent:i];
            [s appendString:self.pickComps[i][idx]];
        }
        double ounceFraction = [s doubleValue] / 16.0;
        
        return lbs + ounceFraction;
    }else{
        NSMutableString *s = [NSMutableString new];
        for (int i = 0; i < [self.pickComps count]; i++){
            NSInteger idx = [self.picker selectedRowInComponent:i];
            [s appendString:self.pickComps[i][idx]];
        }
        return [s doubleValue];
    }
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
            // this is a horrible hack, and ugly one-off code
            if (self.measure == SBTWeight && i == 6){
                d = [(NSString *)(digs[i]) characterAtIndex:0] - '0';
            }
            [self.picker selectRow:d inComponent:i animated:YES];
        }
    }
    [self.picker reloadAllComponents];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return [self.pickComps count];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickComps[component] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickComps[component][row];
}

//-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
//    CGFloat def = self.view.bounds.size.width / [self numberOfComponentsInPickerView:pickerView];
//    if (self.parameter == SBTWeight && self.unitsControl.selectedSegmentIndex != 0){
//        def = self.view.bounds.size.width / ([self numberOfComponentsInPickerView:pickerView] );
//        if (component == 3 || component == 7){
//            def /= 2.0;
//        }
//    }
//    return def;
//}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // we are only dealing with pounds and ounces here
    if (self.parameter != SBTWeight) return;
    if (self.unitsControl.selectedSegmentIndex == 0) return;
    // we don't need to change anything if a zero is selected
    if (row == 0) return;
    
    // components look like ###.#lbs#.#oz
    //                      01234 5 678
    
    // if ounces are selected set the decimal fraction of the pounds to zero
    if (component == 6 || component == 8){
        [self.picker selectRow:0 inComponent:4 animated:YES];
    }
    // if decimal pounds are selected, set the ounces to zero
    if (component == 4){
        [self.picker selectRow:0 inComponent:6 animated:YES];
        [self.picker selectRow:0 inComponent:8 animated:YES];
    }
    
}

#pragma mark - View Life Cycle

-(void)setUpWeight{
    self.titleLabel.text = NSLocalizedString(@"Weight", @"Title for weight entry");
    [self.unitsControl setTitle:@"kg" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"lbs" forSegmentAtIndex:1];
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
        self.pickComps = @[self.digits02, self.digits09, self.digits09, self.decimal, self.digits09, @[@"lbs"], self.ounces, self.decimal, self.digits05, @[@"oz"]];
        NSInteger poundOrd = (int)measureInPrefUnits;
        double poundFrac = measureInPrefUnits - poundOrd;
        NSInteger ouncesOrd = (int)(poundFrac * 16);
        double ounceFrac = poundFrac * 16 - ouncesOrd;
        // round up or down the ounces
        if (ounceFrac < 0.25) ounceFrac = 0.0;
        if (ounceFrac >= 0.75){
            ounceFrac = 0.0;
            ouncesOrd += 1;
            if (ouncesOrd == 16){
                ouncesOrd = 0;
                poundOrd += 1;
            }
        }else{
            ounceFrac = 0.501; // just to be safe
        }
        // set up the picker
        [self.unitsControl setSelectedSegmentIndex:1];
        
        NSMutableString *build = [NSMutableString new];
        [build appendString:[NSString stringWithFormat:@"%03ld",poundOrd]];
        [build appendString:@".0#"];// the hashmark will have a zero value in the setPickerToValue method
        
        NSString *hexd = [NSString stringWithFormat:@"%ld", ouncesOrd];
        if (ouncesOrd > 9){
            char c = [self hexCharacterFor:ouncesOrd];
            hexd = [NSString stringWithFormat:@"%c", c];
        }
        [build appendString:hexd];
        // this hack uses a 1 to represent a half ounce because the "5" is in position 1 in the component array
        NSString *frac;
        if (ounceFrac >= 0.5){
            frac = @".1";
        }else{
            frac = @".0";
        }
        [build appendString:frac];
        measRep = [build copy];
    }
    //get the display digits for the measurement and set the picker
    [self setPickerToValue:measRep];
}

-(void)setUpStature{
    self.titleLabel.text = NSLocalizedString(@"Height/Length", @"Title for height/length entry");
    [self.unitsControl setTitle:@"cm" forSegmentAtIndex:0];
    [self.unitsControl setTitle:@"inch" forSegmentAtIndex:1];
    [self.statureMethodControl setSelectedSegmentIndex:(self.parameter == SBTStature) ? 1 : 0];
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
