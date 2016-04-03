//
//  simple_netty_OC.m
//  A_Simple_NettyforOC
//
//  Created by chenyonghuai on 16/4/2.
//  Copyright © 2016年 chenyonghuai. All rights reserved.
//

#import "simple_netty_OC.h"
#include <sys/sysctl.h>
#import "Reachability.h"

#define SOCKET_WRITE_TIMEOUT  (8)
#define SOCKET_READ_TIMEOUT   (3)
#define SOCKET_READ_TIMEOUT_INFINITE (-1.0)
#define kConf_Server_Addr     @"101.251.224.58" //your socket server
#define kConf_Server_PORT 8888

const NSInteger kHeaderTag = 0;
const NSInteger kBegainTag = 100;
@interface simple_netty_OC ()
{
    NSLock *processMessageLock;//防止在处理数据时，有data add 进来
    dispatch_queue_t turnQueue;
}
@end
@implementation simple_netty_OC
@synthesize delegate;

+(simple_netty_OC *) sharedInstance
{
    
    static simple_netty_OC *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstace = [[self alloc] init];
    });
    return sharedInstace;
    
}

-(void)connectToHost{
    //dispatch_queue_t Queue = dispatch_queue_create("icardSocketQueue", DISPATCH_QUEUE_CONCURRENT);//dispatch_get_main_queue();
    if (_socket==nil) {
        turnQueue = dispatch_queue_create("simple_netty_OC_socket", DISPATCH_QUEUE_SERIAL);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:turnQueue];
        processMessageLock = [[NSLock alloc] init];
    }
    if (_socket.delegate ==nil) {
        [_socket setDelegate:self];
    }
    if(!_recvBuf){
        _recvBuf = [[NSMutableData alloc] init];
    }
    NSError *err = nil;
    BOOL ret = [_socket connectToHost:kConf_Server_Addr onPort:kConf_Server_PORT error:&err];
    NSLog(@"ret: %@" ,ret?@"connectToHost":err.description);
}

- (BOOL)connect
{
    BOOL ret = [_socket isConnected];
    NSLog(@"ret: %@" ,ret?@"YES":@"NO");
    return ret;
}

- (void)close
{
    [_socket disconnect];
    [_recvBuf replaceBytesInRange:NSMakeRange(0, _recvBuf.length) withBytes:NULL length:0];
}

- (void)ReConnect{
    //connectionTimes++;
    //    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:turnQueue];
    //    NSError __autoreleasing *err;
    //    [_socket connectToHost:kConf_Server_Addr onPort:kConf_Server_PORT error:&err];
}
#pragma -
#pragma mark GCDAsyncSocketDelegate methods

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connected to %@:%d", host, port);
    //do you thing in this
    [_socket readDataWithTimeout:-1.0 tag:kHeaderTag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [_recvBuf appendData:data];
    NSLog(@"received= %@, buffered= %@", @(data.length), @(_recvBuf.length));
    NSData *datalen = [_recvBuf subdataWithRange:NSMakeRange(0,4)];
    int *p =(int *)[datalen bytes];
    int msglen = ntohl(*p);
    int actuallen = (int)[_recvBuf length];
    if(actuallen < msglen){
        NSLog(@"\n message no long enough");
    }else{
        [processMessageLock lock];
        NSUInteger bytesDone = 0;
        NSUInteger bytesLeft = _recvBuf.length;
        NSUInteger ret = 0;
        while (bytesLeft > 0) {
            ret = [self processMessage:[_recvBuf subdataWithRange:NSMakeRange(bytesDone, bytesLeft)] ];
            if (ret > 0) {
                bytesDone += ret;
                bytesLeft -= ret;
                NSLog(@"bytes processed =%@, bytesDone=%@, bytesLeft=%@", @(ret), @(bytesDone), @(bytesLeft));
            } else if (ret == 0){
                break;
            }
        }
        if (bytesDone > 0) {
            [_recvBuf replaceBytesInRange:NSMakeRange(0, bytesDone) withBytes:NULL length:0];
        }
        [processMessageLock unlock];
    }
    [_socket readDataWithTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"didWriteData");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    [_socket setDelegate:nil];
    [_socket disconnect];
    [_recvBuf replaceBytesInRange:NSMakeRange(0, _recvBuf.length) withBytes:NULL length:0];
//    if ([self connectedToNetWork]) {
//        [_socket setDelegate:self];
//        [_socket connectToHost:kConf_Server_Addr onPort:kConf_Server_PORT error:&err];
//    }
    [self.delegate connection:self didCloseWithError:err];
}
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    [self.delegate connection:self shouldCloseWithError:nil];
    return 0;
}
- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    if (tag == kBegainTag) {
        [self.delegate connection:self shouldCloseWithError:nil];
    }
    return 0;
}
#pragma -
#pragma mark PrivateMethod

- (NSUInteger)processMessage:(NSData *)data {
    if (data.length<4) {
        return 0;
    }
    NSData *datalen = [data subdataWithRange:NSMakeRange(0,4)];
    int *p =(int *)[datalen bytes];
    int msglen = ntohl(*p);
    if ((data.length-4)<msglen) {
        return 0;
    }
    NSData *actualdata = [data subdataWithRange:NSMakeRange(4, msglen)];
    NSUInteger len = [actualdata length];
    NSError *error = nil;
    NSMutableDictionary *root = (NSMutableDictionary *) [NSJSONSerialization JSONObjectWithData:actualdata options:NSJSONReadingMutableContainers error:&error];
    ;

    if (self.delegate) {
        [self.delegate connection:self receivedobj:root];
    }
    
    return len+4;
}

/*
 
 */
-(NSData *) addDataLengthToBuff:(NSData *) aData{
    unsigned int len = htonl([aData length]);
    NSData *data = [NSData dataWithBytes: &len length: sizeof(len)];
    NSMutableData *appData = [[NSMutableData alloc] init];
    [appData appendData:data];
    [appData appendData:aData];
    return appData;
}
#pragma mark net
//是否连接到网络
-(BOOL)connectedToNetWork
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    NSLog(@"ConnectedToNetWork: %@" ,isReachable && !needsConnection?@"YES":@"NO");
    return (isReachable && !needsConnection) ? YES : NO;
}

@end