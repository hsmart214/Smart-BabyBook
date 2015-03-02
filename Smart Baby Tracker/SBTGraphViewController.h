//
//  SBTGraphViewController.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/24/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTGrowthDataSource.h"

@class SBTBaby;

@interface SBTGraphViewController : UIViewController

@property (nonatomic, weak) SBTBaby *baby;
@property (nonatomic, weak) SBTGrowthDataSource *growthDataSource;
@property (nonatomic, assign)SBTGrowthParameter parameter;

@end
