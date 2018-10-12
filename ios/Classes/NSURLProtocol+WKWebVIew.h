//
//  NSURLProtocol+WKWebVIew.h
//  Pods
//
//  Created by Lorenzo on 11/10/18.
//

#ifndef NSURLProtocol_WKWebVIew_h
#define NSURLProtocol_WKWebVIew_h


#endif /* NSURLProtocol_WKWebVIew_h */

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebVIew)

+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;


@end
