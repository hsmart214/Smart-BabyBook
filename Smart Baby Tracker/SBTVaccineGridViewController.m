//
//  SBTVaccineGridViewController.m
//  Smart Baby Tracker
//
//  Created by J. Howard Smart on 5/10/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTVaccineGridViewController.h"
#import "SBTBaby.h"
#import "SBTVaccine.h"
#import "SBTVaccineCell.h"
#import "SBTVaccineGridHeader.h"

#define COMPONENT_KEY @"component"
#define ENCOUNTERS_KEY @"encounters"

@interface SBTVaccineGridViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
// this is an array of dictionaries - each has two entries - the name of the component, and an array of encounters where the component was given
@property (nonatomic, strong) NSArray *vaccinesGiven;
@property (nonatomic, strong, readonly) NSDictionary *componentsByName;
@property (nonatomic, strong, readonly) NSArray *componentsForGrid;
@property (nonatomic, strong, readonly) NSArray *displayNamesForGrid;
@property (nonatomic, strong) NSArray *gridModel;

@end

@implementation SBTVaccineGridViewController

@synthesize componentsByName = _componentsByName;
@synthesize displayNamesForGrid = _displayNamesForGrid;
@synthesize componentsForGrid = _componentsForGrid;

NSString * const SBTVaccineComponentKey = @"com.mySmartSoftware.SmartBabyTracker.vaccineComponentKey";
NSString * const SBTVaccineEncountersKey = @"com.mySmartSoftware.SmartBabyTracker.vaccineEncountersKey";

-(NSArray *)gridModel
{
    if (!_gridModel){
        NSMutableArray *buildModel = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < [self.componentsForGrid count]; i++){
            SBTComponent component = (SBTComponent)[self.componentsForGrid[i][0] integerValue];
            SBTVaccinationStatus status = [self statusForComponent:component];
            NSMutableDictionary *compDict = [[NSMutableDictionary alloc] init];
            compDict[SBTVaccineSeriesStatusKey] = @(status);
            compDict[SBTVaccineComponentKey] = @(component);
            NSMutableSet *componentEncounters = [[NSMutableSet alloc] init];
            for (NSNumber *n in self.componentsForGrid[i]){
                SBTComponent c = (SBTComponent)[n integerValue];
                NSArray *encs = [self.baby encountersWithGivenVaccineComponent:c];
                [componentEncounters addObjectsFromArray:encs];
            }
            compDict[SBTVaccineEncountersKey] = [componentEncounters allObjects];
            [buildModel addObject:compDict];
        }
        _gridModel = [buildModel copy];
    }
    return _gridModel;
}

-(NSArray *)vaccinesGiven
{
    if (!_vaccinesGiven){
        NSMutableArray *vaccines = [NSMutableArray array];
        NSArray *names = self.displayNamesForGrid;
        for (NSInteger i = 0; i < [names count]; i++){
            // Get ready to make an entry in the vaccines array
            NSString *name = names[i];
            // find all of the encounters where a vaccine with one of these components was given
            for (NSNumber *n in self.componentsForGrid[i]){
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
        _vaccinesGiven = [vaccines copy];
    }
    return _vaccinesGiven;
}

-(NSDictionary *)componentsByName
{
    if (!_componentsByName){
        NSArray *names = self.displayNamesForGrid;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (int i = 0; i < [names count]; i++){
            dict[names[i]] = [self.componentsForGrid[i] firstObject];
        }
        _componentsByName = dict;
    }
    return _componentsByName;
}

-(NSArray *)displayNamesForGrid
{
    if (!_displayNamesForGrid){
        _displayNamesForGrid = @[
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
    return _displayNamesForGrid;
}

-(NSArray *)componentsForGrid
{
    if (!_componentsForGrid){
        _componentsForGrid = @[
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
    return _componentsForGrid;
}

-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter){
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setCalendar:[NSCalendar autoupdatingCurrentCalendar]];
    }
    return _dateFormatter;
}

-(SBTVaccinationStatus)statusForComponentNumber:(NSNumber *)componentObject
{
    SBTComponent c = (SBTComponent)[componentObject integerValue];
    SBTVaccineSchedule *sched = [SBTVaccineSchedule sharedSchedule];
    NSDictionary *dict = [sched vaccinationStatusForVaccineComponent:c
                                                             forBaby:self.baby];
    NSNumber *n = dict[SBTVaccineSeriesStatusKey];
    return (SBTVaccinationStatus)[n integerValue];
}

-(SBTVaccinationStatus)statusForComponent:(SBTComponent)component
{
    return [self statusForComponentNumber:@(component)];
}

#pragma mark - UICollectionView DataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
//    NSInteger count = 0;
//    for (NSArray *comps in self.componentsForGrid){
//        BOOL hasOneOrMoreOfTheseComponents = NO;
//        BOOL thisVaccineIsDueNow = NO;
//        for (NSNumber *n in comps){
//            SBTComponent c = (SBTComponent)[n integerValue];
//            if ([[self.baby daysGivenVaccineComponent:c] count] != 0){
//                hasOneOrMoreOfTheseComponents = YES;
//            }
//        }
//        SBTVaccinationStatus s = [self statusForComponentNumber:comps[0]];
//        thisVaccineIsDueNow = (s == SBTVaccinationDue);
//        if (hasOneOrMoreOfTheseComponents || thisVaccineIsDueNow) count++;
//    }
//    return count;
    return [self.gridModel count];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSDictionary *vaccineRow = self.vaccinesGiven[section];
//    return [vaccineRow[ENCOUNTERS_KEY] count];
    NSInteger items = [self.gridModel[section][SBTVaccineEncountersKey] count];
    SBTVaccinationStatus status = (SBTVaccinationStatus)[self.gridModel[section][SBTVaccineSeriesStatusKey] integerValue];
    if (status == SBTVaccinationDue || status == SBTVaccinationOverdue) items++;
    return items;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SBTVaccineGridHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"vaccineHeader" forIndexPath:indexPath];
//    NSDictionary *vaccineRow = self.vaccinesGiven[indexPath.section];
//    NSString *compName = vaccineRow[COMPONENT_KEY];
//    header.componentName = compName;
//    SBTComponent c = (SBTComponent)[self.componentsByName[compName] integerValue];
//    NSDictionary *statusDict = [[SBTVaccineSchedule sharedSchedule] vaccinationStatusForVaccineComponent:c forBaby:self.baby];
//    header.status = (SBTVaccinationStatus)[statusDict[SBTVaccineSeriesStatusKey] integerValue];
    header.componentName = self.displayNamesForGrid[indexPath.section];
    header.status = [self statusForComponentNumber:self.componentsForGrid[indexPath.section][0]];
    return header;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SBTVaccineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"vaccineCell" forIndexPath:indexPath];
//    NSDictionary *vaccineRow = self.vaccinesGiven[indexPath.section];
//    cell.encounter = vaccineRow[ENCOUNTERS_KEY][indexPath.row];
    NSArray *encounters = self.gridModel[indexPath.section][SBTVaccineEncountersKey];
    if (indexPath.row == [encounters count]){
        // if we went out of bounds this means there is a due dose we need to show (it has no encounter)
        cell.encounter = nil;
    }else{
        cell.encounter = encounters[indexPath.row];
    }
    return cell;
}

#pragma mark - UICollectionView delegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.splitViewController){
        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
        [bgView setContentMode:UIViewContentModeScaleToFill];
        [self.view insertSubview:bgView atIndex:0];
    }
    [self.collectionView reloadData];
}

-(void)dealloc
{
    _dateFormatter = nil;
    _vaccinesGiven = nil;
    _componentsByName = nil;
    _componentsForGrid = nil;
    _displayNamesForGrid = nil;
    _gridModel = nil;
}

@end
