//
//  SBTEncounterEditTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounterEditTVC.h"
#import "SBTEncounter.h"
#import "SBTUnitsConvertor.h"
#import "SBTVaccinesGivenTVC.h"
#import "SBTBaby.h"

// we are either editing an existing encounter or creating a new one
// so if we are not handed one, we create a new one first, then modify it as we go along

@interface SBTEncounterEditTVC ()<SBTVaccinesGivenTVCDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *weightField2;
@property (weak, nonatomic) IBOutlet UITextField *weightField1;
@property (weak, nonatomic) IBOutlet UILabel *poundsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;
@property (weak, nonatomic) IBOutlet UITextField *heightField;
@property (weak, nonatomic) IBOutlet UILabel *heightUnitLabel;
@property (weak, nonatomic) IBOutlet UITextField *headCircField;
@property (weak, nonatomic) IBOutlet UILabel *headCircUnitLabel;
@property (weak, nonatomic) IBOutlet UIButton *heightMethodButton;

@end

@implementation SBTEncounterEditTVC
{
    NSDateFormatter *df;
    SBTEncounter *originalEncounter;
}


#pragma mark - Target/Action
- (IBAction)changeLengthUnitLongPress:(UILongPressGestureRecognizer *)sender {
    UIMenuController *mc = [UIMenuController sharedMenuController];
    UIMenuItem *standardItem = [[UIMenuItem alloc] initWithTitle:K_INCHES action:@selector(standardLengthUnits:)];
    UIMenuItem *metricItem = [[UIMenuItem alloc] initWithTitle:K_CENTIMETERS action:@selector(metricLengthUnits:)];
    mc.menuItems = @[standardItem, metricItem];
    [mc update];
    [mc setTargetRect:sender.view.frame inView:sender.view.superview];
    [mc setMenuVisible:YES animated:YES];
    [sender.view becomeFirstResponder];
}

- (IBAction)changeMassUnitLongPress:(UILongPressGestureRecognizer *)sender {
    UIMenuController *mc = [UIMenuController sharedMenuController];
    UIMenuItem *standardItem = [[UIMenuItem alloc] initWithTitle:K_POUNDS action:@selector(standardMassUnits:)];
    UIMenuItem *metricItem = [[UIMenuItem alloc] initWithTitle:K_KILOGRAMS action:@selector(metricMassUnits:)];
    mc.menuItems = @[standardItem, metricItem];
    [mc update];
    [mc setTargetRect:sender.view.frame inView:sender.view.superview];
    [mc setMenuVisible:YES animated:YES];
    [sender.view becomeFirstResponder];
}

- (IBAction)changeHCUnitLongPress:(UILongPressGestureRecognizer *)sender {
    UIMenuController *mc = [UIMenuController sharedMenuController];
    UIMenuItem *standardItem = [[UIMenuItem alloc] initWithTitle:K_INCHES action:@selector(standardHCUnits:)];
    UIMenuItem *metricItem = [[UIMenuItem alloc] initWithTitle:K_CENTIMETERS action:@selector(metricHCUnits:)];
    mc.menuItems = @[standardItem, metricItem];
    [mc update];
    [mc setTargetRect:sender.view.frame inView:sender.view.superview];
    [mc setMenuVisible:YES animated:YES];
    [sender.view becomeFirstResponder];
}


-(void)standardLengthUnits:(id)sender
{
    [SBTUnitsConvertor setPreferredUnit:K_INCHES forKey:LENGTH_UNIT_KEY];
    [self updateDisplay];
}

-(void)standardMassUnits:(id)sender
{
    [SBTUnitsConvertor setPreferredUnit:K_POUNDS forKey:MASS_UNIT_KEY];
    [self updateDisplay];
}

-(void)standardHCUnits:(id)sender
{
    [SBTUnitsConvertor setPreferredUnit:K_INCHES forKey:HC_UNIT_KEY];
    [self updateDisplay];
}

-(void)metricLengthUnits:(id)sender
{
    [SBTUnitsConvertor setPreferredUnit:K_CENTIMETERS forKey:LENGTH_UNIT_KEY];
    [self updateDisplay];
}

-(void)metricMassUnits:(id)sender
{
    [SBTUnitsConvertor setPreferredUnit:K_KILOGRAMS forKey:MASS_UNIT_KEY];
    [self updateDisplay];
}

-(void)metricHCUnits:(id)sender
{
    [SBTUnitsConvertor setPreferredUnit:K_CENTIMETERS forKey:HC_UNIT_KEY];
    [self updateDisplay];
}

- (IBAction)toggleLinearMeasurementMethod:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"Recumbent", @"Description of supine measurement.")]){
        [sender setTitle:NSLocalizedString(@"Standing", @"Description of standing measurement.") forState:UIControlStateNormal];
    }else{
        [sender setTitle:NSLocalizedString(@"Recumbent", @"Description of supine measurement.") forState:UIControlStateNormal];
    }
}

- (IBAction)cancelEditing:(id)sender {
    //revert to the old values
    SBTEncounter *enc = self.encounter;
    enc.weight = originalEncounter.weight;
    if (originalEncounter.height != 0.0) enc.height = originalEncounter.height;
    if (originalEncounter.length != 0.0) enc.length = originalEncounter.length;
    enc.headCirc = originalEncounter.headCirc;
    enc.universalDate = originalEncounter.universalDate;
    [enc replaceVaccines:[NSSet setWithArray:[originalEncounter vaccinesGiven]]];
    [self.delegate SBTEncounterEditTVC:self updatedEncounter:enc];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveEncounter:(id)sender {
    self.encounter.universalDate = self.datePicker.date;
    if ([[SBTUnitsConvertor preferredUnitForKey:MASS_UNIT_KEY] isEqualToString:K_POUNDS]){
        self.encounter.weight = [self weightFromPoundAndOunces];
    }else{
        self.encounter.weight = [SBTUnitsConvertor metricStandardOf:[self.weightField2.text doubleValue] forKey:MASS_UNIT_KEY];
    }
    NSString *method = self.heightMethodButton.titleLabel.text;
    if ([method isEqualToString:NSLocalizedString(@"Recumbent", @"Description of supine measurement.")]){
        self.encounter.length = [SBTUnitsConvertor metricStandardOf:[self.heightField.text doubleValue] forKey:LENGTH_UNIT_KEY];
    }else{
        self.encounter.height = [SBTUnitsConvertor metricStandardOf:[self.heightField.text doubleValue] forKey:LENGTH_UNIT_KEY];
    }
    self.encounter.headCirc = [SBTUnitsConvertor metricStandardOf:[self.headCircField.text doubleValue] forKey:HC_UNIT_KEY];
    [self.delegate SBTEncounterEditTVC:self updatedEncounter:self.encounter];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 5);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View Life Cycle

-(void)updateDisplay
{
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    self.dateLabel.text = [df stringFromDate:self.datePicker.date];
    self.weightField2.text = [NSString stringWithFormat:@"%0.2f", [SBTUnitsConvertor displayUnitsOf:self.encounter.weight forKey:MASS_UNIT_KEY]];
    if (self.encounter.weight == 0.0) self.weightField2.text = @"";
    double len = self.encounter.length + self.encounter.height;  // one will be zero
    self.heightField.text = [NSString stringWithFormat:@"%1.1f", [SBTUnitsConvertor displayUnitsOf:len forKey:LENGTH_UNIT_KEY]];
    if (len == 0.0) self.heightField.text = @"";
    self.headCircField.text = [NSString stringWithFormat:@"%1.1f", [SBTUnitsConvertor displayUnitsOf:self.encounter.headCirc forKey:HC_UNIT_KEY]];
    if (self.encounter.headCirc == 0.0) self.headCircField.text = @"";
    NSString *method;
    if (self.encounter.length > 0.0){
        method = NSLocalizedString(@"Recumbent", @"Description of supine measurement.");
    }else{
        method = NSLocalizedString(@"Standing", @"Description of standing measurement.");
    }
    [self.heightMethodButton setTitle:method forState:UIControlStateNormal];
    self.weightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY];
    self.heightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY];
    self.headCircUnitLabel.text = [SBTUnitsConvertor displayStringForKey:HC_UNIT_KEY];
    if ([[SBTUnitsConvertor preferredUnitForKey:MASS_UNIT_KEY] isEqualToString:K_POUNDS]){
        double decimalPounds = [SBTUnitsConvertor displayUnitsOf:self.encounter.weight forKey:MASS_UNIT_KEY];
        if ([self.encounter.baby ageInDaysAtEncounter:self.encounter].day < AGE_SWITCH_TO_DECIMAL_POUNDS){
            [self.weightField1 setHidden:NO];
            [self.poundsLabel setHidden:NO];
            self.weightUnitLabel.text = K_OUNCES;
            double pounds = floor(decimalPounds);
            double fractionalPound = decimalPounds - pounds;
            double ounces = fractionalPound * 16.0;
            self.weightField1.text = [NSString stringWithFormat:@"%1.0f", pounds];
            self.weightField2.text = [NSString stringWithFormat:@"%1.1f", ounces];
        }else{
            [self.weightField1 setHidden:YES];
            self.weightField1.text = @"";
            [self.poundsLabel setHidden:YES];
            self.weightUnitLabel.text = K_POUNDS;
            self.weightField2.text = [NSString stringWithFormat:@"%1.2f", decimalPounds];
        }
    }else{
        [self.weightField1 setHidden:YES];
        self.weightField1.text = @"";
        [self.poundsLabel setHidden:YES];
        self.weightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY];
        self.weightField2.text = [NSString stringWithFormat:@"%1.2f", self.encounter.weight];
    }
}

-(double)weightFromPoundAndOunces
{
    double sum;
    if ([self.encounter.baby ageInDaysAtEncounter:self.encounter].day < AGE_SWITCH_TO_DECIMAL_POUNDS){
        sum = [SBTUnitsConvertor metricStandardOf:[self.weightField1.text doubleValue] forKey:MASS_UNIT_KEY];
        sum += [SBTUnitsConvertor metricStandardOf:[self.weightField2.text doubleValue]/16.0 forKey:MASS_UNIT_KEY];
    }else{
        sum = [SBTUnitsConvertor metricStandardOf:[self.weightField2.text doubleValue] forKey:MASS_UNIT_KEY];
    }
    return sum;
}

-(void)viewDidLoad
{
    originalEncounter = [self.encounter copy];
    df = [[NSDateFormatter alloc] init];
    df.calendar = [NSCalendar currentCalendar];
    if (!self.encounter){
        _encounter = [[SBTEncounter alloc] initWithDate:[NSDate date]];
        _encounter.baby = self.baby;
    }
    NSAssert(self.encounter.baby != nil, @"No valid baby passed to encounter editor.");
    self.weightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY];
    self.heightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY];
    self.headCircUnitLabel.text = [SBTUnitsConvertor displayStringForKey:HC_UNIT_KEY];
    self.datePicker.date = self.encounter.universalDate;
    [self updateDisplay];
}

#pragma mark - SBTVaccinesGivenTVCDelegate

-(void)vaccinesGivenTVC:(SBTVaccinesGivenTVC *)vaccinesGivenTVC updatedVaccines:(NSSet *)newVaccineSet
{
    [self.encounter replaceVaccines:newVaccineSet];
    [self.delegate SBTEncounterEditTVC:self updatedEncounter:self.encounter];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == self.heightField) {
        double stature = [SBTUnitsConvertor metricStandardOf:[textField.text doubleValue] forKey:LENGTH_UNIT_KEY];
        if ([self.heightMethodButton.titleLabel.text isEqualToString:NSLocalizedString(@"Recumbent", @"Description of supine measurement.")]){
            self.encounter.length = stature;
        }else{
            self.encounter.height = stature;
        }
    }else if (textField == self.weightField1 || textField == self.weightField2){
        double mass;
        if ([[SBTUnitsConvertor preferredUnitForKey:MASS_UNIT_KEY] isEqualToString:K_POUNDS]){
            mass = [self weightFromPoundAndOunces];
        }else{
            mass = [SBTUnitsConvertor metricStandardOf:[textField.text doubleValue] forKey:MASS_UNIT_KEY];
        }
        self.encounter.weight = mass;
    }else if (textField == self.headCircField){
        double FOC = [SBTUnitsConvertor metricStandardOf:[textField.text doubleValue] forKey:HC_UNIT_KEY];
        self.encounter.headCirc = FOC;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Vaccinations segue"]){
        SBTVaccinesGivenTVC *dest = segue.destinationViewController;
        dest.vaccinesGiven = [NSMutableSet setWithArray:[self.encounter vaccinesGiven]];
        dest.delegate = self;
    }
}

@end
