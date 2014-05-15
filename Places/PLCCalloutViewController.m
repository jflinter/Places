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

@interface PLCCalloutViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, readonly) PLCPlaceStore *placeStore;
@end

@implementation PLCCalloutViewController

@synthesize placeStore = _placeStore;

+ (CGSize)calloutSize
{
    return CGSizeMake(300.0f, 300.0f);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentView.layer.cornerRadius = self.calloutView.cornerRadius;
    self.contentView.layer.masksToBounds = YES;
    self.bottomSpacingConstraint.constant = self.calloutView.arrowHeight;
    self.placeImageView.image = self.place.image;
    self.bottomToolbar.clipsToBounds = YES;
    self.captionTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    self.captionTextView.layer.cornerRadius = 5.0f;
    self.captionTextView.text = self.place.caption;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self resizeTextView:self.captionTextView];
}

- (void)editCaption {
    [self.captionTextView becomeFirstResponder];
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
    [self.placeStore removePlace:self.place];
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

- (PLCPlaceStore *)placeStore {
    if (!_placeStore) {
        _placeStore = [PLCPlaceStore new];
    }
    return _placeStore;
}

- (void) imageSelected:(UIImage *)image {
    [[PLCPhotoStore new] addPhotoWithImage:image toPlace:self.place];
    self.placeImageView.image = image;
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
    if ([self.captionTextView isFirstResponder]) {
        [self.captionTextView resignFirstResponder];        
    }
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        [self imageSelected:nil];
        return;
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

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self imageSelected:image];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.place.caption = textView.text;
    [[self placeStore] save];
}

-(void)textViewDidChange:(UITextView *)textView {
    [self resizeTextView:textView];
}

- (void) resizeTextView:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.textViewWidthConstraint.constant = 50.0f;
    }
    else {
        CGSize inset = CGSizeMake(14, 20);
        CGSize insetSize = CGSizeMake(CGRectGetWidth(textView.superview.frame) - inset.width, CGFLOAT_MAX);
        CGSize size = [textView.attributedText boundingRectWithSize:insetSize options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
        self.textViewHeightConstraint.constant = size.height + inset.height;
        self.textViewWidthConstraint.constant = MAX(size.width + inset.width, 50.0f);
    }
    self.textViewLeadingConstraint.constant = (textView.superview.frame.size.width - self.textViewWidthConstraint.constant) / 2;
    [self.contentView setNeedsLayout];
    textView.contentOffset = CGPointZero;
}

@end
