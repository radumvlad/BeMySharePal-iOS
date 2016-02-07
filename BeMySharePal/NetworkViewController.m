//
//  NetworkViewController.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "NetworkViewController.h"
#import "AppDelegate.h"

@interface NetworkViewController ()

@property (nonatomic, strong) NSMutableDictionary *networkFilesDictionary;

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.networkFilesDictionary = @{}.mutableCopy;
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    for (FriendSocket *friendSocket in appdelegate.friends) {
        
        if ([friendSocket.socket isConnected]) {
            [friendSocket.socket disconnect];
        }
        
        __weak FriendSocket *weakFriendSocket = friendSocket;
        
        NSError *error = nil;
        friendSocket.connectCallback = ^{
            
            NSLog(@"calling callback from connect");
            
            NSError *error = nil;
            NSDictionary *bodyDict = @{@"command": COMMAND_REQ_FILE_ARRAY};
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&error];
            if (error != nil) {
                NSLog(@"Error @parse %@", error);
                return;
            }
            
            [weakFriendSocket.socket writeData:jsonData withTimeout:5 tag:0];
            [weakFriendSocket.socket readDataWithTimeout:5 tag:0];
        };
        
        if (! [friendSocket.socket connectToHost:friendSocket.host onPort:PORT withTimeout:5.0 error:&error]) {
            
            NSLog(@"Error connecting: %@", error);
        }
    }
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshNetworkFilesArray:)
                                                 name:NEW_NETWORK_FILES object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedFileRequest:)
                                                 name:REQUESTED_FILE_RECEIVED object:nil];

   
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)receivedFileRequest:(NSNotification *)notification {
    
    NSDictionary *newFileReceived = notification.object;
    
    if (self.currentFileModel == nil || self.currentFileModel.title != newFileReceived[@"filename"]) {
        
        self.currentFileModel = [FileModel new];
        self.currentFileModel.title = newFileReceived[@"filename"];
        self.currentFileModel.references = [NSMutableArray new];
    }
    
    [self.currentFileModel.references addObject:newFileReceived[@"file"]];
    
    if ([self.currentFileModel.references count] >= 2) {
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSData *share1 = self.currentFileModel.references[0];
        NSData *share2 = self.currentFileModel.references[1];
    
        NSData *result = [appdelegate reconstructDataFrom:share1 and:share2];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:self.currentFileModel.title];
        [result writeToFile:filePath atomically:YES];
    }
}

- (void)refreshNetworkFilesArray:(NSNotification *)notification {
    
    NSDictionary *dict = notification.object;
    
    NSArray *arr = dict[@"files"];
    
    for (NSString *str in arr) {
        
        NSInteger numberOfApparitions = 0;
        NSMutableArray *references = @[].mutableCopy;
        
        if (self.networkFilesDictionary[str] != nil) {
            numberOfApparitions = [self.networkFilesDictionary[str][@"aparitions"] integerValue];
            references = self.networkFilesDictionary[str][@"friends"];
        }
        
        [references addObject: dict[@"friend"]];
        
        self.networkFilesDictionary[str] = @{@"aparitions" : @(numberOfApparitions),
                                             @"friends" : references};
    }
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.networkFilesDictionary.allKeys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NetworkTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NetworkTableViewCell"];
    
    if (cell == nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"NetworkTableViewCell" bundle:nil] forCellReuseIdentifier:@"NetworkTableViewCell"];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NetworkTableViewCell"];
    }
    
    NSString *key = self.networkFilesDictionary.allKeys[indexPath.row];
    
    cell.titleLabel.text = key;
    cell.extraDict = self.networkFilesDictionary[key];
    
    if ([cell.extraDict[@"aparitions"] intValue] < 2) {
        cell.downloadButton.hidden = YES;
    }
    else {
        cell.downloadButton.hidden = NO;
    }
    
    return cell;
}

@end
