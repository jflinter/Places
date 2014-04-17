//
//  PLCMapViewController.m
//  Places
//
//  Created by Cameron Spickert on 4/17/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapViewController.h"
#import "PLCDatabase.h"
#import "PLCPlace.h"

@interface PLCMapViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;

@end

@implementation PLCMapViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self fetchPlaces];
}

#pragma mark -
#pragma mark Properties

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:self.database.mainContext sectionNameKeyPath:nil cacheName:@"Places"];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

#pragma mark -
#pragma mark Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"Controller changed content: %@", controller);
}

#pragma mark -
#pragma mark Helpers

- (void)fetchPlaces
{
    NSError *error = nil;
    BOOL fetchSuccess = [self.fetchedResultsController performFetch:&error];
    if (!fetchSuccess) {
        abort();
    }
}

- (NSFetchRequest *)fetchRequest
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[PLCPlace entityName]];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:PLCPlaceAttributes.latitude ascending:YES], [NSSortDescriptor sortDescriptorWithKey:PLCPlaceAttributes.longitude ascending:YES] ];
    return fetchRequest;
}

@end
