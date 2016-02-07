//
//  ViewController.h
//  BeMySharePal
//
//  Created by Radu on 01/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsTableViewCell.h"



@interface FriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

