//
//  SBTBabyEditViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTBabyEditViewController.h"
#import "SBTImageStore.h"

@interface SBTBabyEditViewController ()<UITextFieldDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *babyPic;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderControl;
@property (nonatomic, strong) UIPopoverController *popCon;
@end

@implementation SBTBabyEditViewController
{
    UIImage *image;
    NSString *imageKey;
}

// wait until the last minute to create the new baby and return it.

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
        [newBaby setImageKey:imageKey];
        [newBaby setThumbnailDataFromImage:image];
        [self.delegate babyEditViewController:self didSaveBaby:newBaby];
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

#pragma mark - UIPopoverController Delegate

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popCon = nil;
}

#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.baby.imageKey){
        [[SBTImageStore sharedStore] deleteImageForKey:self.baby.imageKey];
    }
    image = info[UIImagePickerControllerOriginalImage];
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDCFString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    imageKey = (__bridge NSString *)newUniqueIDCFString;
    [[SBTImageStore sharedStore] setImage:image forKey:imageKey];
    
    CFRelease(newUniqueID);
    CFRelease(newUniqueIDCFString);
    
    if (self.popCon) {
        [self.popCon dismissPopoverAnimated:YES];
        self.popCon = nil;
    }else{
        [self dismissViewControllerAnimated:YES completion:self.dismissBlock];
    }
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.nameField.delegate = self;
}

@end
