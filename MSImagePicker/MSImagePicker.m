//
//  MSImagePicker.m
//  Demo
//
//  Created by DamonDing on 15/5/14.
//  Copyright (c) 2015年 zxm. All rights reserved.
//

#import "MSImagePicker.h"
#import <objc/runtime.h>

static char attachSelfKey;

@interface MSImagePicker ()

@property (readonly) Class PUGridVC;
@property (readonly) Class PUCollectionView;
@property (readonly) Class PUPhotoView;

@property (retain, nonatomic) UIBarButtonItem* doneButton;
@property (retain, nonatomic) UIBarButtonItem* lastDoneButton;

@property (retain, nonatomic) id lastDelegate;

@property (retain, nonatomic) NSIndexPath* curIndexPath;
@property (retain, nonatomic) NSMutableArray* indexPaths;

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

- (NSMutableArray*) indexPaths {
    if (_indexPaths == nil) {
        _indexPaths = [NSMutableArray new];
    }
    
    return _indexPaths;
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
    if ([self.msDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingImage:)]) {
        [self.msDelegate imagePickerController:self didFinishPickingImage:self.images];
    }
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
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 15;
    button.backgroundColor = [UIColor blueColor];
    [v addSubview:button];
    
    [button setTranslatesAutoresizingMaskIntoConstraints:false];
    
    NSArray* cs1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(30)]-1-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)];
    
    NSArray* cs2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(30)]-1-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)];

    [v addConstraints:cs1];
    [v addConstraints:cs2];
    
    [button setSelected:true];
    button.hidden = false;
    
    [v updateConstraintsIfNeeded];
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
    static dispatch_once_t token;
    
    self.curIndexPath = nil;
    [self.images removeAllObjects];
    [self.indexPaths removeAllObjects];
    
    UIView* collection = [self getPUCollectionView:viewController.view];
    
    if (collection == nil) {
        return;
    }
    
    /**
     *  the collection base class is UICollectionView, so delegate, datasource ...
     */
    self.lastDelegate = [collection valueForKey:@"delegate"];
    [collection setValue:self forKey:@"delegate"];
    
    dispatch_once(&token, ^{
        Method m1 = class_getInstanceMethod([self class], @selector(override_collectionView:cellForItemAtIndexPath:));
        
        class_addMethod([self.lastDelegate class], @selector(override_collectionView:cellForItemAtIndexPath:), method_getImplementation(m1), method_getTypeEncoding(m1));
        
        Method m2 = class_getInstanceMethod([self.lastDelegate class], @selector(override_collectionView:cellForItemAtIndexPath:));
        Method m3 = class_getInstanceMethod([self.lastDelegate class], @selector(collectionView:cellForItemAtIndexPath:));
        
        method_exchangeImplementations(m2, m3);
    });
    
    objc_setAssociatedObject(self.lastDelegate, &attachSelfKey, self, OBJC_ASSOCIATION_RETAIN);
    
    self.lastDoneButton = viewController.navigationItem.rightBarButtonItem;
}


/**
 *
 *
 *  @return -1 not in
 */
- (int) isCurIndexInIndexPaths {
    for (int i = 0; i < self.indexPaths.count; i++) {
        if (((NSIndexPath*)self.indexPaths[i]).row == self.curIndexPath.row &&
            ((NSIndexPath*)self.indexPaths[i]).section == self.curIndexPath.section) {
            return i;
        }
    }
    
    return -1;
}

/**
 *  careful self is PUUIMomentsGridViewController now
 *
 *  @param collectionView
 *  @param indexPath
 *
 *  @return
 */
- (UICollectionViewCell *)override_collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
    MSImagePicker* picker = (MSImagePicker*)objc_getAssociatedObject(self, &attachSelfKey);
    
    UICollectionViewCell* cell = [self performSelector:@selector(override_collectionView:cellForItemAtIndexPath:) withObject:collectionView withObject:indexPath];
    
    if (picker != nil) {
        picker.curIndexPath = indexPath;
        if ([picker isCurIndexInIndexPaths] != -1) {
            UIButton* indicatorButton = [picker getIndicatorButton:cell];
            
            if (indicatorButton == nil) {
                // do select(add button)
                [picker addIndicatorButton:cell];
            }
        } else {
            [picker removeIndicatorButton:cell];
        }
    }
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%s", sel_getName(_cmd)]);
    if ([self.lastDelegate respondsToSelector:sel]) {
        [self.lastDelegate performSelector:sel withObject:collectionView withObject:indexPath];
    }
    
    self.curIndexPath = indexPath;
    
    UIView* cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIButton* indicatorButton = [self getIndicatorButton:cell];
    
    if (indicatorButton == nil) {
        // do select(add button)
        [self addIndicatorButton:cell];
    } else {
        // do deselect (remove button)
        [self removeIndicatorButton:cell];
    }
    
    return YES;
}

// The picker does not dismiss itself; the client dismisses it in these callbacks.
// The delegate will receive one or the other, but not both, depending whether the user
// confirms or cancels.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo; {
    int idx = [self isCurIndexInIndexPaths];
    if (idx == -1) {
        // select
        [self.indexPaths addObject:self.curIndexPath];
        [self.images addObject:image];
    } else {
        // deselect
        [self.indexPaths removeObjectAtIndex:idx];
        [self.images removeObjectAtIndex:idx];
    }
    
    if (self.images.count == 1) {
        picker.topViewController.navigationItem.rightBarButtonItem = self.doneButton;
    } else if (self.images.count == 0) {
        picker.topViewController.navigationItem.rightBarButtonItem = self.lastDoneButton;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker; {
    if ([self.msDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.msDelegate imagePickerControllerDidCancel:self];
    }
}
@end
