//
//  LocalViewController.m
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import "LocalViewController.h"

@interface LocalViewController ()

@property (nonatomic, strong) NSArray *localResourcesArray;

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.localResourcesArray = @[@"File 1", @"File 2", @"File 3"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.localResourcesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    LocalTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocalTableViewCell"];
    
    if (cell == nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"LocalTableViewCell" bundle:nil] forCellReuseIdentifier:@"LocalTableViewCell"];
        
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocalTableViewCell"];
    }
    
    
    cell.titleLabel.text = self.localResourcesArray[indexPath.row];
    
    //configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]]];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    
    return cell;
}

@end
