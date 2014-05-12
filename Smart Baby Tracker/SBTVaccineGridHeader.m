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
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation SBTVaccineGridHeader

-(void)setComponentName:(NSString *)componentName
{
    self.label.text = componentName;
}

-(void)setStatus:(SBTVaccinationStatus)status
{
    switch (status) {
        case SBTVaccinationDue:
            self.statusLabel.text = NSLocalizedString(@"Due", @"Vaccine is due (one word?)");
            break;
        case SBTVaccinationDueLockedOut:
            self.statusLabel.text = NSLocalizedString(@"Lockout", @"Vaccine is locked out (one word?)");
            break;
        case SBTVaccinationOverdue:
            self.statusLabel.text = NSLocalizedString(@"Overdue", @"Vaccine is overdue (one word?)");
            break;
        case SBTVaccinationUTD:
            self.statusLabel.text = NSLocalizedString(@"UTD", @"Vaccine is up to date (one word?)");
            break;
        default:
            self.statusLabel.text = @"Should not ever see this text";
            break;
    }
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
