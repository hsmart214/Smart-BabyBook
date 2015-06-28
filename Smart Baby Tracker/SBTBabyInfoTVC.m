//
//  SBTBabyInfoTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/15/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTBabyInfoTVC.h"
#import "SBTBaby.h"
#import "SBTEncountersTVC.h"
#import "SBTEncounterEditTVC.h"
#import "SBTGraphVC.h"
#import "SBTWHODataSource.h"
#import "SBTCDCDataSource.h"
#import "SBTVaccineGridViewController.h"

@interface SBTBabyInfoTVC ()<SBTBabyEditDelegate, SBTEncounterEditTVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *birthDateLable;
@property (weak, nonatomic) IBOutlet UILabel *birthTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *babyPic;
@property (weak, nonatomic) IBOutlet UILabel *numberOfEncountersLabel;
@property (weak, nonatomic) IBOutlet UILabel *growthChartDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *vaccineStatusLabel;

@end

@implementation SBTBabyInfoTVC

#pragma mark - Delegate methods

-(void)babyEditor:(id)babyEditor didSaveBaby:(SBTBaby *)baby
{
    self.baby = baby;
    [self.delegate babyEditor:babyEditor didSaveBaby:baby];
    [self updateDisplay];
}

-(void)SBTEncounterEditTVC:(SBTEncounterEditTVC *)editTVC updatedEncounter:(SBTEncounter *)encounter{
    //this will only add the encounter if it did not already exist
    [self.baby addEncounter:encounter];
    [self updateDisplay];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIPageViewControllerDelegate, UIPageViewControllerDataSource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return nil;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    return nil;
}

#pragma mark - view life cycle

-(void)updateDisplay
{
    [self setTitle:self.baby.name];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setCalendar:[NSCalendar currentCalendar]];
    [df setDateStyle:NSDateFormatterMediumStyle];
    [df setTimeStyle:NSDateFormatterNoStyle];
    NSString *dateString = [df stringFromDate:self.baby.DOB];
    self.birthDateLable.text = dateString;
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    NSString *timeString = [df stringFromDate:self.baby.DOB];
    self.birthTimeLabel.text = timeString;
    // put the number of encounters into the encounters cell label
    NSInteger num = [[self.baby encountersList] count];
    NSString *suffix = NSLocalizedString(@"events", @"events");
    self.numberOfEncountersLabel.text = [NSString stringWithFormat:@"%ld %@", (long)num, suffix];
    // put the data source (CDC/WHO) into the growth chart cell label
    suffix = NSLocalizedString(@"Data", @"Growth Data");
    SBTGrowthDataSource *infantSource = [SBTGrowthDataSource growthDataSourceForAge:1];
    SBTGrowthDataSource *childSource = [SBTGrowthDataSource growthDataSourceForAge:6 * 365];
    NSString *source1 = [infantSource isKindOfClass:[SBTWHODataSource class]] ? @"WHO" : @"CDC";
    NSString *source2 = [childSource isKindOfClass:[SBTWHODataSource class]] ? @"WHO" : @"CDC";
    self.growthChartDescriptionLabel.text = [NSString stringWithFormat:@"%@/%@ %@", source1, source2, suffix];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSAssert(self.baby != nil, @"No baby in Baby Info TVC");
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
    [self updateDisplay];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = self.baby.thumbnail;
    self.babyPic.image = image;
    [self updateDisplay];
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // this will prevent an error if we try to plot the growth and there is only one point to graph
    if ([identifier isEqualToString:@"showGrowthChart"]){
        return [self.baby.encountersList count] > 1;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editBabySegue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTBabyEditViewController *bevc = [nav.viewControllers firstObject];
        bevc.baby = self.baby;
        bevc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"List Encounters Segue"]
        || [segue.identifier isEqualToString:@"New Encounter Segue"]){
        SBTEncountersTVC *encTVC = segue.destinationViewController;
        encTVC.baby = self.baby;
        encTVC.delegate = self;
        if ([segue.identifier isEqualToString:@"New Encounter Segue"]){
            encTVC.addingNewEncounter = YES;
        }
    }
    if ([segue.identifier isEqualToString:@"showGrowthChart"]){
        SBTGraphVC *dest = segue.destinationViewController;
        dest.baby = self.baby;
        dest.growthDataSource = [SBTGrowthDataSource growthDataSourceForAge:[self.baby ageDDAtDate:[NSDate date]].day];
        dest.parameter = SBTWeight;
        // no need to set childChart to NO here - it is the default value
    }
    if ([segue.identifier isEqualToString:@"Vaccine Grid Segue"]){
        SBTVaccineGridViewController *dest = segue.destinationViewController;
        dest.baby = self.baby;
        dest.delegate = self;
    }
}

@end
