//
//  SettingsViewController.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.label.text =  [NSString stringWithFormat:@"Your local ip address is %@", [appdelegate getIPAddress:YES]];
}

@end
