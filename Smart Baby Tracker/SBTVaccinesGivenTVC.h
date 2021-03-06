//
//  SBTVaccinesGivenTVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
@class SBTVaccinesGivenTVC;
@class SBTVaccine;

@protocol SBTVaccinesGivenTVCDelegate <NSObject>

@required

-(void)vaccinesGivenTVC:(SBTVaccinesGivenTVC *)vaccinesGivenTVC updatedVaccines:(NSSet *)newVaccineSet;
-(BOOL)vaccineIsTooEarly:(SBTVaccine *)vaccine;
-(BOOL)babyIsTooOldForVaccine:(SBTVaccine *)vaccine;

@end

@interface SBTVaccinesGivenTVC : UITableViewController

@property (nonatomic, strong) NSMutableSet *vaccinesGiven;
@property (nonatomic, weak) id<SBTVaccinesGivenTVCDelegate> delegate;

@end
