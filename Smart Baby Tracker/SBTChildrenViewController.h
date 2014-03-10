//
//  SBTChildrenViewController.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTBabyEditViewController.h"

@interface SBTChildrenViewController : UITableViewController<SBTBabyEditDelegate>

@property (nonatomic, strong)NSMutableArray *children;

@end
