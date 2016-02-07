//
//  LocalTableViewCell.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "LocalTableViewCell.h"
#import "AppDelegate.h"

@implementation LocalTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)share:(id)sender {
    
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ([appdelegate.friends count] < 2) {
//        
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"You need at least 2 friends to share this file!" preferredStyle:UIAlertControllerStyleAlert];
//        
//        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//        [alertController addAction:ok];
//        
//        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *inboxDirectory = [NSString stringWithFormat:@"%@/Inbox", documentsDirectory];
    
    NSURL *pathURL = [NSURL fileURLWithPath:[inboxDirectory stringByAppendingPathComponent: self.titleLabel.text]];
    NSData *dataFile = [NSData dataWithContentsOfURL:pathURL];
    
    __block NSArray *arrDatas = [appdelegate divideData:dataFile inCount: (int)appdelegate.friends.count];

    
    for (int i = 0; i < [appdelegate.friends count]; i++) {
        
        FriendSocket *friendSocket = appdelegate.friends[i];
        
        if ([friendSocket.socket isConnected]) {
            [friendSocket.socket disconnect];
        }
        
        __weak FriendSocket *weakSocket = friendSocket;
        
        NSError *error = nil;
        friendSocket.connectCallback = ^{
            
            NSError *error = nil;
            NSData *dataFile = arrDatas[i];
            
            NSString *base64Encoded = [dataFile base64EncodedStringWithOptions:0];
        
        
            NSDictionary *bodyDict = @{@"command": COMMAND_SEND_FILE,
                                       @"file": base64Encoded,
                                       @"filename" : self.titleLabel.text};
        
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&error];
            if (error != nil) {
                NSLog(@"Error @parse %@", error);
                return;
            }
            
            [weakSocket.socket writeData:jsonData withTimeout:20 tag:0];
        };
        
        if (![friendSocket.socket connectToHost:friendSocket.host onPort:PORT withTimeout:5.0 error:&error]) {
            
            NSLog(@"Error connecting: %@", error);
        }
    }
    
}

@end
