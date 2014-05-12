//
//  SBTVaccineGridViewController.m
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineGridViewController.h"
#import "SBTBaby.h"
#import "SBTVaccineCell.h"
#import "SBTVaccineGridHeader.h"

#define COMPONENT_KEY @"component"
#define ENCOUNTERS_KEY @"encounters"

@interface SBTVaccineGridViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
// this is an array of dictionaries - each has two entries - the name of the component, and an array of encounters where the component was given
@property (nonatomic, strong) NSArray *vaccines;
@property (nonatomic, strong, readonly) NSDictionary *componentsByName;

@end

@implementation SBTVaccineGridViewController

@synthesize componentsByName = _componentsByName;

-(NSArray *)vaccines
{
    if (!_vaccines){
        NSMutableArray *vaccines = [NSMutableArray array];
        NSArray *names = [[self class] displayNamesForGrid];
        NSArray *components = [[self class] componentsForGrid];
        for (NSInteger i = 0; i < [names count]; i++){
            // Get ready to make an entry in the vaccines array
            NSString *name = names[i];
            // find all of the encounters where a vaccine with one of these components was given
            for (NSNumber *n in components[i]){
                SBTComponent c = (SBTComponent)[n integerValue];
                NSArray *encounters = [self.baby encountersWithGivenVaccineComponent:c];
                if ([encounters count] > 0){
                    NSDictionary *dict = @{COMPONENT_KEY: name,
                                           ENCOUNTERS_KEY: encounters,
                                           };
                    [vaccines addObject:dict];
                }
            }
        }
        _vaccines = vaccines;
    }
    return _vaccines;
}

-(NSDictionary *)componentsByName
{
    if (!_componentsByName){
        NSArray *names = [[self class] displayNamesForGrid];
        NSArray *comps = [[self class] componentsForGrid];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (int i = 0; i < [names count]; i++){
            dict[names[i]] = [comps[i] firstObject];
        }
        _componentsByName = dict;
    }
    return _componentsByName;
}

-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setCalendar:[NSCalendar autoupdatingCurrentCalendar]];
    }
    return _dateFormatter;
}

#pragma mark - UICollectionView DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = 0;
    for (NSArray *comps in [[self class] componentsForGrid]){
        BOOL hasOneOrMoreOfTheseComponents = NO;
        for (NSNumber *n in comps){
            SBTComponent c = (SBTComponent)[n integerValue];
            if ([[self.baby daysGivenVaccineComponent:c] count] != 0){
                hasOneOrMoreOfTheseComponents = YES;
            }
        }
        if (hasOneOrMoreOfTheseComponents) count++;
    }
    return count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDictionary *vaccineRow = self.vaccines[section];
    return [vaccineRow[ENCOUNTERS_KEY] count];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SBTVaccineGridHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"vaccineHeader" forIndexPath:indexPath];
    NSDictionary *vaccineRow = self.vaccines[indexPath.section];
    NSString *compName = vaccineRow[COMPONENT_KEY];
    header.componentName = compName;
    SBTComponent c = (SBTComponent)[self.componentsByName[compName] integerValue];
    header.status = [[SBTVaccineSchedule sharedSchedule] vaccinationStatusForVaccineComponent:c forBaby:self.baby];
    return header;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SBTVaccineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"vaccineCell" forIndexPath:indexPath];
    NSDictionary *vaccineRow = self.vaccines[indexPath.section];
    cell.encounter = vaccineRow[ENCOUNTERS_KEY][indexPath.row];
    return cell;
}

#pragma mark - UICollectionView delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.splitViewController){
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Green"]];
        [self.view insertSubview:bgView atIndex:0];
    }
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

+(NSArray *)displayNamesForGrid{
    return @[
             @"DTP",
             @"HiB",
             @"Polio",
             @"Hep B",
             @"Hep A",
             @"MMR",
             @"Chickenpox",
             @"Rotavirus",
             @"Pneumococcus",
             @"Meningococcus",
             @"Tetanus",
             @"HPV",
             ];
}

+(NSArray *)componentsForGrid{
    return @[
             @[@(SBTComponentDTaP), @(SBTComponentDTP), @(SBTComponentDTwP)],
             @[@(SBTComponentHiB), @(SBTComponentPRP_OMP), @(SBTComponentPRP_T)],
             @[@(SBTComponentIPV), @(SBTComponentOPV)],
             @[@(SBTComponentHepB)],
             @[@(SBTComponentHepA)],
             @[@(SBTComponentMMR), @(SBTComponentMeasles), @(SBTComponentMumps), @(SBTComponentRubella)],
             @[@(SBTComponentVZV)],
             @[@(SBTComponentRota)],
             @[@(SBTComponentPCV13), @(SBTComponentPCV7)],
             @[@(SBTComponentMCV4), @(SBTComponentMenCY), @(SBTComponentMenC), @(SBTComponentMenB), @(SBTComponentMPV4)],
             @[@(SBTComponentTdap), @(SBTComponentTd)],
             @[@(SBTComponentHPV4), @(SBTComponentHPV2)],
             ];
}

@end
