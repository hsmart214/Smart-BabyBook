//
//  SBTVaccinesGivenTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccinesGivenTVC.h"
#import "SBTVaccine.h"

@interface SBTVaccinesGivenTVC ()

@end

@implementation SBTVaccinesGivenTVC
{
    NSMutableSet *selected; // we will load this with the names of the selected vaccines
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return [[SBTVaccine vaccinesByTradeName] count];
    }else{
        return [[SBTVaccine vaccinesByGenericName] count];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell accessoryType] == UITableViewCellAccessoryNone){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
}

#pragma mark - UITableViewDatasource

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return @"Trade names";
    }else{
        return @"Generic names";
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Vaccine Cell" forIndexPath:indexPath];
    SBTVaccine *vacc;
    if (indexPath.section == 0){  // trade name section
        NSArray *array = [[[SBTVaccine vaccinesByTradeName] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 localizedCaseInsensitiveCompare:obj2];
        }];
        vacc = [SBTVaccine vaccinesByTradeName][array[indexPath.row]];
    }else{  // generic name section
        NSArray *array = [[[SBTVaccine vaccinesByGenericName] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 localizedCaseInsensitiveCompare:obj2];
        }];
        vacc = [SBTVaccine vaccinesByGenericName][array[indexPath.row]];
    }
    cell.textLabel.text = vacc.name;
    NSString *str = [vacc.displayNames firstObject];
    if ([vacc.displayNames count] > 1){
        for (int i = 1; i < [vacc.displayNames count]; i++){
            str = [str stringByAppendingString:[NSString stringWithFormat:@" %@", vacc.displayNames[i]]];
        }
    }
    cell.detailTextLabel.text = str;
    if ([selected containsObject:vacc.name]){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

#pragma mark - Navigation, View Life Cycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selected = [NSMutableSet set];
    for (SBTVaccine *vac in self.vaccinesGiven){
        [selected addObject:vac.name];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSMutableSet *newVaccineSet = [NSMutableSet set];
    NSDictionary *genericVaccines = [SBTVaccine vaccinesByGenericName];
    NSSet *genericNames = [NSSet setWithArray:[genericVaccines allKeys]];
    NSDictionary *brandNameVaccines = [SBTVaccine vaccinesByTradeName];
    for (NSString *vacName in selected){
        if ([genericNames containsObject:vacName]){
            [newVaccineSet addObject:genericVaccines[vacName]];
        }else{
            [newVaccineSet addObject:brandNameVaccines[vacName]];
        }
    }
    [self.delegate vaccinesGivenTVC:self updatedVaccines:newVaccineSet];
    [super viewWillDisappear:animated];
}

@end
