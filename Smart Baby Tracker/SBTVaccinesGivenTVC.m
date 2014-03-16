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
    return cell;
}

@end
