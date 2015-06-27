//
//  SBTEncounterInfoTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/22/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
@class SBTEncounter;
#import "SBTEncounterEditTVC.h"
#import "SBTBabyEditDelegate.h"

@interface SBTEncounterInfoTVC : UITableViewController

@property (nonatomic, weak) SBTEncounter *encounter;
@property (nonatomic, weak) id<SBTEncounterEditTVCDelegate> delegate;
@property (nonatomic, assign) BOOL disableEditing;

@end
