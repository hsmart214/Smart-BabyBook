//
//  SBTEncounterEditTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SBTBaby;
@class SBTEncounter;

@interface SBTEncounterEditTVC : UITableViewController

@property (nonatomic, strong) SBTEncounter *encounter;
@property (nonatomic, strong) SBTBaby *baby;

@end
