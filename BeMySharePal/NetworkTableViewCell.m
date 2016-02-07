//
//  NetworkTableViewCell.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "NetworkTableViewCell.h"
#import "AppDelegate.h"

@implementation NetworkTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)download:(id)sender {
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    for (__block FriendSocket *friendSocket in self.extraDict[@"friends"]) {
        
        if ([friendSocket.socket isConnected]) {
            [friendSocket.socket disconnect];
        }
        
        NSError *error = nil;
        friendSocket.connectCallback = ^{
            
            NSError *error = nil;
            NSURL *pathURL = [[NSBundle mainBundle] URLForResource:@"file" withExtension:@"txt"];
            NSData *dataFile = [NSData dataWithContentsOfURL:pathURL];
            NSString *base64Encoded = [dataFile base64EncodedStringWithOptions:0];
            
            
            NSDictionary *bodyDict = @{@"command": COMMAND_REQ_FILE,
                                       @"filename" : self.titleLabel.text};
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&error];
            if (error != nil) {
                NSLog(@"Error @parse %@", error);
                return;
            }
            
            [friendSocket.socket writeData:jsonData withTimeout:20 tag:0];
            [friendSocket.socket readDataWithTimeout:20 tag:0];
        };
        
        if (![friendSocket.socket connectToHost:friendSocket.host onPort:PORT withTimeout:5.0 error:&error]) {
            
            NSLog(@"Error connecting: %@", error);
        }
    }
    
}

@end
