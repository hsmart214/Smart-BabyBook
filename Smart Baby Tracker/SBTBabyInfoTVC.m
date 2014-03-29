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
#import "SBTGraphViewController.h"
#import "SBTWHODataSource.h"
#import "SBTCDCDataSource.h"

@interface SBTBabyInfoTVC ()<SBTBabyEditDelegate>
@property (weak, nonatomic) IBOutlet UILabel *birthDateLable;
@property (weak, nonatomic) IBOutlet UILabel *birthTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *babyPic;
@property (weak, nonatomic) IBOutlet UILabel *numberOfEncountersLabel;
@property (weak, nonatomic) IBOutlet UILabel *growthChartDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *vaccineStatusLabel;

@end

@implementation SBTBabyInfoTVC

#pragma mark - SBTBabyEditDelegate methods

-(void)babyEditor:(id)babyEditor didSaveBaby:(SBTBaby *)baby
{
    self.baby = baby;
    [self.delegate babyEditor:babyEditor didSaveBaby:baby];
    [self updateDisplay];
}

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
    NSInteger num = [[self.baby encountersList] count];
    NSString *suffix = NSLocalizedString(@"encounters", @"encounters");
    self.numberOfEncountersLabel.text = [NSString stringWithFormat:@"%ld %@", (long)num, suffix];
}

-(void)viewDidLoad
{
    NSAssert(self.baby != nil, @"No baby in Baby Info TVC");
    [self updateDisplay];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIImage *image = self.baby.thumbnail;
    self.babyPic.image = image;
    [self updateDisplay];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editBabySegue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTBabyEditViewController *bevc = [nav.viewControllers firstObject];
        bevc.baby = self.baby;
        bevc.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"List Encounters Segue"]){
        SBTEncountersTVC *encTVC = segue.destinationViewController;
        encTVC.baby = self.baby;
        encTVC.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"showGrowthChart"]){
        SBTGraphViewController *dest = segue.destinationViewController;
        dest.baby = self.baby;
        dest.growthDataSource = [SBTCDCDataSource sharedDataSource];
        dest.parameter = SBTWeight;
    }
}


@end
