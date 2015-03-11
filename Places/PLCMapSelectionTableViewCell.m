//
//  PLCMapSelectionTableViewCell.m
//  Places
//
//  Created by Jack Flintermann on 9/13/14.
//  Copyright (c) 2014 Places. All rights reserved.
//

#import "PLCMapSelectionTableViewCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PLCMapSelectionTableViewCell()<UITextFieldDelegate, SWTableViewCellDelegate>
@property(nonatomic)PLCMapRowViewModel *viewModel;
@end

@implementation PLCMapSelectionTableViewCell

- (void)configureWithViewModel:(PLCMapRowViewModel *)viewModel {
    self.viewModel = viewModel;
    RAC(self.textLabel, text) = RACObserve(viewModel, title);
    RAC(self.editTitleTextField, text) = RACObserve(viewModel, title);
    [RACObserve(self.viewModel, selected) subscribeNext:^(NSNumber *selected) {
        if (selected.boolValue) {
            self.textLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:18.0f];
        } else {
            self.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0f];
        }
    }];
    self.editTitleTextField.alpha = 0;
    self.editTitleTextField.hidden = YES;
    self.editTitleTextField.delegate = self;
    self.delegate = self;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithRed:131.0f / 255.0f green:219.0f / 255.0f blue:242.0f / 255.0f alpha:1.0f];
    [button setTitle:NSLocalizedString(@"Edit Title", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.backgroundColor = [UIColor colorWithRed:249.0f / 255.0f green:58.0f / 255.0f blue:47.0f / 255.0f alpha:1.0f];
    [deleteButton setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deleteButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0f]];
    
    self.rightUtilityButtons = @[button, deleteButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length != 0) {
        self.viewModel.title = textField.text;
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    [cell hideUtilityButtonsAnimated:YES];
    if (index == 0) {
        self.editTitleTextField.hidden = NO;
        [UIView animateWithDuration:0.3
                         animations:^{ self.editTitleTextField.alpha = 1.0; }
                         completion:^(__unused BOOL finished) { [self.editTitleTextField becomeFirstResponder]; }];
        return;
    }
    [self.viewModel deleteMap];
}


@end
