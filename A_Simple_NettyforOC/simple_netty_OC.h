//
//  simple_netty_OC.h
//  A_Simple_NettyforOC
//
//  Created by chenyonghuai on 16/4/2.
//  Copyright © 2016年 chenyonghuai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@protocol SimpleNettyDelegate;

@interface simple_netty_OC : NSObject <GCDAsyncSocketDelegate>
{
    GCDAsyncSocket *_socket;
    NSMutableData *_recvBuf;
}
@property(weak) id<SimpleNettyDelegate> delegate;

+ (simple_netty_OC *)sharedInstance;
- (void)connectToHost;
- (BOOL)connect;
- (void)close;

@end

@protocol SimpleNettyDelegate <NSObject>

@optional
- (void)connection:(simple_netty_OC *)conn shouldCloseWithError:(NSError *)error;
- (void)connection:(simple_netty_OC *)conn didCloseWithError:(NSError *)error;
- (void)connection:(simple_netty_OC *)conn receivedobj:(id)obj;

@end
