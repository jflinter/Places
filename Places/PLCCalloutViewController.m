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
#import <JTSImageViewController/JTSImageViewController.h>

@interface PLCCalloutViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIInputView *inputView;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryToolbar;
@property (nonatomic, weak) IBOutlet UIScrollView *contentView;
@property (nonatomic) UIEdgeInsets originalInsets;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (nonatomic, weak) UIButton *imageButton;
@end

@implementation PLCCalloutViewController

- (CGFloat)imageSize {
    return 180.0f;
}

+ (CGSize)calloutSize
{
    return CGSizeMake(310.0f, 310.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.captionTextView.text = self.place.caption;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.captionTextView.frame.size.width - self.imageSize)/2, 0, self.imageSize, self.imageSize)];
    self.imageButton = button;
    [button setImage:self.place.image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(imageTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.originalInsets = self.captionTextView.contentInset;
    self.originalInsets = ({
        UIEdgeInsets insets = self.originalInsets;
        insets.bottom += self.bottomToolbar.frame.size.height;
        insets;
    });
    [self.captionTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    [self.captionTextView addSubview:button];
    self.contentView.layer.cornerRadius = self.calloutView.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.bottomSpacingConstraint.constant = self.calloutView.arrowHeight;
    self.bottomToolbar.clipsToBounds = YES;
    self.captionTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    self.captionTextView.layer.cornerRadius = 5.0f;
    [self.accessoryToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.inputView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, 320, 37) inputViewStyle:UIInputViewStyleDefault];
    [self.inputView addSubview:self.accessoryToolbar];
    self.captionTextView.inputAccessoryView = self.inputView;
    [self updateInsets];
    [self.addressButton setTitle:[[self.place.geocodedAddress objectForKey:@"Street"] description] forState:UIControlStateNormal];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self textViewDidChange:self.captionTextView];
    }
}

- (void)updateInsets {
    if ([self.imageButton imageForState:UIControlStateNormal]) {
        self.captionTextView.contentInset = ({
            UIEdgeInsets insets = self.originalInsets;
            insets.bottom += self.imageSize + 10;
            insets;
        });
    }
    else {
        self.captionTextView.contentInset = self.originalInsets;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.contentView.contentSize = self.contentView.frame.size;
}

- (void)editCaption {
    [self.captionTextView becomeFirstResponder];
}

- (IBAction)doneEditing:(id)sender {
    if ([self.captionTextView isFirstResponder]) {
        [self.captionTextView resignFirstResponder];
    }
}

// TODO: viewWillDisappear et. al. are not being called correctly; I think they should be used here instead.
- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    [self.captionTextView resignFirstResponder];
}

- (PLCCalloutView *)calloutView
{
    return (PLCCalloutView *)self.view;
}

- (IBAction)deletePlace:(id)sender {
    [[PLCPlaceStore sharedInstance] removePlace:self.place];
}

- (IBAction)sharePlace:(id)sender {
    [self.captionTextView resignFirstResponder];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.place] applicationActivities:nil];
    //exclude the airdrop action because it's incredibly fucking slow and noone uses it
    NSMutableArray *excludedTypes = [@[UIActivityTypePrint,
                                       UIActivityTypeAirDrop] mutableCopy];
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
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = image;
    imageInfo.referenceRect = self.imageButton.frame;
    imageInfo.referenceView = self.imageButton.superview;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundStyle_ScaledDimmedBlurred];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void) imageSelected:(UIImage *)image {
    if (image) {
        [[PLCPhotoStore new] addPhotoWithImage:image toPlace:self.place];
    }
    else {
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
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    [actionSheet showInView:self.view.window];
    actionSheet.delegate = self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self imageSelected:nil];
        [self updateInsets];
        return;
    }
    if ([self.captionTextView isFirstResponder]) {
        [self.captionTextView resignFirstResponder];
    }
    UIImagePickerControllerSourceType sourceType;
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Take Photo", nil)]) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = YES;
    [self.parentViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.captionTextView becomeFirstResponder];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self imageSelected:image];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.captionTextView becomeFirstResponder];
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    [self updateInsets];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    NSCharacterSet *set = [NSCharacterSet newlineCharacterSet];
    NSRange newLineRange = [textView.text rangeOfCharacterFromSet:set];
    if (newLineRange.location != NSNotFound) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.captionTextView.attributedText];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0f] range:NSMakeRange( newLineRange.location, textView.text.length - newLineRange.location)];
        textView.attributedText = attributedString;
    }
    self.imageButton.frame = ({
        CGRect rect = self.imageButton.frame;
        rect.origin.y = self.captionTextView.contentSize.height;
        rect;
    });
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.place.caption = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithRange:NSMakeRange(NSAttachmentCharacter, 1)]];
    [[PLCPlaceStore sharedInstance] save];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.captionTextView) {
        return;
    }
    scrollView.contentOffset = CGPointZero;
}

@end
