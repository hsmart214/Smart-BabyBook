//
//  SBTEncounterTableViewCell.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounterTableViewCell.h"

@implementation SBTEncounterTableViewCell

-(NSString *)debugDescription{
    return [NSString stringWithFormat:@"Encounter on date %@", self.dateLabel.text];
}

@end
