//
//  SBTChildrenViewController.m
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 3/9/14.
//  Copyright (c) 2014 J. HOWARD SMART. All rights reserved.
//

#import "SBTChildrenViewController.h"
#import "SBTBaby.h"

@interface SBTChildrenViewController ()

@end

@implementation SBTChildrenViewController

-(NSMutableArray *)children
{
    if (!_children){
        _children = [NSMutableArray array];
    }
    return _children;
}

-(void)babyEditViewController:(SBTBabyEditViewController *)babyEditVC didSaveBaby:(SBTBaby *)baby
{
    [self.children addObject:baby];
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    NSDateComponents *comps = baby.DOBComponents;
    NSString *age;
    if (comps.year < 2){
        if (comps.year < 1){
            if (comps.month < 1){
                age = [NSString stringWithFormat:@"%d day", comps.day];
                if (comps.day > 1) age = [age stringByAppendingString:@"s"];
            }else{
                age = [NSString stringWithFormat:@"%d mo", comps.month];
                if (comps.month > 1) age = [age stringByAppendingString:@"s"];
            }
        }else{
            age = [NSString stringWithFormat:@"%d mos", comps.month];
        }
    }else{
        age = [NSString stringWithFormat:@"%d yrs", comps.year];
    }
    cell.detailTextLabel.text = age;
    
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
    if ([segue.identifier isEqualToString:@"New Child"]){
        [segue.destinationViewController setDelegate:self];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
