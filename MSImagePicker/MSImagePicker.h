//
//  MSImagePicker.h
//  Demo
//
//  Created by DamonDing on 15/5/14.
//  Copyright (c) 2015年 zxm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSImagePicker;

@protocol MSImagePickerDelegate<NSObject>

@optional
- (void)imagePickerController:(MSImagePicker *)picker didFinishPickingImage:(NSArray *)images;
- (void)imagePickerControllerDidCancel:(MSImagePicker *)picker;

@end

/**
 *  This class is just for select image
 */
@interface MSImagePicker : UIImagePickerController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/**
 * save all selected image
 */
@property (strong, nonatomic) NSMutableArray* images;

@property (weak, nonatomic) id<MSImagePickerDelegate> msDelegate;

@end
