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
#import "SBTChildCell.h"

@interface SBTChildrenViewController ()

@end

@implementation SBTChildrenViewController

#pragma mark - Baby Edit Delegate

-(void)babyEditor:(id)babyEditor didSaveBaby:(SBTBaby *)baby
{
    [[SBTDataStore sharedStore] storeBaby:baby];
    self.children = [[SBTDataStore sharedStore] storedBabies];
    [self.tableView reloadData];
}

-(void)babyEditor:(id)babyEditor didRenameBaby:(SBTBaby *)baby
      fromOldName:(NSString *)oldName
        toNewName:(NSString *)newName{
    // here, even though the baby is the same shared reference, once it has been renamed, it is still stored in the dictionary
    // of the DataStore under the old name. Just saving the baby will not remove this reference. Deleting the reference under the old key
    // will not delete the Baby object, but it will reduce its reference count.
    // This prevents us having two keys referring to the same Baby in the DataStore, which would make the same baby appear twice on the home
    // screen, once under the old name, even thought the name woud show up correctly if you tap on the row.
    [[SBTDataStore sharedStore] removeBabyByName:oldName];
    [[SBTDataStore sharedStore] storeBaby:baby];
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

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        return 160.0;
    }else{
        //return UITableViewAutomaticDimension;
        return 88.0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 0.0 : 44.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) return nil;
    UILabel *headerLabel = [[UILabel alloc] init];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setText:NSLocalizedString(@"Children", @"Children - for the list of kids' names")];
    [headerLabel setFont:[UIFont boldSystemFontOfSize:17.0]];
    return headerLabel;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SBTChildCell *cell;
    if (indexPath.section == 0){
        cell =[tableView dequeueReusableCellWithIdentifier:@"Main Info Cell" forIndexPath:indexPath];
    }else{
        static NSString *CellIdentifier = @"Child Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        SBTBaby *baby = self.children[indexPath.row];
        cell.name.text = baby.name;
        cell.ageLabel.text = [baby ageDescriptionAtDate:[NSDate date]];
        cell.dobLabel.text = baby.dobDescription;
        cell.thumbnailView.image = baby.thumbnail;
        cell.baby = baby;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addBabySegue"]){
        // I have run into problems downstream if no valid baby instance is sent to the new baby creation machine.
        SBTBaby *baby = [[SBTBaby alloc] initWithName:NSLocalizedString(@"New Baby", @"New Baby name") andDOB:[NSDate dateWithTimeIntervalSince1970:0.0]];
        UINavigationController *nav = segue.destinationViewController;
        SBTBabyEditViewController *bevc = nav.viewControllers[0];
        bevc.baby = baby;
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
