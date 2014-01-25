//
//  SBTMasterViewController.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 1/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBTDetailViewController;

@interface SBTMasterViewController : UITableViewController

@property (strong, nonatomic) SBTDetailViewController *detailViewController;

@end
