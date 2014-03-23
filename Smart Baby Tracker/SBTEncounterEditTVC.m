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

// we are either editing an existing encounter or creating a new one
// so if we are not handed one, we create a new one first, the n modify it as we go along

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

@property (nonatomic, strong) NSMutableSet *vaccines;
@end

@implementation SBTEncounterEditTVC
{
    NSDateFormatter *df;
}

-(NSMutableSet *)vaccines
{
    if (!_vaccines){
        if (self.encounter){
            _vaccines = [NSMutableSet setWithArray:[self.encounter vaccinesGiven]];
        }else{
            _vaccines = [NSMutableSet set];
        }
    }
    return _vaccines;
}

#pragma mark - Target/Action

- (IBAction)toggleLinearMeasurementMethod:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"Recumbent", @"Description of supine measurement.")]){
        [sender setTitle:NSLocalizedString(@"Standing", @"Description of standing measurement.") forState:UIControlStateNormal];
    }else{
        [sender setTitle:NSLocalizedString(@"Recumbent", @"Description of supine measurement.") forState:UIControlStateNormal];
    }
}

- (IBAction)cancelEditing:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveEncounter:(id)sender {
    self.encounter.universalDate = self.datePicker.date;
    self.encounter.weight = [SBTUnitsConvertor metricStandardOf:[self.weightField2.text doubleValue] forKey:MASS_UNIT_KEY];
    NSString *method = self.heightMethodButton.titleLabel.text;
    if ([method isEqualToString:NSLocalizedString(@"Recumbent", @"Description of supine measurement.")]){
        self.encounter.length = [SBTUnitsConvertor metricStandardOf:[self.heightField.text doubleValue] forKey:LENGTH_UNIT_KEY];
    }else{
        self.encounter.height = [SBTUnitsConvertor metricStandardOf:[self.heightField.text doubleValue] forKey:LENGTH_UNIT_KEY];
    }
    self.encounter.headCirc = [SBTUnitsConvertor metricStandardOf:[self.headCircField.text doubleValue] forKey:LENGTH_UNIT_KEY];
    [self.encounter replaceVaccines:self.vaccines];
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
    //TODO: Fix the display for lbs/oz and ft/in
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    self.dateLabel.text = [df stringFromDate:self.encounter.dateComps.date];
    self.weightField2.text = [NSString stringWithFormat:@"%0.2f", [SBTUnitsConvertor displayUnitsOf:self.encounter.weight forKey:MASS_UNIT_KEY]];
    if (self.encounter.weight == 0.0) self.weightField2.text = @"";
    double len = self.encounter.length + self.encounter.height;  // one will be zero
    self.heightField.text = [NSString stringWithFormat:@"%1.2f", [SBTUnitsConvertor displayUnitsOf:len forKey:LENGTH_UNIT_KEY]];
    if (len == 0.0) self.heightField.text = @"";
    self.headCircField.text = [NSString stringWithFormat:@"%1.2f", [SBTUnitsConvertor displayUnitsOf:self.encounter.headCirc forKey:LENGTH_UNIT_KEY]];
    if (self.encounter.headCirc == 0.0) self.headCircField.text = @"";
    NSString *method;
    if (self.encounter.length > 0.0){
        method = NSLocalizedString(@"Recumbent", @"Description of supine measurement.");
    }else{
        method = NSLocalizedString(@"Standing", @"Description of standing measurement.");
    }
    [self.heightMethodButton setTitle:method forState:UIControlStateNormal];
}

-(void)viewDidLoad
{
    NSAssert(self.baby != nil, @"No valid baby passed to encounter editor.");
    
    df = [[NSDateFormatter alloc] init];
    df.calendar = [NSCalendar currentCalendar];
    if (!self.encounter){
        _encounter = [[SBTEncounter alloc] initWithDate:[NSDate date]];
    }
    self.weightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY];
    self.heightUnitLabel.text = [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY];
    self.headCircUnitLabel.text = [SBTUnitsConvertor displayStringForKey:HC_UNIT_KEY];
    [self updateDisplay];
}

#pragma mark - SBTVaccinesGivenTVCDelegate

-(void)vaccinesGivenTVC:(SBTVaccinesGivenTVC *)vaccinesGivenTVC updatedVaccines:(NSSet *)newVaccineSet
{
    [self.encounter replaceVaccines:newVaccineSet];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
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
        dest.vaccinesGiven = self.vaccines;
        dest.delegate = self;
    }
}

@end
