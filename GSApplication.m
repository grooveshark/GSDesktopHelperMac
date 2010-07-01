//
//  GSApplication.m
//  GSDesktopHelper
//
//  Created by Terin Stock on 5/29/10.
//  Copyright 2010 Three Strange Days Development. All rights reserved.
//

#import "GSApplication.h"


@implementation GSApplication

- (NSString *) bundleVersionNumber {
	return [NSString stringWithFormat:@"%@ (%@)",[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"]];
}

@end
