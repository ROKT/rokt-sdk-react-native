#import <UIKit/UIKit.h>
#import <React/RCTInvalidating.h>

@class RoktEmbeddedView;

// React owns this wrapper; the SDK can retain the embedded view after React removes it.
@interface RoktLegacyEmbeddedView : UIView <RCTInvalidating>
@property (nonatomic, strong, readonly) RoktEmbeddedView *roktEmbeddedView;
@property (nonatomic, copy) NSString *placeholderName;
@end
