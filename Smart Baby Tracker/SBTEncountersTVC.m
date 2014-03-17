//
//  SBTEncountersTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTEncountersTVC.h"
#import "SBTEncounterTableViewCell.h"
#import "SBTEncounter.h"
#import "SBTBaby.h"
#import "SBTEncounterEditTVC.h"

@interface SBTEncountersTVC ()<SBTEncounterEditTVCDelegate>

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation SBTEncountersTVC

#pragma mark - UITableViewDatasource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.encounters count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTEncounterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Encounter Cell" forIndexPath:indexPath];
    SBTEncounter *enc = self.encounters[indexPath.row];
    cell.dateLabel.text = [self.dateFormatter stringFromDate:enc.dateComps.date];
    if (enc.weight != 0.0){
        [cell.weightIcon setAlpha:1.0];
    }else{
        [cell.weightIcon setAlpha:0.0];
    }
    // one of these (or both) will be zero
    double combinedStature = enc.length + enc.height;
    if (combinedStature != 0.0){
        [cell.heightIcon setAlpha:1.0];
    }else{
        [cell.heightIcon setAlpha:0.0];
    }
    if (enc.headCirc != 0.0) {
        [cell.headIcon setAlpha:1.0];
    }else{
        [cell.headIcon setAlpha:0.0];
    }
    cell.ageAtEncounterLabel.text = [self.baby ageDescriptionAtDate:enc.dateComps.date];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - SBTEncounterEditTVCDelegate

-(void)SBTEncounterEditTVC:(SBTEncounterEditTVC *)editTVC updatedEncounter:(SBTEncounter *)encounter
{
    if (![self.encounters containsObject:encounter]){
        [self.baby addEncounter:encounter];
        self.encounters = [self.baby encountersList];
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addEncounterSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTEncounterEditTVC *editTVC = [nav.viewControllers firstObject];
        editTVC.baby = self.baby;
        editTVC.delegate = self;
    }
}

#pragma mark - View Life Cycle

-(void)viewDidLoad
{
    NSAssert(self.baby != nil, @"No baby in encounters TVC");
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setCalendar:[NSCalendar currentCalendar]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    self.encounters = [self.baby encountersList];
}

@end
