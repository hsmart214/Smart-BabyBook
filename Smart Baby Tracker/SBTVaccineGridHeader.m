//
//  SBTVaccineGridHeader.m
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineGridHeader.h"

@interface SBTVaccineGridHeader()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SBTVaccineGridHeader

-(void)setComponentName:(NSString *)componentName
{
    self.label.text = componentName;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
