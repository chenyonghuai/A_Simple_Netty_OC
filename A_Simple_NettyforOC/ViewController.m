//
//  ViewController.m
//  A_Simple_NettyforOC
//
//  Created by chenyonghuai on 16/4/3.
//  Copyright © 2016年 chenyonghuai. All rights reserved.
//

#import "ViewController.h"
#import "RippleButton.h"
#import "simple_netty_OC.h"

@interface ViewController ()<SimpleNettyDelegate>
{
    simple_netty_OC *testConnent;
}
@property (nonatomic, strong) RippleButton *rButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.rButton];
    // Do any additional setup after loading the view, typically from a nib.
}
-(RippleButton *)rButton{
    if (!_rButton) {
        _rButton = [[RippleButton alloc] initWithFrame:CGRectMake(100, 100,100, 100)];
        _rButton.layer.cornerRadius = 50;
        _rButton.backgroundColor = [UIColor colorWithRed:255/255.f green:119/255.f blue:0/255.f alpha:1];
        [_rButton setText:@"签"];
        __weak typeof(self) weakSelf = self;
        _rButton.clickBlock = ^(void) {
            [weakSelf connectToHost];
        };
    }
    return _rButton;

}
-(void)connectToHost{
    testConnent = [simple_netty_OC sharedInstance];
    testConnent.delegate = self;
    [testConnent connectToHost];
}

#pragma mark - SimpleNettyDelegate
- (void)connection:(simple_netty_OC *)conn shouldCloseWithError:(NSError *)error{
    
}
- (void)connection:(simple_netty_OC *)conn didCloseWithError:(NSError *)error{
    
}
- (void)connection:(simple_netty_OC *)conn receivedobj:(id)obj{
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
