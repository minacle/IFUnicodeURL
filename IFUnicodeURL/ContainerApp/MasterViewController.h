//
//  MasterViewController.h
//  ContainerApp
//
//  Created by John Brayton on 7/2/16.
//  Copyright © 2016 Jungle Candy Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;


@end

