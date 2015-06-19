//
//  SBTVaccineGridViewController.h
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBTBaby.h"
#import "SBTEncounterEditTVC.h"

@interface SBTVaccineGridViewController : UICollectionViewController

@property (nonatomic, strong) SBTBaby *baby;
@property (weak, nonatomic) id<SBTEncounterEditTVCDelegate> delegate;

@end
