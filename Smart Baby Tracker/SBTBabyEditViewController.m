//
//  SBTBabyEditViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTBabyEditViewController.h"
#import "SBTImageStore.h"
@import MobileCoreServices;

@interface SBTBabyEditViewController ()<UITextFieldDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate>
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
        [newBaby setImageKey:imageKey];
        newBaby.thumbnail = image;
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

#pragma mark - UITableViewDelegate

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
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
    image = [self reducedSizeImage: info[UIImagePickerControllerOriginalImage]];
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDCFString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    //TODO: Decide whether I really need to store the images
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

-(void)updateDisplay
{
    if (self.baby){
        self.title = self.baby.name;
        self.nameField.text = self.baby.name;
        self.babyPic.image = self.baby.thumbnail;
        [self.dobPicker setDate:self.baby.DOB];
        [self.birthTimePicker setDate:self.baby.DOB];
        [self.genderControl setSelectedSegmentIndex:self.baby.gender];
    }
    if (image) self.babyPic.image = image;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.nameField.delegate = self;
    [self updateDisplay];
}

@end
