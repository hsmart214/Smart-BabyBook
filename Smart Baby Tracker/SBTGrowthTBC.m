//
//  SBTGrowthTBC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/13/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTGrowthTBC.h"

@interface SBTGrowthTBC ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *ageToggle;

@end

@implementation SBTGrowthTBC

- (BOOL)childGrowthChart{
    return self.ageToggle.selectedSegmentIndex;
}

- (void)setChildGrowthChart:(BOOL)childGrowthChart{
    if (childGrowthChart){
        [self.ageToggle setSelectedSegmentIndex:1];
    }else{
        [self.ageToggle setSelectedSegmentIndex:0];
    };
}

- (IBAction)toggleAge:(UISegmentedControl *)sender {
    NSInteger state = sender.selectedSegmentIndex;
    switch (state) {
        case 0:
            [sender setSelectedSegmentIndex:1];
            break;
        case 1:
            [sender setSelectedSegmentIndex:0];
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:SBTGrowthChartDidChangeAgeRangeNotification object:self userInfo:@{SBTChildGraphKey : @(state)}];
}

@end
