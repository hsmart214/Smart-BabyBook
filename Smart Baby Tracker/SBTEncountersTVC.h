//
//  SBTEncountersTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTBabyEditDelegate.h"
@class SBTBaby;

@interface SBTEncountersTVC : UITableViewController

@property (nonatomic, weak) SBTBaby *baby;
@property (nonatomic, weak) id<SBTBabyEditDelegate> delegate;
@property (nonatomic, strong) NSArray *encounters;

@end
