//
//  SBTBabyEditViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTBabyEditViewController.h"
#import "SBTEncounterEditTVC.h"
#import "SBTEncounter.h"
#import "SBTUnitsConvertor.h"
#import "SBTBaby.h"
#import "NSDateComponents+Today.h"

#define BIRTH_TIME_ROW 2
#define BIRTH_DATA_ROW 1
#define DUE_DATE_ROW 4
#define DATE_PICKER_HEIGHT 219.0F

@interface SBTBabyEditViewController ()<UITextFieldDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SBTEncounterEditTVCDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *babyPic;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UILabel *dobLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *headCircLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *dueDatePicker;
@property (nonatomic, strong) UIPopoverController *popCon;

@property (strong, nonatomic) SBTEncounter *birthEncounter;
@end

@implementation SBTBabyEditViewController
{
    UIImage *image;
    
    BOOL editingBirthTime;
    BOOL editingDueDate;
    NSDate *tempDOB;
    NSDate *tempBirthTime;
    NSString *tempName;
    NSDateComponents *dobComponentsMMDDYYYY;
    NSDateComponents *birthTimeHHMM;
    NSDateFormatter *df;
    NSNumberFormatter *nf;
}

// wait until the last minute to create the new baby and send it back to the delegate.
// this is complicated with the combination of the birth encounter and the birth time picker.  They have to coordinate.
// First of all, EVERY BABY has to have a birth encounter. It can be edited but NEVER DELETED. It will be encounter[0].
// Once a baby is created, you can change the DOB (who is really going to get their own baby's DOB wrong?),
// BUT you cannot change it to a date that occurs after another existing encounter.  This is just wrong.

// when entering this edit view controller, if there is an existing baby, then the birthTimePicker can be set to the baby's DOB,
// which will correctly set the time.  Otherwise it will be set to [NSDate date].
// when saving the baby, we extract only the hours + minutes from the timePicker, and add it to the DOBComponents.
// then we set it back on the birth encounter, and on the baby itself, and notify the delegate that we changed the baby.

- (IBAction)pressedDone:(id)sender {
    // add the birth time to the DOB from the birth encounter
    
    // by stripping out only the hours and minutes from the timePicker, I do not care what day it is set to.
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    birthTimeHHMM = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.birthTimePicker.date];
    
    // now I take only the day of the birthday, ignoring any previous birth time, setting the new birth time on it.
    unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear;
    dobComponentsMMDDYYYY = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.birthEncounter.universalDate];
    NSDate *newDOB = [[NSCalendar currentCalendar] dateFromComponents:dobComponentsMMDDYYYY];
    NSDate *newUniversalDOB = [[NSCalendar currentCalendar] dateByAddingComponents:birthTimeHHMM toDate:newDOB options:0];
    
    // now that I have added the hours and minutes to the birth encounter day, I will set the full date back on the encounter
    self.birthEncounter.universalDate = newUniversalDOB;
    
    SBTBaby *newBaby;
    if ([self.nameField.text isEqualToString:@""]){
        [self pressedCancel:self];
    }else{
        if (self.baby){ // this means I am editing an existing SBTBaby *
            newBaby = [self.baby copyWithNewName:self.nameField.text andDOB:self.birthEncounter.universalDate];
        }else{
            newBaby = [[SBTBaby alloc] initWithName:self.nameField.text andDOB:self.birthEncounter.universalDate];
        }
        BOOL success = [newBaby replaceBirthEncounterWithEncounter:self.birthEncounter];
        if (!success){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change failed"
                                                                message:@"Attempting to put birth date after existing encounters."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
            [alertView show];
        }else{
            newBaby.gender = (SBTGender)self.genderControl.selectedSegmentIndex;
            newBaby.thumbnail = image ? image : self.baby.thumbnail;
            // unitFlags is still MMDDYYYY
            newBaby.dueDate = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.dueDatePicker.date];
            [self.delegate babyEditor:self didSaveBaby:newBaby];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)pressedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takeBabyPic:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else{
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    [imagePicker setDelegate:self];
    if (self.popCon) {
        [self.popCon dismissPopoverAnimated:YES];
        self.popCon = nil;
        return;
    }
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        popover.delegate = self;
        self.popCon = popover;
        [popover presentPopoverFromBarButtonItem:self.cameraButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self presentViewController:imagePicker animated:YES completion:nil];
    }

}

#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == BIRTH_TIME_ROW || indexPath.row == DUE_DATE_ROW || indexPath.row == BIRTH_DATA_ROW){
        return YES;
    }else{
        return NO;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == BIRTH_TIME_ROW + 1){
        return editingBirthTime ? DATE_PICKER_HEIGHT : 0.0;
    }else if(indexPath.row == DUE_DATE_ROW + 1){
        return editingDueDate ? DATE_PICKER_HEIGHT : 0.0;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == BIRTH_TIME_ROW) {
        editingBirthTime = !editingBirthTime;
        editingDueDate = NO;
        [self.dueDatePicker setHidden:YES];
        if (!editingBirthTime){ // STOP editing, and store the birth time
            [self.birthTimePicker setHidden:YES];
            df.timeStyle = NSDateFormatterShortStyle;
            df.dateStyle = NSDateFormatterNoStyle;
            self.birthTimeLabel.text = [df stringFromDate:self.birthTimePicker.date];
            tempBirthTime = self.birthTimePicker.date;
        }else{ // YES editing birth time now
            if (self.birthEncounter){
                [self.birthTimePicker setDate:self.birthEncounter.universalDate];
            }else{
                [self.birthTimePicker setDate:tempBirthTime ? tempBirthTime : [NSDate date]];
            }
            [self.birthTimePicker setHidden:NO];
        }
    }else if(indexPath.row == DUE_DATE_ROW) {
        editingDueDate = !editingDueDate;
        editingBirthTime = NO;
        [self.birthTimePicker setHidden:YES];
        if (!editingDueDate){
            [self.dueDatePicker setHidden:YES];
            df.timeStyle = NSDateFormatterNoStyle;
            df.dateStyle = NSDateFormatterMediumStyle;
            self.dueDateLabel.text = [df stringFromDate:self.dueDatePicker.date];
            NSCalendarUnit unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear;
            self.baby.dueDate = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.dueDatePicker.date];
            self.baby.dueDate.calendar = [NSCalendar currentCalendar];
        }else{
            [self.dueDatePicker setHidden:NO];
        }
    }
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView reloadData];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"birthEncounterSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - UIPopoverController Delegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popCon = nil;
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [self reducedSizeImage: info[UIImagePickerControllerOriginalImage]];
        
    if (self.popCon) {
        [self.popCon dismissPopoverAnimated:YES];
        self.popCon = nil;
    }else{
        [self dismissViewControllerAnimated:YES completion:self.dismissBlock];
    }
    [self updateDisplay];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.popCon) {
        [self.popCon dismissPopoverAnimated:YES];
        self.popCon = nil;
    }else{
        [self dismissViewControllerAnimated:YES completion:self.dismissBlock];
    }
}

-(UIImage *)reducedSizeImage:(UIImage *)largeImage
{
    CGSize origImageSize = [largeImage size];
    
    CGRect newRect = CGRectMake(0, 0, THUMBNAIL_DIMENSION, THUMBNAIL_DIMENSION);
    CGFloat ratio = MAX(newRect.size.width / origImageSize.width,
                        newRect.size.height / origImageSize.height);
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    [path addClip];
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    [largeImage drawInRect:projectRect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //    NSData *data = UIImagePNGRepresentation(image);
    
    UIGraphicsEndImageContext();
    
    return smallImage;
}


#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    tempName = textField.text;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertViewCancel:(UIAlertView *)alertView
{
    // do nothing so far
}

#pragma mark - SBTEncounterEditTVCDelegate

-(void)SBTEncounterEditTVC:(SBTEncounterEditTVC *)editTVC updatedEncounter:(SBTEncounter *)encounter
{
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterShortStyle;
    self.dobLabel.text = [df stringFromDate:encounter.universalDate];
    tempDOB = encounter.universalDate;
    NSString *units = [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY];
    NSString *buildString;
    if ([SBTUnitsConvertor displayPounds]){
        SBTImperialWeight wt = [SBTUnitsConvertor imperialWeightForMass:encounter.weight];
        buildString = [NSString stringWithFormat:@"%ld %@ %1.1f oz", (long)wt.pounds, units, wt.ounces];
    }else{
        buildString = [NSString stringWithFormat:@"%1.2f %@", encounter.weight, units];
    }
    self.birthWeightLabel.text = buildString;
    
    units = [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY];
    double len = [SBTUnitsConvertor displayUnitsOf:encounter.length forKey:LENGTH_UNIT_KEY];
    buildString = [NSString stringWithFormat:@"%1.1f %@", len, units];
    self.birthLengthLabel.text = buildString;
    
    units = [SBTUnitsConvertor displayStringForKey:HC_UNIT_KEY];
    double hc = [SBTUnitsConvertor displayUnitsOf:encounter.headCirc forKey:HC_UNIT_KEY];
    buildString = [NSString stringWithFormat:@"%1.1f %@", hc, units];
    self.headCircLabel.text = buildString;

    BOOL success = [self.baby replaceBirthEncounterWithEncounter:[encounter copy]];
    if (success) {
        self.birthEncounter = [encounter copy];
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editBirthEncounter"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTEncounterEditTVC *dest = [nav.viewControllers firstObject];
        dest.delegate = self;
        dest.baby = self.baby;
        dest.editingBirthData = YES;
        if ([self.baby.encountersList count]) {
            dest.encounter = self.baby.encountersList[0];
        }
        [dest setTitle:@"Birth Encounter"];
    }
}

#pragma mark - View Controller Life Cycle

-(void)updateDisplay
{
    if (self.baby){
        tempBirthTime = self.baby.DOB;
        tempDOB = self.baby.DOB;
        self.title = self.baby.name;
        self.nameField.text = tempName ? tempName : self.baby.name;
        self.babyPic.image = self.baby.thumbnail;
        [self.birthTimePicker setDate:self.baby.DOB];
        if (self.baby.dueDate){
            NSCalendar *cal = self.baby.dueDate.calendar ? self.baby.dueDate.calendar : [NSCalendar currentCalendar];
            [self.dueDatePicker setDate:[cal dateFromComponents:self.baby.dueDate]];
        }else{
            [self.dueDatePicker setDate:self.baby.DOB];
        }
        [self.genderControl setSelectedSegmentIndex:self.baby.gender];
        if (self.birthEncounter){  // this was set in viewWillAppear
            double len = [SBTUnitsConvertor displayUnitsOf:self.birthEncounter.length + self.birthEncounter.height forKey:LENGTH_UNIT_KEY];
            NSString *units = [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY];
            self.birthLengthLabel.text = [NSString stringWithFormat:@"%1.1f %@", len, units];
            
            SBTImperialWeight impWt = [SBTUnitsConvertor imperialWeightForMass:self.birthEncounter.weight];
            NSString *displayString;
            if ([SBTUnitsConvertor displayPounds]){
                displayString = [NSString stringWithFormat:@"%ld lbs %1.1f oz", (long)impWt.pounds, impWt.ounces];
            }else{
                displayString = [NSString stringWithFormat:@"%1.2f %@", impWt.mass, [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY]];
            }
            self.birthWeightLabel.text = displayString;
            
            double hc = [SBTUnitsConvertor displayUnitsOf:self.birthEncounter.headCirc forKey:HC_UNIT_KEY];
            units = [SBTUnitsConvertor displayStringForKey:HC_UNIT_KEY];
            self.headCircLabel.text = [NSString stringWithFormat:@"%1.1f %@", hc, units];
        }
    }else{
        tempDOB = [NSDate date];
        tempBirthTime = tempDOB;
    }
    df.timeStyle = NSDateFormatterShortStyle;
    df.dateStyle = NSDateFormatterNoStyle;
    self.birthTimeLabel.text = [df stringFromDate:tempBirthTime];
    
    df.timeStyle = NSDateFormatterNoStyle;
    df.dateStyle = NSDateFormatterMediumStyle;
    self.dobLabel.text = [df stringFromDate:tempDOB];
    
    if (self.baby.dueDate){
        self.dueDateLabel.text = [df stringFromDate:self.dueDatePicker.date];
    }else{
        self.dueDateLabel.text = [df stringFromDate:self.baby.DOB];
    }

    if (image) self.babyPic.image = image;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
    df = [[NSDateFormatter alloc] init];
    df.calendar = [NSCalendar currentCalendar];
    nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    editingBirthTime = NO;
    editingDueDate = NO;

    if ([self.baby.encountersList count]){
        self.birthEncounter = [self.baby.encountersList firstObject];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dueDatePicker setHidden:YES];
    [self.birthTimePicker setHidden:YES];
    self.nameField.delegate = self;
    [self updateDisplay];
}

-(void)dealloc
{
    df = nil;
    nf = nil;
    self.birthEncounter = nil;
}

@end
