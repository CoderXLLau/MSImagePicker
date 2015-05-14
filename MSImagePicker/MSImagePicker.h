//
//  MSImagePicker.h
//  Demo
//
//  Created by DamonDing on 15/5/14.
//  Copyright (c) 2015年 zxm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSImagePicker : UIImagePickerController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/**
 * save all selected image
 */
@property (strong, nonatomic) NSMutableArray* images;

@end
