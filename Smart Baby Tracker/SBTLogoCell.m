//
//  SBTLogoCell.m
//  Smart BabyBook
//
//  Created by J. HOWARD SMART on 10/13/17.
//  Copyright © 2017 J. HOWARD SMART. All rights reserved.
//

#import "SBTLogoCell.h"

@implementation SBTLogoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.infoTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    [self.infoTextView flashScrollIndicators];
}

@end
