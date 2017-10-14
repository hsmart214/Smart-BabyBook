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
#import "SBTVaccineSchedule.h"

@interface SBTAddScannedVaccinesTVC ()<SBTCaptureDelegate, SBTVaccinesGivenTVCDelegate>

@property (strong, nonatomic) NSMutableArray *addedVaccines; // array of SBTVaccine

@end

@implementation SBTAddScannedVaccinesTVC

#pragma mark - SBTCaptureDelegate

- (void) camera:(id)sender didCaptureBarcode:(AVMetadataMachineReadableCodeObject *)barcode{
    SBTVaccine *newVacc = [[SBTVaccine alloc] initWithBarcode:barcode.stringValue];
    if (newVacc) {
        [self.addedVaccines addObject:newVacc];
    }else{
        NSString *ndc = [SBTVaccine ndcFromBarcode:barcode.stringValue];
        NSString *message = [NSString stringWithFormat:@"No info for NDC %@", ndc];
        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unrecognized Barcode." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Unrecognized Barcode."
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:dismissAction];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - SBTVaccinesGivenTVCDelegate

// the complication here is that the VaccinesGivenTVC only keep names of vaccines
// if we only took back the names we would lose the scanned information we already have
// so we need to first save any scanned vaccines
-(void)vaccinesGivenTVC:(SBTVaccinesGivenTVC *)vaccinesGivenTVC updatedVaccines:(NSSet *)newVaccineSet{
    NSMutableArray *modifiedVaccines = [NSMutableArray array];
    // run through the previous list of scanned vaccines and save any that are still
    // in the list of names returned from the TVC
    for (SBTVaccine *vac in self.addedVaccines){
        BOOL present = NO;
        for (SBTVaccine *newVac in newVaccineSet){
            present = present || [vac.name isEqualToString:newVac.name];
        }
        if (present){
            [modifiedVaccines addObject:vac];
        }
    }
    // then run through the new vaccines and add any vaccines not already in the list
    for (SBTVaccine *newVac in newVaccineSet){
        BOOL present = NO;
        for (SBTVaccine *oldVac in modifiedVaccines){
            present = present || [newVac.name isEqualToString:oldVac.name];
        }
        if (!present){
            [modifiedVaccines addObject:newVac];
        }
    }
    self.addedVaccines = modifiedVaccines;
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(BOOL)vaccineIsTooEarly:(SBTVaccine *)vaccine
{
    return [self.delegate isTooYoungForVaccine:vaccine];
}

-(BOOL)babyIsTooOldForVaccine:(SBTVaccine *)vaccine
{
    return [self.delegate isTooOldForVaccine:vaccine];
}

#pragma mark - View controller lifecycle

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.goStraightToCamera){
        [self performSegueWithIdentifier:@"Scan Barcode" sender:self];
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
        dest.delegate = self.delegate;
    }
    if ([segue.identifier isEqual:@"Full List Segue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTVaccinesGivenTVC *dest = [nav.viewControllers firstObject];
        dest.vaccinesGiven = [NSMutableSet setWithArray:self.addedVaccines];
        dest.delegate = self;
    }
    if ([segue.identifier isEqualToString:@"Scan Barcode"]){
        SBTScannerViewController *dest = segue.destinationViewController;
        dest.delegate = self;
        self.goStraightToCamera = NO;
    }
}

- (IBAction)saveChanges:(id)sender {
    NSSet *vaccineSet = [NSSet setWithArray:self.addedVaccines];
    [self.delegate addScannedVaccinesTVC:self addedVaccines:vaccineSet];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)discardChanges:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc{
    self.addedVaccines = nil;
}

@end
