//
//  SBTAddScannedVaccinesTVC.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

#import "SBTAddScannedVaccinesTVC.h"
#import "SBTScannerViewController.h"
#import "SBTVaccine.h"

@interface SBTAddScannedVaccinesTVC ()<SBTCaptureDelegate>

@property (strong, nonatomic) NSMutableArray *addedVaccines;

@end

@implementation SBTAddScannedVaccinesTVC

#pragma mark - SBTCaptureDelegate

- (void) camera:(id)sender didCaptureBarcode:(AVMetadataMachineReadableCodeObject *)barcode{
    NSString *code = barcode.stringValue;
    
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return cell;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.addedVaccines removeObjectAtIndex:indexPath.row];
    }
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
}

- (IBAction)saveChanges:(id)sender {
}

- (IBAction)discardChanges:(id)sender {
}


@end
