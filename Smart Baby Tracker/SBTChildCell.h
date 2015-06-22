//
//  SBTChildCell.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 6/21/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBTBaby;

@interface SBTChildCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *dobLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusIcon;

@property (weak, nonatomic) SBTBaby *baby;

@end
