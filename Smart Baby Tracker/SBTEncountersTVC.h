//
//  SBTEncountersTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
@class SBTBaby;

@interface SBTEncountersTVC : UITableViewController

@property (nonatomic, strong) SBTBaby *baby;
@property (nonatomic, strong) NSArray *encounters;

@end
