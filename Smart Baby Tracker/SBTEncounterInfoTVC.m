//
//  SBTEncounterInfoTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/22/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncounterInfoTVC.h"
#import "SBTEncounter.h"
#import "SBTVaccine.h"
#import "SBTUnitsConvertor.h"

@interface SBTEncounterInfoTVC ()

@property (nonatomic, strong) NSMutableArray *vaccineComponents;       // store the names of each component from each vaccine given
@property (nonatomic, strong) NSMutableArray *componentFromVaccine;    // store the name of the vaccine each component came from

@end

@implementation SBTEncounterInfoTVC

-(void)setEncounter:(SBTEncounter *)encounter
{
    if (encounter != _encounter){
        _encounter = encounter;
        _vaccineComponents = [NSMutableArray array];
        _componentFromVaccine = [NSMutableArray array];
        for (SBTVaccine *vacc in [encounter vaccinesGiven]){
            for (NSString *displayName in vacc.displayNames){
                [self.vaccineComponents addObject:displayName];
                [self.componentFromVaccine addObject:vacc.name];
            }
        }
    }
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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return NSLocalizedString(@"Measurements", @"Header for growth measurements in table view");
    }else{
        return NSLocalizedString(@"Vaccines Given", @"Header for vaccines in encounter table view");
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EncounterInfoCell" forIndexPath:indexPath];
    double stature = self.encounter.height + self.encounter.length;
    stature = [SBTUnitsConvertor displayUnitsOf:stature forKey:LENGTH_UNIT_KEY];
    double wt = [SBTUnitsConvertor displayUnitsOf:self.encounter.weight forKey:MASS_UNIT_KEY];
    double hc = [SBTUnitsConvertor displayUnitsOf:self.encounter.headCirc forKey:LENGTH_UNIT_KEY];
    if (indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Height/Length";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.1f %@", stature, [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY]];
                if (stature == 0.0) cell.detailTextLabel.text = @"";
                break;
            case 1:
                //TODO: fix the display for pounds and ounces!!!!
                cell.textLabel.text = @"Weight";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.1f %@", wt, [SBTUnitsConvertor displayStringForKey:MASS_UNIT_KEY]];
                if (wt == 0.0) cell.detailTextLabel.text = @"";
                break;
            case 2:
                cell.textLabel.text = @"Head Circumference";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.1f %@", hc, [SBTUnitsConvertor displayStringForKey:LENGTH_UNIT_KEY]];
                if (hc == 0.0) cell.detailTextLabel.text = @"";
                break;
            default:
                NSAssert(NO, @"Should never reach this default clause (SBTEncounterInfoTVC)");
                break;
        }
    }else{
        NSInteger offset = indexPath.row - 3;
        cell.textLabel.text = self.vaccineComponents[offset];
        cell.detailTextLabel.text = self.componentFromVaccine[offset];
    }
    return cell;
}

@end
