//
//  SBTEncounterTableViewCell.h
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBTEncounterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageAtEncounterLabel;

@property (weak, nonatomic) IBOutlet UIImageView *heightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *weightIcon;
@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UIImageView *vaccineIcon;
@property (weak, nonatomic) IBOutlet UIImageView *milestoneIcon;


@end
