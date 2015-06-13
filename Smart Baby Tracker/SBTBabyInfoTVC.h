//
//  SBTBabyInfoTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTBabyEditViewController.h"

@class SBTBaby;

@interface SBTBabyInfoTVC : UITableViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

// model
@property (nonatomic, strong) SBTBaby *baby;
@property (nonatomic, weak) id<SBTBabyEditDelegate> delegate;

@end
