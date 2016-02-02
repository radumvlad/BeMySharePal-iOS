//
//  NetworkViewController.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "NetworkViewController.h"

@interface NetworkViewController ()

@property (nonatomic, strong) NSArray *networkFilesArray;

@end

@implementation NetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.networkFilesArray = @[@"NFile 1", @"NFile 2", @"NFile 3"];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.networkFilesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NetworkTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NetworkTableViewCell"];
    
    if (cell == nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"NetworkTableViewCell" bundle:nil] forCellReuseIdentifier:@"NetworkTableViewCell"];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NetworkTableViewCell"];
    }
    
    
    cell.titleLabel.text = self.networkFilesArray[indexPath.row];
    
    return cell;
}

@end
