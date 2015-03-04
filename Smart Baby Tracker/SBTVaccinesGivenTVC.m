//
//  SBTVaccinesGivenTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/16/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccinesGivenTVC.h"
#import "SBTVaccine.h"
#import "SBTScannedVaccineDetailsTVC.h"

// Note that only the NAMES of the given vaccines are used to determine what was administered
// Make sure there are NO DUPLICATE NAMES in the vaccine dictionaries!


@interface SBTVaccinesGivenTVC ()

@property (nonatomic, strong) NSArray *sortedTradeNames;
@property (nonatomic, strong) NSArray *sortedGenericNames;

@end

@implementation SBTVaccinesGivenTVC
{
    NSMutableSet *selected; // we will load this with the names of the selected vaccines
}

-(NSArray *)sortedTradeNames{
    if (!_sortedTradeNames){
        _sortedTradeNames = [[[SBTVaccine vaccinesByTradeName] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 localizedCaseInsensitiveCompare:obj2];
        }];
    }
    return _sortedTradeNames;
}

-(NSArray *)sortedGenericNames{
    if (!_sortedGenericNames){
        _sortedGenericNames = [[[SBTVaccine vaccinesByGenericName] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 localizedCaseInsensitiveCompare:obj2];
        }];
    }
    return _sortedGenericNames;
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
        [selected addObject:cell.textLabel.text];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [selected removeObject:cell.textLabel.text];
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
        vacc = [SBTVaccine vaccinesByTradeName][self.sortedTradeNames[indexPath.row]];
    }else{  // generic name section
        vacc = [SBTVaccine vaccinesByGenericName][self.sortedGenericNames[indexPath.row]];
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

- (IBAction)discardChanges:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveChanges:(id)sender {
    NSMutableSet *newVaccineSet = [NSMutableSet set];
    NSDictionary *genericVaccines = [SBTVaccine vaccinesByGenericName];
    NSSet *genericNames = [NSSet setWithArray:[genericVaccines allKeys]];
    NSDictionary *brandNameVaccines = [SBTVaccine vaccinesByTradeName];
    for (NSString *vacName in selected){
        if ([genericNames containsObject:vacName]){
            [newVaccineSet addObject:genericVaccines[vacName]];
        }else{ // must be a trade name - mutually exclusive sets of names
            [newVaccineSet addObject:brandNameVaccines[vacName]];
        }
    }
    [self.delegate vaccinesGivenTVC:self updatedVaccines:newVaccineSet];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    selected = [NSMutableSet set];
    for (SBTVaccine *vac in self.vaccinesGiven){
        [selected addObject:vac.name];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
}

@end
