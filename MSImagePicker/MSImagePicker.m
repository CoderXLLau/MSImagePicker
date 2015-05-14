//
//  MSImagePicker.m
//  Demo
//
//  Created by DamonDing on 15/5/14.
//  Copyright (c) 2015年 zxm. All rights reserved.
//

#import "MSImagePicker.h"

@interface MSImagePicker ()

@property (readonly) Class PUGridVC;
@property (readonly) Class PUCollectionView;
@property (readonly) Class PUPhotoView;

@property (retain, nonatomic) UIBarButtonItem* doneButton;
@property (retain, nonatomic) UIBarButtonItem* lastDoneButton;

@property (retain, nonatomic) id lastDelegate;

@end

@implementation MSImagePicker

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (Class) PUPhotoView {
    return NSClassFromString(@"PUPhotoView");
}

- (Class) PUCollectionView {
    return NSClassFromString(@"PUCollectionView");
}

- (Class) PUGridVC {
    return NSClassFromString(@"PUUIMomentsGridViewController");
}

- (NSMutableArray*) images {
    if (_images == nil) {
        _images = [NSMutableArray new];
    }
    
    return _images;
}

- (UIBarButtonItem*) doneButton {
    if (_doneButton == nil) {
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    }
    
    return _doneButton;
}

- (void) done:(id)sender {
    
}

-(UIView*) getPUCollectionView:(UIView*)v {
    for (UIView* i in v.subviews) {
        if ([i isKindOfClass:self.PUCollectionView]) {
            return i;
        }
    }
    
    return nil;
}

/**
 *  get indicator button in PUPhotoView
 *
 *  @param v must be PUPhotoView
 *
 *  @return the indicator button
 */
- (UIButton*) getIndicatorButton:(UIView*) v {
    for (id b in v.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            return (UIButton*)b;
        }
    }
    
    return nil;
}

/**
 *  add selected state
 *
 *  @param v must be PUPhotoView
 */
- (void) addIndicatorButton:(UIView*) v {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.frame = CGRectMake(0, 0, 20, 20);
    [v addSubview:button];
    button.hidden = false;
}

/**
 *  remove selectd state
 *
 *  @param v must be PUPhotoView
 */
- (void) removeIndicatorButton:(UIView*)v {
    for (UIView* b in v.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            [b removeFromSuperview];
            return;
        }
    }
}

- (void) addNewImage:(UIImage*) image {
    [self.images addObject:image];
}


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;{
    
    UIView* collection = [self getPUCollectionView:viewController.view];
    
    if (collection == nil) {
        return;
    }
    
    self.lastDelegate = [collection valueForKey:@"delegate"];
    [collection setValue:self forKey:@"delegate"];
}


- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%s", sel_getName(_cmd)]);
    if ([self.lastDelegate respondsToSelector:sel]) {
        [self.lastDelegate performSelector:sel withObject:collectionView withObject:indexPath];
    }
    
    UIView* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIButton* indicatorButton = [self getIndicatorButton:cell];
    
    if (indicatorButton == nil) {
        // add button and image in self.images
    } else {
        // remove button and image in self.images
    }
    
    return YES;
}


@end
