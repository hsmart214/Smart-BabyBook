//
//  SBTBabyEditViewController.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTBaby.h"
@class SBTBabyEditViewController;

@protocol SBTBabyEditDelegate <NSObject>

@required

-(void)babyEditViewController:(SBTBabyEditViewController *)babyEditVC didSaveBaby:(SBTBaby *)baby;

@end

@interface SBTBabyEditViewController : UITableViewController

@property (weak, nonatomic) id<SBTBabyEditDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *dobPicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *birthTimePicker;

@property (nonatomic, strong) SBTBaby *baby;
@property (nonatomic, copy) void (^dismissBlock)(void);


@end
