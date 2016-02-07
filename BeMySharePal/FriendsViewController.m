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

@property (nonatomic, strong) NSArray *friendsArray;
@property (nonatomic) UITextField *alertTextField;

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.friendsArray = appdelegate.friends;
}

- (void)viewDidAppear:(BOOL)animated {
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    
    if (cell == nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"FriendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"FriendsTableViewCell"];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"FriendsTableViewCell"];
    }
    
    FriendSocket *fs = self.friendsArray[indexPath.row];
    cell.titleLabel.text = fs.host;
    
    return cell;
}

- (IBAction)addFriend:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Local IP" message:@"Enter your friend's local ip address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    alertView.delegate = self;
    
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 1) {
        UITextField *passwordTextField = [alertView textFieldAtIndex:0];
        
        FriendSocket *fs2 = [FriendSocket new];
        fs2.host = passwordTextField.text;
        fs2.socket = [[GCDAsyncSocket alloc] initWithDelegate:fs2 delegateQueue:dispatch_get_main_queue()];
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appdelegate.friends addObject:fs2];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });

}

@end
