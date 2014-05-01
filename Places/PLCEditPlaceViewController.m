//
//  PLCEditPlaceViewController.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "PLCEditPlaceViewController.h"
#import "PLCPhotoStore.h"
#import "PLCPlaceStore.h"

@interface PLCEditPlaceViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, readonly, strong) PLCPlaceStore *placeStore;
@end

@implementation PLCEditPlaceViewController

@synthesize placeStore = _placeStore;

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView.image = self.place.image;
}

- (void)setPlace:(PLCPlace *)place {
    _place = place;
    self.imageView.image = place.image;
}

#pragma mark -
#pragma mark UIImagePickerController

- (IBAction)choosePhoto:(id)sender {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    [self.view.window.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)deletePlace:(id)sender {
    [self.placeStore removePlace:self.place];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    [[PLCPhotoStore new] addPhotoWithImage:image toPlace:self.place];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (PLCPlaceStore *)placeStore {
    if (!_placeStore) {
        _placeStore = [PLCPlaceStore new];
    }
    return _placeStore;
}


@end
