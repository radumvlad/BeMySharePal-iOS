//
//  LocalTableViewCell.h
//  BeMySharePal
//
//  Created by Radu on 02/02/16.
//  Copyright © 2016 FMI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MGSwipeTableCell/MGSwipeTableCell.h>


@protocol LocalTableViewCellDelegate <NSObject>

- (void)shareFailed;

@end


@interface LocalTableViewCell : MGSwipeTableCell


@property (strong, nonatomic) id<LocalTableViewCellDelegate> localTableCellDelegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end
