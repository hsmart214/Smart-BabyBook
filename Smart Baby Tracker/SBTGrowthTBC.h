//
//  SBTGrowthTBC.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/13/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

@import UIKit;
@class SBTBaby;

@interface SBTGrowthTBC : UITabBarController

@property (nonatomic, getter=isChildGrowthChart) BOOL childGrowthChart;
@property (weak, nonatomic) SBTBaby* baby;

@end
