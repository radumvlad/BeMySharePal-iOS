//
//  SettingsViewController.h
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FriendSocket.h"

@interface SettingsViewController : UIViewController<GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;

@end
