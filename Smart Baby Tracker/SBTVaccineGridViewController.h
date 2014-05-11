//
//  SBTVaccineGridViewController.h
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SBTBaby;

@interface SBTVaccineGridViewController : UICollectionViewController

@property (nonatomic, strong) SBTBaby *baby;

+(NSArray *)componentsForGrid;

@end
