//
//  NetworkTableViewCell.h
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (strong, nonatomic) NSDictionary *extraDict;

//@property (nonatomic) NSInteger numberOfAparitions;
//@property (strong, nonatomic) NSMutableArray *friends;

@end
