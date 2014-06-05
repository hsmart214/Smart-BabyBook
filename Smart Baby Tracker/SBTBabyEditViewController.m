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

#define BIRTH_TIME_ROW 5
#define DATE_PICKER_HEIGHT 219.0F

@interface SBTBabyEditViewController ()<UITextFieldDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, SBTEncounterEditTVCDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *babyPic;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (weak, nonatomic) IBOutlet UILabel *dobLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *headCircLabel;
@property (nonatomic, strong) UIPopoverController *popCon;

@property (strong, nonatomic) SBTBaby *oldBaby;
@end

@implementation SBTBabyEditViewController
{
    UIImage *image;
    
    BOOL editingDOB;
    BOOL editingBirthTime;
    
    NSDate *tempDOB;
    NSDate *tempBirthTime;
    NSDateFormatter *df;
    NSNumberFormatter *nf;
}

// wait until the last minute to create the new baby and send it back to the delegate.

- (IBAction)pressedDone:(id)sender {
    SBTBaby *newBaby;
    if ([self.nameField.text isEqualToString:@""]){
        [self pressedCancel:self];
    }else{
        if (self.baby){
            newBaby = [self.baby copyWithNewName:self.nameField.text andDOB:self.dobPicker.date];
        }else{
            newBaby = [[SBTBaby alloc] initWithName:self.nameField.text andDOB:self.dobPicker.date];
        }
        newBaby.gender = (SBTGender)self.genderControl.selectedSegmentIndex;
        newBaby.thumbnail = image;
        [self.delegate babyEditor:self didSaveBaby:newBaby];
        [self dismissViewControllerAnimated:YES completion:nil];
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
    if (indexPath.row == BIRTH_TIME_ROW){
        return YES;
    }else{
        return NO;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == BIRTH_TIME_ROW + 1){
        return editingBirthTime ? DATE_PICKER_HEIGHT : 0.0;
    }else{
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == BIRTH_TIME_ROW) {
        editingBirthTime = !editingBirthTime;
        editingDOB = NO;
        [self.dobPicker setHidden:YES];
        [self.birthTimePicker setHidden:!editingBirthTime];
        if (!editingBirthTime){
            df.timeStyle = NSDateFormatterShortStyle;
            df.dateStyle = NSDateFormatterNoStyle;
            self.birthTimeLabel.text = [df stringFromDate:self.birthTimePicker.date];
            tempBirthTime = self.birthTimePicker.date;
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
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
        buildString = [NSString stringWithFormat:@"%ld %@ %1.1f oz", wt.pounds, units, wt.ounces];
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

}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"birthEncounterSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTEncounterEditTVC *dest = [nav.viewControllers firstObject];
        dest.delegate = self;
        dest.baby = self.baby;
        if ([self.baby.encountersList count]) {
            dest.encounter = self.baby.encountersList[0];
        }
        dest.dateDescriptionLabel.text = NSLocalizedString(@"Birth Date:", @"Label for birth date entry field");
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
        self.nameField.text = self.baby.name;
        self.babyPic.image = self.baby.thumbnail;
        [self.dobPicker setDate:self.baby.DOB];
        [self.birthTimePicker setDate:self.baby.DOB];
        [self.genderControl setSelectedSegmentIndex:self.baby.gender];
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
    self.nameField.delegate = self;
    df = [[NSDateFormatter alloc] init];
    df.calendar = [NSCalendar currentCalendar];
    nf = [[NSNumberFormatter alloc] init];
    [nf setLocale:[NSLocale currentLocale]];
    [self.birthTimePicker setHidden:YES];
    [self updateDisplay];
    self.oldBaby = self.baby;
}

-(void)dealloc
{
    df = nil;
    nf = nil;
    self.oldBaby = nil;
}

@end
