//
//  SBTChildrenViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTChildrenViewController.h"
#import "SBTBaby.h"
#import "SBTBabyInfoTVC.h"
#import "SBTBabyEditViewController.h"
#import "SBTDataStore.h"

@interface SBTChildrenViewController ()

@end

@implementation SBTChildrenViewController

-(void)babyEditor:(id)babyEditor didSaveBaby:(SBTBaby *)baby
{
    [[SBTDataStore sharedStore] storeBaby:baby];
    self.children = [[SBTDataStore sharedStore] storedBabies];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : [self.children count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        return 160.0;
    }else{
        return UITableViewAutomaticDimension;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 1 ? NSLocalizedString(@"Children", @"Children - for the list of kids' names") : nil;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0){
        cell =[tableView dequeueReusableCellWithIdentifier:@"Main Info Cell" forIndexPath:indexPath];
    }else{
        static NSString *CellIdentifier = @"Child Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        SBTBaby *baby = self.children[indexPath.row];
        cell.textLabel.text = baby.name;
        cell.detailTextLabel.text = [baby ageDescriptionAtDate:[NSDate date]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView beginUpdates];
        [[SBTDataStore sharedStore] removeBaby:self.children[indexPath.row]];
        self.children = [[SBTDataStore sharedStore] storedBabies];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addBabySegue"]){
        UINavigationController *nav = segue.destinationViewController;
        SBTBabyEditViewController *bevc = nav.viewControllers[0];
        [bevc setDelegate:self];
        __weak SBTChildrenViewController *myWeakSelf = self;
        [bevc setDismissBlock:^{
            [myWeakSelf.tableView reloadData];
        }];
    }else if ([segue.identifier isEqualToString:@"showBabyInfo"]){
        SBTBabyInfoTVC *dest = segue.destinationViewController;
        NSIndexPath *ip = [self.tableView indexPathForCell:sender];
        SBTBaby *baby = self.children[ip.row];
        [dest setBaby:baby];
        dest.delegate = self;
    }
}

#pragma mark - View Life Cycyle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.splitViewController){
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPhoneBackgroundImage]];
    }else{
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:SBTiPadMasterBackgroundImage]];
    }
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.children = [[SBTDataStore sharedStore] storedBabies];
}


@end
