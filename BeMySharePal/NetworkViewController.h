//
//  NetworkViewController.h
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkTableViewCell.h"
#import "FileModel.h"

@interface NetworkViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FileModel *currentFileModel;

@end
