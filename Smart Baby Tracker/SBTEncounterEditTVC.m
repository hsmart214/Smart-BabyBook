//
//  SBTEncounterEditTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 6/12/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounterEditTVC.h"
#import "SBTBaby.h"
#import "SBTEncounter.h"
#import "SBTUnitsConvertor.h"
#import "SBTAddScannedVaccinesTVC.h"
#import "SBTMeasurementEntryVC.h"
#import "SBTVaccineSchedule.h"
#import "SBTVaccine.h"

#define DATE_PICKER_ROW 1

@interface SBTEncounterEditTVC ()<SBTAddScannedVaccinesDelegate, SBTMeasurementReturnDelegate>

@property (strong, nonatomic) SBTEncounter *oldEncounter;
@property (strong, nonatomic) NSDateFormatter *df;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *encounterDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *statureLabel;
@property (weak, nonatomic) IBOutlet UILabel *headCircLabel;

@end

@implementation SBTEncounterEditTVC

#pragma mark - Target/Action

- (IBAction)encounterDateChanged:(UIDatePicker *)sender {
    [self.encounter setUniversalDate:sender.date];
    [self updateDisplay];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveEncounter:(id)sender {
    [self.delegate SBTEncounterEditTVC:self updatedEncounter:self.encounter];
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == DATE_PICKER_ROW){
        return 220.0;
    }else{
        return UITableViewAutomaticDimension;
    }
}

#pragma mark - SBTMeasurementReturnDelegate

-(void)measurementReturnDelegate:(id)delegate returnedMeasurement:(double)measurement forParameter:(SBTGrowthParameter)parameter{
    switch (parameter) {
        case SBTWeight:
            self.encounter.weight = measurement;
            break;
        case SBTLength:
            self.encounter.length = measurement;
            break;
        case SBTStature:
            self.encounter.height = measurement;
            break;
        case SBTHeadCircumference:
            self.encounter.headCirc = measurement;
            break;
        default:
            break;
    }
    [self updateDisplay];
}

#pragma mark - SBTAddScannedVaccinesDelegate

-(void)addScannedVaccinesTVC:(SBTAddScannedVaccinesTVC *)sender addedVaccines:(NSSet *)vaccines{
    [self.encounter replaceVaccines:vaccines];
}

-(BOOL)isTooYoungForVaccine:(SBTVaccine *)vaccine
{
    return [[SBTVaccineSchedule sharedSchedule] vaccine:vaccine tooEarlyForEncounter:self.encounter];
}

-(BOOL)isTooOldForVaccine:(SBTVaccine *)vaccine
{
    return [[SBTVaccineSchedule sharedSchedule] tooOldForVaccine:vaccine atEncounter:self.encounter];
}

-(BOOL)isExpiredVaccine:(SBTVaccine *)vaccine
{
    return [vaccine.expirationDate timeIntervalSinceDate:self.encounter.universalDate] > 0;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"Show Vaccine List"] || [segue.identifier isEqualToString:@"Scan Vaccine Bottle"]){
        SBTAddScannedVaccinesTVC *dest = segue.destinationViewController;
        dest.delegate = self;
        dest.currentVaccines = [[NSSet alloc] initWithArray:self.encounter.vaccinesGiven];
        dest.goStraightToCamera = [segue.identifier isEqualToString:@"Scan Vaccine Bottle"];
    }
    SBTMeasurementEntryVC *dest = segue.destinationViewController;
    dest.delegate = self;
    if ([segue.identifier isEqualToString:@"Obtain Weight"]){
        dest.parameter = SBTWeight;
        dest.measure = self.encounter.weight;
        dest.infant = self.encounter.ageInDays < AGE_SWITCH_TO_DECIMAL_POUNDS;
    }
    if ([segue.identifier isEqualToString:@"Obtain Stature"]){
        if (self.encounter.length == 0.0){
            dest.parameter = SBTStature;
            dest.measure = self.encounter.height;
        }else{
            dest.parameter = SBTLength;
            dest.measure = self.encounter.length;
        }
    }
    if ([segue.identifier isEqualToString:@"Obtain HC"]){
        dest.parameter = SBTHeadCircumference;
        dest.measure = self.encounter.headCirc;
    }
}

#pragma mark - View Life Cycle

-(void)updateDisplay{
    self.encounterDateLabel.text = [self.df stringFromDate:self.encounter.universalDate];
    self.weightLabel.text = [SBTUnitsConvertor formattedStringForMeasurement:self.encounter.weight forKey:MASS_UNIT_KEY];
    self.statureLabel.text = [SBTUnitsConvertor formattedStringForMeasurement:(self.encounter.height + self.encounter.length) forKey:LENGTH_UNIT_KEY];
    self.headCircLabel.text = [SBTUnitsConvertor formattedStringForMeasurement:self.encounter.headCirc forKey:LENGTH_UNIT_KEY];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.datePicker.date = self.encounter.universalDate;
    [self updateDisplay];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.df = [NSDateFormatter new];
    [self.df setTimeStyle:NSDateFormatterNoStyle];
    [self.df setDateStyle:NSDateFormatterShortStyle];
    if (!self.encounter){
        self.encounter = [SBTEncounter new];
        self.encounter.baby = self.baby;
        NSAssert(self.baby != nil, @"Asked for a new encounter without giving an SBTBaby");
        if (!self.title) self.title = @"New Encounter";
    }else{
        NSString *t = NSLocalizedString(@"Event", @"Encounter decription");
        if (!self.title) self.title = [NSString stringWithFormat:@"%@ %@", t, [self.df stringFromDate:self.encounter.universalDate]];
    }
    if (!self.baby){
        self.baby = self.encounter.baby;
    }
    // here we will allow setting the encounter earlier than the DOB to allow for changing the DOB itself
    if (!self.editingBirthData) [self.datePicker setMinimumDate:self.baby.DOB];
    [self.datePicker setMaximumDate:[NSDate date]];
}

-(void)dealloc{
    self.encounter = nil;
    self.oldEncounter = nil;
    self.df = nil;
}

@end
