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
#import "Firebase+Places.h"

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
@property (nonatomic, weak) UIActivityIndicatorView *activityIndicator;
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
    button.layer.cornerRadius = 6.0f;
    button.clipsToBounds = YES;
    self.imageButton = button;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [button setImage:self.place.image forState:UIControlStateNormal];
    if (!self.place.image && self.place.imageId) {
        [self.activityIndicator startAnimating];
        [[PLCPhotoStore new] fetchImageWithId:self.place.imageId
                                   completion:^(UIImage *image) {
                                       [self.activityIndicator stopAnimating];
                                       if (image) {
                                           [button setImage:image forState:UIControlStateNormal];
                                           [self updateInsets];
                                           self.imageButton.enabled = NO;
                                           self.imageButton.enabled = YES;
                                           self.activityIndicator.userInteractionEnabled = NO;
                                       }
                                   }];
    }
    [button addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.originalInsets = self.captionTextView.contentInset;
    self.originalInsets = ({
        UIEdgeInsets insets = self.originalInsets;
        insets.bottom += self.bottomToolbar.frame.size.height;
        insets;
    });
    self.captionTextView.scrollIndicatorInsets = UIEdgeInsetsMake(12, 0, self.originalInsets.bottom, 5);
    [self.captionTextView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize)) options:NSKeyValueObservingOptionNew context:NULL];
    [self.captionTextView addSubview:self.imageButton];
    [self.captionTextView addSubview:self.activityIndicator];
    self.activityIndicator.center = button.center;
    self.contentView.layer.cornerRadius = self.calloutView.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.bottomSpacingConstraint.constant = self.calloutView.arrowHeight;
    self.bottomToolbar.clipsToBounds = YES;
    self.captionTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    self.captionTextView.layer.cornerRadius = 5.0f;
    [self updateInsets];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self textViewDidChange:self.captionTextView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(__unused id)object change:(__unused NSDictionary *)change context:(__unused void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
        [self textViewDidChange:self.captionTextView];
    }
}

- (void)dealloc {
    [self.captionTextView removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentSize))];
}

- (void)updateInsets {
    if (self.activityIndicator.isAnimating || [self.imageButton imageForState:UIControlStateNormal]) {
        self.captionTextView.contentInset = ({
            UIEdgeInsets insets = self.originalInsets;
            insets.bottom += self.imageSize + 10;
            insets;
        });
    } else {
        self.captionTextView.contentInset = self.originalInsets;
    }
    if ([self.imageButton imageForState:UIControlStateNormal]) {
        if (self.imageButton.hidden) {
            self.imageButton.alpha = 0;
            self.imageButton.hidden = NO;
            [UIView animateWithDuration:0.2f animations:^{ self.imageButton.alpha = 1.0f; }];
        }
    } else {
        self.imageButton.hidden = YES;
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

- (IBAction)doneEditing:(__unused id)sender {
    if ([self.captionTextView isFirstResponder]) {
        [self.captionTextView resignFirstResponder];
    }
    [UIView animateWithDuration:0.3 animations:^{ self.bottomToolbar.alpha = 0; } completion:^(__unused BOOL finished) { self.bottomToolbar.hidden = YES; }];
}

// TODO: viewWillDisappear et. al. are not being called correctly; I think they should be used here instead.
- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    [self.captionTextView resignFirstResponder];
}

- (PLCCalloutView *)calloutView {
    return (PLCCalloutView *)self.view;
}

- (IBAction)deletePlace:(__unused id)sender {
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
        [[PLCPhotoStore new] addPhotoWithImage:image toPlace:self.place withUUID:[NSUUID UUID].UUIDString];
    } else {
        [[PLCPhotoStore new] removePhotoFromPlace:self.place];
    }
    [self.imageButton setImage:image forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (IBAction)choosePhoto:(__unused id)sender {
    [self.captionTextView resignFirstResponder];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (self.place.imageId) {
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Remove Photo", nil)
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(__unused UIAlertAction *action) {
                                                         [self imageSelected:nil];
                                                         [self updateInsets];
                                                     }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(__unused UIAlertAction *action) {
                                                         UIImagePickerController *imagePicker = [UIImagePickerController new];
                                                         imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                         imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                                                         imagePicker.delegate = self;
                                                         imagePicker.allowsEditing = YES;
                                                         [self.parentViewController presentViewController:imagePicker animated:YES completion:nil];
                                                     }]];
    }

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Library", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(__unused UIAlertAction *action) {
                                                         UIImagePickerController *imagePicker = [UIImagePickerController new];
                                                         imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                         imagePicker.delegate = self;
                                                         imagePicker.allowsEditing = YES;
                                                         [self.parentViewController presentViewController:imagePicker animated:YES completion:nil];
                                                     }]];
    }
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Image Search", nil)
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(__unused UIAlertAction *action) {
                                                     PLCFlickrSearchViewController *flickrController = [[PLCFlickrSearchViewController alloc]
                                                         initWithQuery:self.place.title
                                                                region:MKCoordinateRegionMakeWithDistance(self.place.coordinate, 500, 500)];
                                                     flickrController.delegate = self;
                                                     flickrController.modalPresentationStyle = UIModalPresentationCustom;
                                                     flickrController.transitioningDelegate = self;
                                                     [self.parentViewController presentViewController:flickrController animated:YES completion:nil];
                                                 }]];

    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{ [self editCaption]; }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
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

- (void)textViewDidChange:(__unused UITextView *)textView {
    self.imageButton.frame = ({
        CGRect rect = self.imageButton.frame;
        rect.origin.y = self.captionTextView.contentSize.height;
        rect;
    });
    self.activityIndicator.center = self.imageButton.center;
}

- (void)textViewDidBeginEditing:(__unused UITextView *)textView {
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
                                                      presentingViewController:(__unused UIViewController *)presenting
                                                          sourceViewController:(__unused UIViewController *)source {
    if ([presented isKindOfClass:[PLCFlickrSearchViewController class]]) {
        PLCBlurredModalPresentationController *controller =
            [[PLCBlurredModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:self];
        controller.edgeInsets = UIEdgeInsetsMake(10, 5, 0, 5);
        return controller;
    }
    return nil;
}

@end
