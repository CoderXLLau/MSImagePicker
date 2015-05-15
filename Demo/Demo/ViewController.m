//
//  ViewController.m
//  Demo
//
//  Created by DamonDing on 15/5/14.
//  Copyright (c) 2015年 zxm. All rights reserved.
//

#import "ViewController.h"

#import "MSImagePicker.h"
#import <QuickLook/QLPreviewController.h>

@interface ViewController ()
@property (retain, nonatomic) NSArray* array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doPicker:(id)sender {
    MSImagePicker* picker = [[MSImagePicker alloc] init];
    picker.msDelegate = self;
    
    [self presentViewController:picker animated:true completion:nil];
}

- (void)imagePickerController:(MSImagePicker *)picker didFinishPickingImage:(NSArray *)images; {
    self.array = images;

    int i = 0;
    for (UIImage* img in images) {
        NSData* data = UIImagePNGRepresentation(img);
        if (data != nil) {
            [data writeToFile:[NSString stringWithFormat:@"%@/Documents/%d.png", NSHomeDirectory(), i++] atomically:true];
        }
    }
    
    [picker dismissViewControllerAnimated:true completion:^{
        QLPreviewController* ql = [[QLPreviewController alloc] init];
        ql.dataSource = self;
        
        [self presentViewController:ql animated:true completion:nil];
    }];
}


/*!
 * @abstract Returns the number of items that the preview controller should preview.
 * @param controller The Preview Controller.
 * @result The number of items.
 */
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller; {
    return self.array.count;
}

/*!
 * @abstract Returns the item that the preview controller should preview.
 * @param panel The Preview Controller.
 * @param index The index of the item to preview.
 * @result An item conforming to the QLPreviewItem protocol.
 */
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index; {
    NSString* path = [NSString stringWithFormat:@"%@/Documents/%ld.png", NSHomeDirectory(), (long)index];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:path];
    
    return url;
}


- (void)imagePickerControllerDidCancel:(MSImagePicker *)picker; {
    NSLog(@"do cancel");
}
@end
