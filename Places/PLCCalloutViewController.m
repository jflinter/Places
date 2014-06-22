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

@property (strong, nonatomic) IBOutlet UIInputView *inputView;
@property (strong, nonatomic) IBOutlet UIToolbar *accessoryToolbar;
@property (nonatomic, weak) IBOutlet UIScrollView *contentView;
@end

@implementation PLCCalloutViewController

+ (CGSize)calloutSize
{
    return CGSizeMake(310.0f, 310.0f);
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
    [self textViewDidChange:self.captionTextView];
    if ((!self.place.caption || [self.place.caption isEqualToString:@""]) && self.place.geocodedAddress) {
        self.captionTextView.text = [[self.place.geocodedAddress objectForKey:@"Street"] description];
    }
    [self.accessoryToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.inputView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, 320, 37) inputViewStyle:UIInputViewStyleDefault];
    [self.inputView addSubview:self.accessoryToolbar];
    self.captionTextView.inputAccessoryView = self.inputView;
    [self addImage:self.place.image];
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

- (void) imageSelected:(UIImage *)image {
    [[PLCPhotoStore new] addPhotoWithImage:image toPlace:self.place];
    self.placeImageView.image = image;
    [self addImage:image];
}

- (void)addImage:(UIImage *)image {
    if (!image) {
//        NSMutableAttributedString *mut = [self.captionTextView.attributedText mutableCopy];
//        [mut.mutableString replaceCharactersInRange:NSMakeRange(mut.mutableString.length - 1, 0) withString:@""];
//        self.captionTextView.attributedText = mut;
        return;
    }
    NSTextAttachment *attachment = [NSTextAttachment new];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, 200, 200);
    NSMutableAttributedString *mut = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    NSDictionary *attributes = [self.captionTextView.attributedText attributesAtIndex:0 effectiveRange:nil];
    [mut addAttributes:attributes range:NSMakeRange(0, mut.length)];
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    [mut addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, mut.length)];
    NSMutableAttributedString *full = [self.captionTextView.attributedText mutableCopy];
    [full appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [full appendAttributedString:mut];
    self.captionTextView.attributedText = full;
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
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self imageSelected:image];
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
