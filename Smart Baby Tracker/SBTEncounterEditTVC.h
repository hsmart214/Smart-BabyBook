//
//  SBTEncounterEditTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 6/12/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;

#import "SBTMeasurementEntryVC.h"

@class SBTEncounter;
@class SBTEncounterEditTVC;
@class SBTBaby;

@protocol SBTEncounterEditTVCDelegate <NSObject>

@required

-(void)SBTEncounterEditTVC:(SBTEncounterEditTVC *)editTVC updatedEncounter:(SBTEncounter *)encounter;

@end

@interface SBTEncounterEditTVC : UITableViewController<SBTMeasurementReturnDelegate>

@property (nonatomic, copy) SBTEncounter *encounter;
@property (nonatomic, weak) SBTBaby *baby;
@property (nonatomic, weak) id<SBTEncounterEditTVCDelegate> delegate;


@end
