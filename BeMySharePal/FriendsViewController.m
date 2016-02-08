//
//  ViewController.m
//  BeMySharePal
//
//  Created by Radu on 01/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "FriendsViewController.h"
#import "AppDelegate.h"

@interface FriendsViewController ()

@property (nonatomic) UITextField *alertTextField;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return [appdelegate.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    
    if (cell == nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"FriendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendsTableViewCell"];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    }
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    FriendSocket *fs = appdelegate.friends[indexPath.row];
    cell.titleLabel.text = fs.name;
    
    MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate.friends removeObjectAtIndex:indexPath.row];
        [appdelegate saveFriends];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        return YES;
    }];
    
    cell.rightButtons = @[deleteButton];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    
    return cell;
}

- (IBAction)addFriend:(id)sender {
    
    __block UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add friend" message:@"Please specify your friend's informations!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        FriendSocket *fs2 = [FriendSocket new];
        fs2.socket = [[GCDAsyncSocket alloc] initWithDelegate:fs2 delegateQueue:dispatch_get_main_queue()];
        
        for (UITextField *textField in alertController.textFields) {
            
            if (textField.tag == 1) {
                fs2.name = textField.text;
            }
            else if(textField.tag == 2) {
                fs2.host = textField.text;
            }
        }
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate.friends addObject:fs2];
        [appdelegate saveFriends];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [alertController addAction:cancel];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.tag = 1;
        textField.placeholder = @"Name";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.tag = 2;
        textField.placeholder = @"Local IP";
        textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
