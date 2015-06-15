//
//  SBTEncounterInfoTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/22/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounterInfoTVC.h"
#import "SBTEncounterEditTVC.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTUnitsConvertor.h"
#import "SBTBaby.h"


@interface SBTEncounterInfoTVC ()<SBTEncounterEditTVCDelegate>

@property (nonatomic, strong) NSMutableArray *vaccineComponents;       // store the names of each component from each vaccine given
@property (nonatomic, strong) NSMutableArray *componentFromVaccine;    // store the name of the vaccine each component came from

@end

@implementation SBTEncounterInfoTVC

-(void)setEncounter:(SBTEncounter *)encounter
{
    _encounter = encounter;
    _vaccineComponents = [NSMutableArray array];
    _componentFromVaccine = [NSMutableArray array];
    for (SBTVaccine *vacc in [encounter vaccinesGiven]){
        
        for (NSString *displayName in vacc.displayNames){
            [self.vaccineComponents addObject:displayName];
            [self.componentFromVaccine addObject:vacc.name];
        }
    }
    [self.tableView reloadData];
}

-(void)SBTEncounterEditTVC:(SBTEncounterEditTVC *)editTVC updatedEncounter:(SBTEncounter *)encounter
{
    self.encounter = encounter;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setCalendar:[NSCalendar currentCalendar]];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    NSString *title = [df stringFromDate:encounter.universalDate];
    [self setTitle:title];
    [self.delegate SBTEncounterEditTVC:editTVC updatedEncounter:encounter];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UITableViewDatasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return 3;
    }else{
        return [self.vaccineComponents count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *headerText;
    if (section == 0){
        headerText = NSLocalizedString(@"Measurements", @"Header for growth measurements in table view");
    }else{
        headerText = NSLocalizedString(@"Vaccines Given", @"Header for vaccines in encounter table view");
    }
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setText:headerText];
    return headerLabel;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EncounterInfoCell" forIndexPath:indexPath];
    double stature = self.encounter.height + self.encounter.length;
    stature = [SBTUnitsConvertor displayUnitsOf:stature forKey:LENGTH_UNIT_KEY];
    double wt = [SBTUnitsConvertor displayUnitsOf:self.encounter.weight forKey:MASS_UNIT_KEY];
    double hc = [SBTUnitsConvertor displayUnitsOf:self.encounter.headCirc forKey:HC_UNIT_KEY];
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = self.encounter.height != 0.0 ? NSLocalizedString(@"Height", @"Height"): NSLocalizedString(@"Length", @"Length");
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.1f %@", stature, [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY]];
                if (stature == 0.0) cell.detailTextLabel.text = @"";
                break;
            case 1:
            {
                cell.textLabel.text = @"Weight";
                NSString *wtString;
                if (wt == 0.0){
                    wtString = @"";
                }else if ([SBTUnitsConvertor displayPounds] && [self.encounter.baby ageDDAtDate:self.encounter.universalDate].day < AGE_SWITCH_TO_DECIMAL_POUNDS){
                    SBTImperialWeight impWt = [SBTUnitsConvertor imperialWeightForMass:self.encounter.weight];
                    wtString = [NSString stringWithFormat:@"%ld lbs %1.1f oz", (long)impWt.pounds, impWt.ounces];
                }else{
                    wtString = [NSString stringWithFormat:@"%1.1f %@", wt, [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY]];
                }
                cell.detailTextLabel.text = wtString;
            }
                break;
            case 2:
                cell.textLabel.text = @"Head Circumference";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.1f %@", hc, [SBTUnitsConvertor displayStringForKey:HC_UNIT_KEY]];
                if (hc == 0.0) cell.detailTextLabel.text = @"";
                break;
            default:
                NSAssert(NO, @"Should never reach this default clause (SBTEncounterInfoTVC)");
                break;
        }
    }else{
        NSInteger offset = indexPath.row;
        cell.textLabel.text = self.vaccineComponents[offset];
        cell.detailTextLabel.text = self.componentFromVaccine[offset];
    }
    return cell;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editThisEncounter"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTEncounterEditTVC *editor = nav.viewControllers[0];
        editor.encounter = self.encounter;
        editor.delegate = self;
    }
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
}

@end
