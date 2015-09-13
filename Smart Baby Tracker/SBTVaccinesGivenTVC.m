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

@property (nonatomic, strong) NSDictionary *vaccinesByGenericName;
@property (nonatomic, strong) NSDictionary *vaccinesByTradeName;

@end

@implementation SBTVaccinesGivenTVC
{
    __block NSMutableSet *selected; // we will load this with the names of the selected vaccines
}

-(NSDictionary *)vaccinesByGenericName{
    if (!_vaccinesByGenericName){
        _vaccinesByGenericName = [SBTVaccine vaccinesByGenericName];
    }
    return _vaccinesByGenericName;
}

-(NSDictionary *)vaccinesByTradeName{
    if (!_vaccinesByTradeName){
        _vaccinesByTradeName = [SBTVaccine vaccinesByTradeName];
    }
    return _vaccinesByTradeName;
}

-(NSArray *)sortedTradeNames{
    if (!_sortedTradeNames){
        _sortedTradeNames = [[self.vaccinesByTradeName allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            return [obj1 localizedCaseInsensitiveCompare:obj2];
        }];
    }
    return _sortedTradeNames;
}

-(NSArray *)sortedGenericNames{
    if (!_sortedGenericNames){
        _sortedGenericNames = [[self.vaccinesByGenericName allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
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
        SBTVaccine *vacc;
        if (self.vaccinesByGenericName[cell.textLabel.text]){
            vacc = self.vaccinesByGenericName[cell.textLabel.text];
        }else{
            vacc = self.vaccinesByTradeName[cell.textLabel.text];
        }
        if (![self.delegate vaccineIsTooEarly:vacc] && ![self.delegate babyIsTooOldForVaccine:vacc]){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            [selected addObject:cell.textLabel.text];
        }else{
            // here we embark on informing the user that the vaccine date is out of range
            // in certain cases this will still be acceptable, so we must allow for it
            NSString *ageText = [self.delegate vaccineIsTooEarly:vacc] ? @"too young" : @"too old";
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:[NSString stringWithFormat:@"Child %@ for vaccine.", ageText]
                                                         message:@"This may be appropriate for epidemics or known exposure."
                                                  preferredStyle:UIAlertControllerStyleActionSheet];
            __weak NSMutableSet *slectd = selected;
            UIAlertAction *actionAdd = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                [slectd addObject:cell.textLabel.text];
            }];
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
            [alert addAction:actionAdd];
            [alert addAction:actionCancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
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
    NSSet *genericNames = [NSSet setWithArray:[self.vaccinesByGenericName allKeys]];
    for (NSString *vacName in selected){
        if ([genericNames containsObject:vacName]){
            [newVaccineSet addObject:self.vaccinesByGenericName[vacName]];
        }else{ // must be a trade name - mutually exclusive sets of names
            [newVaccineSet addObject:self.vaccinesByTradeName[vacName]];
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

-(void)dealloc{
    self.sortedGenericNames = nil;
    self.sortedTradeNames = nil;
    self.vaccinesGiven = nil;
}

@end
