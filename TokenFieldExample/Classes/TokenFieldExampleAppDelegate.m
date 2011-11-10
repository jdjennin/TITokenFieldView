//
//  TokenFieldExampleAppDelegate.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleAppDelegate.h"
#import "TokenFieldExampleViewController.h"
#import <QuartzCore/QuartzCore.h>

// Nice custom nav bar...once we have an image for it...
@implementation UINavigationBar (CustomBackground)

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
  if ([self isMemberOfClass:[UINavigationBar class]] == NO || self.tag == 23) {
    [super drawLayer:layer inContext:context];
    return;
  }
  
  UIImage *image = image = [UIImage imageNamed:@"bg-top-bar.png"];
  
  CGContextScaleCTM(context, 1, -1);
  CGContextDrawImage(context, CGRectMake(0, - image.size.height, image.size.width, image.size.height), image.CGImage);
}

@end

@implementation TokenFieldExampleAppDelegate


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	TokenFieldExampleViewController * viewController = [[TokenFieldExampleViewController alloc] init];
	navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
  [navigationController setDelegate:self];
	[viewController release];
	
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
  
  return YES;
}


- (void)dealloc {
  [navigationController setDelegate:nil];
  [navigationController release];
  [window release];
  [super dealloc];
}


@end
