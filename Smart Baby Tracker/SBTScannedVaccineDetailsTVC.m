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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUI];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.delegate isTooYoungForVaccine:self.vaccine] || [self.delegate isTooOldForVaccine:self.vaccine]){
        NSString *alertPhrase = [self.delegate isTooYoungForVaccine:self.vaccine] ? @"too young" : @"too old";
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:[NSString stringWithFormat:@"Child %@ for vaccine.", alertPhrase]
                                    message:@"This may be appropriate for epidemics or known exposure."
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    if ([self.delegate isExpiredVaccine:self.vaccine]){
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"Vaccine expired before date given."
                                    message:@"Please confirm dates."
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
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

@end
