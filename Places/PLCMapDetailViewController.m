//
//  PLCMapDetailViewController.m
//  Places
//
//  Created by Jack Flintermann on 6/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapDetailViewController.h"
#import "PLCMap.h"

@interface PLCMapDetailViewController ()

@end

@implementation PLCMapDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)shareMap:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[self.map shareURL]] applicationActivities:nil];
    //exclude the airdrop action because it's incredibly fucking slow and noone uses it
    activityViewController.excludedActivityTypes = @[UIActivityTypePrint,
                                                     UIActivityTypeAirDrop];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    self.navigationItem.title = self.map.name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.clipsToBounds = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
