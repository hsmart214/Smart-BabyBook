//
//  SBTAddScannedVaccinesTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;

@class SBTAddScannedVaccinesTVC;

@protocol SBTAddScannedVaccinesDelegate

-(void)addScannedVaccinesTVC:(SBTAddScannedVaccinesTVC *)sender addedVaccines:(NSArray *)vaccines;

@end

@interface SBTAddScannedVaccinesTVC : UITableViewController

@property (nonatomic, strong) NSSet* currentVaccines;  // set of SBTVaccine

@end
