//
//  SBTScannedVaccineDetailsTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTVaccine.h"
#import "SBTAddScannedVaccinesTVC.h"

@interface SBTScannedVaccineDetailsTVC : UITableViewController

@property (strong, nonatomic) SBTVaccine* vaccine;
@property (weak, nonatomic) id<SBTAddScannedVaccinesDelegate>delegate;

@end
