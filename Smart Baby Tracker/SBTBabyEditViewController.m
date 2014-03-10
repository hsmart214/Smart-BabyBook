//
//  SBTBabyEditViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTBabyEditViewController.h"

@interface SBTBabyEditViewController ()<UITextFieldDelegate>

@end

@implementation SBTBabyEditViewController

- (IBAction)pressedDone:(id)sender {
    SBTBaby *newBaby = [[SBTBaby alloc] initWithName:self.nameField.text andDOB:self.dobPicker.date];
    [self.delegate babyEditViewController:self didSaveBaby:newBaby];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pressedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
