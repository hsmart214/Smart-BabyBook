//
//  SBTScannedVaccineDetailsTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTScannedVaccineDetailsTVC.h"

@interface SBTScannedVaccineDetailsTVC ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lotNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *componentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *ndcLabel;

@end

@implementation SBTScannedVaccineDetailsTVC

-(void)updateUI{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    NSString *formattedDate = [df stringFromDate:self.vaccine.expirationDate];
    self.nameLabel.text = self.vaccine.name;
    self.ndcLabel.text = self.vaccine.ndc;
    self.expDateLabel.text = formattedDate;
    self.lotNumberLabel.text = self.vaccine.lotNumber;
    self.componentsLabel.text = self.vaccine.componentString;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
    [self updateUI];
}

@end
