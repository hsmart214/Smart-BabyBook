//
//  SBTGraphVC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/13/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
#import "SBTGrowthDataSource.h"

@class SBTBaby;

@interface SBTGraphVC : UIViewController

@property (nonatomic, weak) SBTBaby *baby;
@property (nonatomic, weak) SBTGrowthDataSource *growthDataSource;
@property (nonatomic, assign)SBTGrowthParameter parameter;


@end
