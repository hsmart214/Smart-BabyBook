//
//  SBTAddScannedVaccinesTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;

@class SBTAddScannedVaccinesTVC;
@class SBTVaccine;

@protocol SBTAddScannedVaccinesDelegate

-(void)addScannedVaccinesTVC:(SBTAddScannedVaccinesTVC *)sender addedVaccines:(NSSet *)vaccines;
-(BOOL)isTooYoungForVaccine:(SBTVaccine *)vaccine;
-(BOOL)isTooOldForVaccine:(SBTVaccine *)vaccine;

@end

@interface SBTAddScannedVaccinesTVC : UITableViewController

@property (weak, nonatomic) id<SBTAddScannedVaccinesDelegate> delegate;
@property (nonatomic, strong) NSSet* currentVaccines;  // set of SBTVaccine
@property (nonatomic, assign) BOOL goStraightToCamera;

@end
