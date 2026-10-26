#import <UIKit/UIKit.h>
#import <React/RCTInvalidating.h>

// React owns this wrapper; the SDK can retain the embedded view after React removes it.
@interface RoktLegacyEmbeddedView : UIView <RCTInvalidating>
// The Rokt SDK's RoktEmbeddedView.
@property (nonatomic, strong, readonly) UIView *roktEmbeddedView;
@property (nonatomic, copy) NSString *placeholderName;
@end
