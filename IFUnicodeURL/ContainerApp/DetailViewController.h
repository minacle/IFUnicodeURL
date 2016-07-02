//
//  DetailViewController.h
//  ContainerApp
//
//  Created by John Brayton on 7/2/16.
//  Copyright © 2016 Jungle Candy Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

