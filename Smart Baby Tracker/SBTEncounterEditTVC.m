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

// we are either editing an existing encounter or creating a new one
// so if we are not handed one, we create a new one first, the n modify it as we go along

@interface SBTEncounterEditTVC ()
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
}

- (IBAction)cancelEditing:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveEncounter:(id)sender {
    
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
    self.dateLabel.text = [df stringFromDate:self.encounter.dateComps.date];
    self.weightField2.text = [NSString stringWithFormat:@"%0.2f", [SBTUnitsConvertor displayUnitsOf:self.encounter.weight forKey:MASS_UNIT_KEY]];
    double len = self.encounter.length + self.encounter.height;  // one will be zero
    self.heightField.text = [NSString stringWithFormat:@"%1.2f", [SBTUnitsConvertor displayUnitsOf:len forKey:LENGTH_UNIT_KEY]];
    self.headCircField.text = [NSString stringWithFormat:@"%1.2f", [SBTUnitsConvertor displayUnitsOf:self.encounter.headCirc forKey:LENGTH_UNIT_KEY]];
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


@end
