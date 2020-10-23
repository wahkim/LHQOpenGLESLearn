//
//  ViewController.m
//  Learn_01_Triangle
//
//  Created by Xhorse_iOS3 on 2020/10/22.
//

#import "ViewController.h"
#import "OpenGLDrawView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    OpenGLDrawView *view = [[OpenGLDrawView alloc] init];
    view.frame = self.view.frame;
    [self.view addSubview:view];
}


@end
