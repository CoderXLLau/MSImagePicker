# MSImagePicker
A subclass of UIImagePIckerController that support multi select.

## How to use
* Drag MSImagePicker to your project.
* `#import "MSImagePickerController.h"`
```
  MSImagePickerController* picker = [[MSImagePickerController alloc] init];
  picker.msDelegate = self;
```
* implementation MSImagePickerDelegate.

### Requirements
* ios7 or higher.

### Demo
<img src="https://github.com/Jameson-zxm/MSImagePicker/blob/master/demo.gif" width="376" height="661" />

### How it works
* The PUCollectionView's base class is UICollectionView, so we can reset it's delegate.
* Through runtime we can customized it's method
<img src="https://github.com/Jameson-zxm/MSImagePicker/blob/master/howitworks.png" width="829" height="661" />

#### Contact
* morenotepad@163.com
