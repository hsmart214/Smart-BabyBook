//
//  SBTAddScannedVaccinesTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTAddScannedVaccinesTVC.h"
#import "SBTScannedVaccineDetailsTVC.h"
#import "SBTScannerViewController.h"
#import "SBTVaccinesGivenTVC.h"
#import "SBTVaccine.h"

@interface SBTAddScannedVaccinesTVC ()<SBTCaptureDelegate>

@property (strong, nonatomic) NSMutableArray *addedVaccines; // array of SBTVaccine

@end

@implementation SBTAddScannedVaccinesTVC

#pragma mark - SBTCaptureDelegate

- (void) camera:(id)sender didCaptureBarcode:(AVMetadataMachineReadableCodeObject *)barcode{
    SBTVaccine *newVacc = [[SBTVaccine alloc] initWithBarcode:barcode.stringValue];
    [self.addedVaccines addObject:newVacc];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - View controller lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadDetailBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }
    self.addedVaccines = [NSMutableArray arrayWithArray:[self.currentVaccines allObjects]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addedVaccines count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Additional Vaccine" forIndexPath:indexPath];
    SBTVaccine *vacc = self.addedVaccines[indexPath.row];
    cell.textLabel.text = vacc.name;
    cell.detailTextLabel.text = vacc.componentString;
    return cell;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.addedVaccines removeObjectAtIndex:indexPath.row];
        [tableView endUpdates];
    }
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"Show Vaccine Details"]){
        SBTScannedVaccineDetailsTVC *dest = segue.destinationViewController;
        NSIndexPath *ip = [self.tableView indexPathForCell:sender];
        dest.vaccine = self.addedVaccines[ip.row];
    }
    if ([segue.identifier isEqual:@"Full List Segue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTVaccinesGivenTVC *dest = [nav.viewControllers firstObject];
        dest.vaccinesGiven = [NSMutableSet setWithArray:self.addedVaccines];
    }
    if ([segue.identifier isEqualToString:@"Scan Barcode"]){
        SBTScannerViewController *dest = segue.destinationViewController;
        dest.delegate = self;
    }
}

- (IBAction)saveChanges:(id)sender {
    
}

- (IBAction)discardChanges:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
