//
//  SBTPreferencesTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 4/6/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTPreferencesTVC.h"

#define INFANT_STANDARD_SECTION 0
#define CHILD_STANDARD_SECTION 1
#define INFANT_CHILD_BREAK_SECTION 2
#define MEASURMENT_STANDARD_SECTION 3

#define CDC_ROW 0
#define WHO_ROW 1

#define TWO_YEAR_ROW 0
#define THREE_YEAR_ROW 1
#define FIVE_YEAR_ROW 2

#define TWO_YEARS 730.5
#define THREE_YEARS 1095.75
#define FIVE_YEARS 1826.25

#define US_STANDARD_ROW 0
#define METRIC_STANDARD_ROW 1


@interface SBTPreferencesTVC ()

@end

@implementation SBTPreferencesTVC

-(NSString *)textForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"INFANT GROWTH STANDARDS", @"Infant Growth Standards");
        case 1:
            return NSLocalizedString(@"CHILD GROWTH STANDARDS", @"Child Growth Standards");
        case 2:
            return NSLocalizedString(@"INFANT/CHILD AGE CUTOFF", @"Infant/Child age cutoff");
        case 3:
            return NSLocalizedString(@"MEASUREMENT UNITS", @"Measurement Units");
            
        default:
            return nil;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont boldSystemFontOfSize:17.0]];
    [label setTextColor:[UIColor whiteColor]];
    label.text = [self textForHeaderInSection:section];
    return label;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.section) {
        case INFANT_STANDARD_SECTION:
        {
            NSIndexPath *otherPath;
            if (indexPath.row == CDC_ROW){
                otherPath = [NSIndexPath indexPathForRow:WHO_ROW
                                               inSection:INFANT_STANDARD_SECTION];
                [defaults setInteger:CDC_INFANT_CHART forKey:SBTGrowthDataSourceInfantDataSourceKey];
            }else{
                otherPath = [NSIndexPath indexPathForRow:CDC_ROW
                                               inSection:INFANT_STANDARD_SECTION];
                [defaults setInteger:WHO_INFANT_CHART forKey:SBTGrowthDataSourceInfantDataSourceKey];
            }
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            cell = [tableView cellForRowAtIndexPath:otherPath];
            [cell    setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
        case CHILD_STANDARD_SECTION:
        {
            NSIndexPath *otherPath;
            if (indexPath.row == CDC_ROW){
                otherPath = [NSIndexPath indexPathForRow:WHO_ROW
                                               inSection:CHILD_STANDARD_SECTION];
                [defaults setInteger:CDC_CHILD_CHART forKey:SBTGrowthDataSourceChildDataSourceKey];
            }else{
                otherPath = [NSIndexPath indexPathForRow:CDC_ROW
                                               inSection:CHILD_STANDARD_SECTION];
                // using the WHO standard for CHILDREN requires the entire first 5 years to be done as WHO data
                // therefore we also need to set WHO for the infant standard and set the break point to five years.
                NSIndexPath *yap = [NSIndexPath indexPathForRow:CDC_ROW inSection:INFANT_STANDARD_SECTION];
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:yap];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                yap = [NSIndexPath indexPathForRow:WHO_ROW inSection:INFANT_STANDARD_SECTION];
                cell = [tableView cellForRowAtIndexPath:yap];
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                yap = [NSIndexPath indexPathForRow:TWO_YEAR_ROW inSection:INFANT_CHILD_BREAK_SECTION];
                cell = [tableView cellForRowAtIndexPath:yap];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                yap = [NSIndexPath indexPathForRow:THREE_YEAR_ROW inSection:INFANT_CHILD_BREAK_SECTION];
                cell = [tableView cellForRowAtIndexPath:yap];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                yap = [NSIndexPath indexPathForRow:FIVE_YEAR_ROW inSection:INFANT_CHILD_BREAK_SECTION];
                cell = [tableView cellForRowAtIndexPath:yap];
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [defaults setInteger:WHO_CHILD_CHART forKey:SBTGrowthDataSourceChildDataSourceKey];
            }
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            cell = [tableView cellForRowAtIndexPath:otherPath];
            [cell    setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
        case INFANT_CHILD_BREAK_SECTION:
        {
            NSIndexPath *otherPath1, *otherPath2;
            switch (indexPath.row) {
                case TWO_YEAR_ROW:
                    otherPath1 = [NSIndexPath indexPathForRow:THREE_YEAR_ROW
                                                    inSection:INFANT_CHILD_BREAK_SECTION];
                    otherPath2 = [NSIndexPath indexPathForRow:FIVE_YEAR_ROW
                                                    inSection:INFANT_CHILD_BREAK_SECTION];
                    [defaults setDouble:TWO_YEARS forKey:SBTGrowthDataSourceInfantChildCutoffKey];
                    break;
                case THREE_YEAR_ROW:
                    otherPath1 = [NSIndexPath indexPathForRow:TWO_YEAR_ROW
                                                    inSection:INFANT_CHILD_BREAK_SECTION];
                    otherPath2 = [NSIndexPath indexPathForRow:FIVE_YEAR_ROW
                                                    inSection:INFANT_CHILD_BREAK_SECTION];
                    [defaults setDouble:THREE_YEARS forKey:SBTGrowthDataSourceInfantChildCutoffKey];
                    break;
                case FIVE_YEAR_ROW:
                    otherPath1 = [NSIndexPath indexPathForRow:THREE_YEAR_ROW
                                                    inSection:INFANT_CHILD_BREAK_SECTION];
                    otherPath2 = [NSIndexPath indexPathForRow:TWO_YEAR_ROW
                                                    inSection:INFANT_CHILD_BREAK_SECTION];
                    [defaults setDouble:FIVE_YEARS forKey:SBTGrowthDataSourceInfantChildCutoffKey];
                    break;
                default:
                    break;
            }
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            cell = [tableView cellForRowAtIndexPath:otherPath1];
            [cell    setAccessoryType:UITableViewCellAccessoryNone];
            cell = [tableView cellForRowAtIndexPath:otherPath2];
            [cell    setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
        case MEASURMENT_STANDARD_SECTION:
        {
            NSIndexPath *otherPath;
            if (indexPath.row == US_STANDARD_ROW){
                otherPath = [NSIndexPath indexPathForRow:METRIC_STANDARD_ROW
                                               inSection:MEASURMENT_STANDARD_SECTION];
                [defaults setObject:SBTUnitPreferenceStandard forKey:UNIT_PREFS_KEY];
            }else{
                otherPath = [NSIndexPath indexPathForRow:US_STANDARD_ROW
                                               inSection:MEASURMENT_STANDARD_SECTION];
                [defaults setObject:SBTUnitPreferenceMetric forKey:UNIT_PREFS_KEY];
            }
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            cell = [tableView cellForRowAtIndexPath:otherPath];
            [cell    setAccessoryType:UITableViewCellAccessoryNone];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [defaults synchronize];
}

#pragma mark - Target/Action

- (IBAction)pressedDone:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad
{
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadMasterBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
}

@end
