//
//  PLCCalloutViewController.m
//  Places
//
//  Created by Jack Flintermann on 4/19/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCPlace.h"
#import "PLCCalloutView.h"
#import "PLCCalloutViewController.h"
#import "PLCPhotoStore.h"
#import "PLCPlaceStore.h"
#import "PLCPlaceTextStorage.h"
#import "PLCGoogleMapsActivity.h"
#import <JTSImageViewController/JTSImageViewController.h>
#import "PLCFlickrSearchViewController.h"
#import "PLCBlurredModalPresentationController.h"

@interface PLCCalloutViewController () <UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate,
                                        UIActionSheetDelegate,
                                        PLCFlickrSearchViewControllerDelegate,
                                        UIViewControllerTransitioningDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, weak) IBOutlet UIScrollView *contentView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) UIEdgeInsets originalInsets;
@property (weak, nonatomic) IBOutlet UITextField *placeTypeField;
@property (nonatomic, weak) UIButton *imageButton;
@property (nonatomic) PLCPlaceTextStorage *textStorage;
@end

@implementation PLCCalloutViewController

- (CGFloat)imageSize {
    return 120.0f;
}

+ (CGSize)calloutSize {
    return CGSizeMake(240.0f, 240.0f);
}

- (void)loadView {
    [super loadView];
    self.textStorage = [PLCPlaceTextStorage new];
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    [self.textStorage addLayoutManager:layoutManager];

    NSTextContainer *textContainer = [NSTextContainer new];
    [layoutManager addTextContainer:textContainer];

    UITextView *textView = [[UITextView alloc] initWithFrame:self.containerView.bounds textContainer:textContainer];

    textView.typingAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f] };
    textView.textContainerInset = UIEdgeInsetsMake(12, 15, 10, 15);
    textView.textAlignment = NSTextAlignmentCenter;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    textView.delegate = self;
    [self.containerView addSubview:textView];
    self.captionTextView = textView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.captionTextView.frame = self.captionTextView.superview.bounds;
    self.captionTextView.text = self.place.caption;
    UIButton *button =
        [[UIButton alloc] initWithFrame:CGRectMake((self.captionTextView.frame.size.width - self.imageSize) / 2, 0, self.imageSize, self.imageSize)];
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageButton = button;
    [button setImage:self.place.image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.originalInsets = self.captionTextView.contentInset;
    self.originalInsets = ({
        UIEdgeInsets insets = self.originalInsets;
        insets.bottom += self.bottomToolbar.frame.size.height;
        insets;
    });
    self.captionTextView.scrollIndicatorInsets = UIEdgeInsetsMake(12, 0, self.originalInsets.bottom, 5);
    [self.captionTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    [self.captionTextView addSubview:button];
    self.contentView.layer.cornerRadius = self.calloutView.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.bottomSpacingConstraint.constant = self.calloutView.arrowHeight;
    self.bottomToolbar.clipsToBounds = YES;
    self.captionTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    self.captionTextView.layer.cornerRadius = 5.0f;
    [self updateInsets];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self textViewDidChange:self.captionTextView];
    }
}

- (void)dealloc {
    [self.captionTextView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)updateInsets {
    if ([self.imageButton imageForState:UIControlStateNormal]) {
        self.imageButton.hidden = NO;
        self.captionTextView.contentInset = ({
            UIEdgeInsets insets = self.originalInsets;
            insets.bottom += self.imageSize + 10;
            insets;
        });
    } else {
        self.imageButton.hidden = YES;
        self.captionTextView.contentInset = self.originalInsets;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.contentView.contentSize = self.contentView.frame.size;
}

- (void)editCaption {
    [self.captionTextView becomeFirstResponder];
    self.bottomToolbar.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{ self.bottomToolbar.alpha = 1.0f; }];
}

- (IBAction)doneEditing:(id)sender {
    if ([self.captionTextView isFirstResponder]) {
        [self.captionTextView resignFirstResponder];
    }
    [UIView animateWithDuration:0.3 animations:^{ self.bottomToolbar.alpha = 0; } completion:^(BOOL finished) { self.bottomToolbar.hidden = YES; }];
}

// TODO: viewWillDisappear et. al. are not being called correctly; I think they should be used here instead.
- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    [self.captionTextView resignFirstResponder];
}

- (PLCCalloutView *)calloutView {
    return (PLCCalloutView *)self.view;
}

- (IBAction)deletePlace:(id)sender {
    [[PLCPlaceStore sharedInstance] removePlace:self.place];
}

- (IBAction)sharePlace:(id)sender {
    [self doneEditing:sender];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.place.coordinate addressDictionary:self.place.geocodedAddress];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[self.place, mapItem] applicationActivities:@[[PLCGoogleMapsActivity new]]];
    // exclude the airdrop action because it's incredibly fucking slow and noone uses it
    NSMutableArray *excludedTypes = [@[UIActivityTypePrint, UIActivityTypeAirDrop] mutableCopy];
    if (!self.place.geocodedAddress) {
        [excludedTypes addObject:UIActivityTypeMessage];
    }
    if (!self.place.image) {
        [excludedTypes addObject:UIActivityTypeAssignToContact];
    }
    activityViewController.excludedActivityTypes = [excludedTypes copy];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)imageTapped:(UIButton *)sender {
    UIImage *image = [sender imageForState:UIControlStateNormal];
    if (!image) {
        return;
    }
    sender.selected = NO;
    sender.highlighted = NO;
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = image;
    imageInfo.referenceRect = self.imageButton.frame;
    imageInfo.referenceView = self.imageButton.superview;

    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                       mode:JTSImageViewControllerMode_Image
                                                                            backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];

    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)imageSelected:(UIImage *)image {
    if (image) {
        [[PLCPhotoStore new] addPhotoWithImage:image toPlace:self.place];
    } else {
        [[PLCPhotoStore new] removePhotoFromPlace:self.place];
    }
    [self.imageButton setImage:image forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (IBAction)choosePhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    if (self.place.image) {
        actionSheet.destructiveButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Remove Photo", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Take Photo", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Choose From Library", nil)];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Search Flickr", nil)];
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showInView:self.view.window];
    actionSheet.delegate = self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self imageSelected:nil];
        [self updateInsets];
        return;
    }
    [self doneEditing:nil];
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Search Flickr", nil)]) {
        PLCFlickrSearchViewController *controller =
            [[PLCFlickrSearchViewController alloc] initWithQuery:self.place.title region:MKCoordinateRegionMakeWithDistance(self.place.coordinate, 500, 500)];
        controller.delegate = self;
        controller.modalPresentationStyle = UIModalPresentationCustom;
        controller.transitioningDelegate = self;
        [UIView animateWithDuration:0.2
            animations:^{ [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO]; }
            completion:^(BOOL finished) { [self.parentViewController presentViewController:controller animated:YES completion:nil]; }];
        return;
    }
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [self.parentViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)cancelFlickr:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{ [self editCaption]; }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self imageSelected:image];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{ [self editCaption]; }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [self updateInsets];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.imageButton.frame = ({
        CGRect rect = self.imageButton.frame;
        rect.origin.y = self.captionTextView.contentSize.height;
        rect;
    });
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.bottomToolbar.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{ self.bottomToolbar.alpha = 1.0f; }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.place.caption = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithRange:NSMakeRange(NSAttachmentCharacter, 1)]];
    [[PLCPlaceStore sharedInstance] save];
    [textView setContentOffset:CGPointZero animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.captionTextView) {
        return;
    }
    scrollView.contentOffset = CGPointZero;
}

#pragma mark -
#pragma mark - PLCFlickrSearchCollectionViewControllerDelegate

- (void)controller:(PLCFlickrSearchViewController *)controller didFinishWithImage:(UIImage *)image {
    if (image) {
        [self imageSelected:image];
    }
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:^{ [self editCaption]; }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self updateInsets];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {
    if ([presented isKindOfClass:[PLCFlickrSearchViewController class]]) {
        PLCBlurredModalPresentationController *controller =
            [[PLCBlurredModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:self];
        controller.edgeInsets = UIEdgeInsetsMake(10, 5, 0, 5);
        return controller;
    }
    return nil;
}

@end
