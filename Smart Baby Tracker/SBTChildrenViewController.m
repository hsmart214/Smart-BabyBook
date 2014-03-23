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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.children = [[SBTDataStore sharedStore] storedBabies];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Child Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SBTBaby *baby = self.children[indexPath.row];
    cell.textLabel.text = baby.name;
    cell.detailTextLabel.text = [baby ageDescriptionAtDate:[NSDate date]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
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

@end
