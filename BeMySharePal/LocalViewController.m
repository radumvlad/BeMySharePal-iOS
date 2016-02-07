//
//  LocalViewController.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "LocalViewController.h"
#import "AppDelegate.h"

@interface LocalViewController ()

@property (nonatomic, strong) NSArray *localResourcesArray;

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {
    
    [self refreshLocalFilesArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshLocalFilesArray)
                                                 name:NEW_FILE_NOTIFICATION object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshLocalFilesArray {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *inboxDirectory = [NSString stringWithFormat:@"%@/Inbox", documentsDirectory];
    
    self.localResourcesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:inboxDirectory
                                                                                   error:NULL].mutableCopy;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.localResourcesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocalTableViewCell"];
    
    if (cell == nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"LocalTableViewCell" bundle:nil] forCellReuseIdentifier:@"LocalTableViewCell"];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocalTableViewCell"];
    }
    
    
    cell.titleLabel.text = self.localResourcesArray[indexPath.row];
    
    MGSwipeButton *shareButton = [MGSwipeButton buttonWithTitle:@"Load" backgroundColor:[UIColor blueColor] callback:^BOOL(MGSwipeTableCell *sender) {

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *inboxDirectory = [NSString stringWithFormat:@"%@/Inbox", documentsDirectory];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", inboxDirectory, self.localResourcesArray[indexPath.row]];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        controller.excludedActivityTypes = @[UIActivityTypeAirDrop];
        controller.completionWithItemsHandler = ^(NSString* activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            NSLog(@"ashdfihansdf");
        };
        
        // Present the controller
        [self presentViewController:controller animated:YES completion:nil];
        return YES;
    }];
    
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *inboxDirectory = [NSString stringWithFormat:@"%@/Inbox", documentsDirectory];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", inboxDirectory, self.localResourcesArray[indexPath.row]];

        NSLog(@"Deleting file at path %@", filePath);
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        NSError *error = nil;
        [manager removeItemAtPath:filePath error:&error];

        if (error) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:[NSString stringWithFormat:@"Could not delete file %@ due to error %@", self.localResourcesArray[indexPath.row], error] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
            return NO;
        }
        
        [self refreshLocalFilesArray];
        
        return YES;
    }];
    
    cell.leftButtons = @[shareButton];
    cell.leftSwipeSettings.transition = MGSwipeTransition3D;
    
    cell.rightButtons = @[deleteButton];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    cell.localTableCellDelegate = self;
    
    return cell;
}

#pragma mark LocalTableViewCellDelegate

- (void)shareFailed {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"You need at least 2 friends to share this file!" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];

    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
