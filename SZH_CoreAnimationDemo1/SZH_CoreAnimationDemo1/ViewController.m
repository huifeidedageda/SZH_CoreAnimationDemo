//
//  ViewController.m
//  SZH_CoreAnimationDemo1
//
//  Created by 智衡宋 on 2017/9/28.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>
#import <QuartzCore/QuartzCore.h>
//度数转换弧度的宏定义
#define RADIANS_TO_DEGREES(X) ((X)/M_PI*180.0)

#define LIGHT_DIRECTION 0, 1, -0.5
#define AMBIENT_LIGHT 0.5
@interface ViewController ()
@property (nonatomic,strong) UIView *containnerView;
@property (nonatomic,strong) NSMutableArray *arrays;
@end

@implementation ViewController


#pragma mark ------------ 懒加载

- (NSMutableArray *)arrays {
    if (!_arrays) {
        _arrays = [NSMutableArray arrayWithCapacity:0];
    }
    return _arrays;
}


- (UIView *)containnerView {
    if (!_containnerView) {
        _containnerView = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
//        _containnerView.backgroundColor = [UIColor whiteColor];
        _containnerView.userInteractionEnabled = YES;
        [self.view addSubview:_containnerView];
    }
    return _containnerView;
}


#pragma mark ------------

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor grayColor];
//    [self test1];
//    [self test2];
//    [self test3];
//    [self test4];
//    [self test5];
    [self test6];
}


#pragma mark ------------ 2D仿射变换 CGAffineTransform

- (void)test1 {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 150, 150)];
    view.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    //缩放50%
    transform = CGAffineTransformScale(transform, 0.5, 0.5);
    //旋转30度
    transform = CGAffineTransformRotate(transform, RADIANS_TO_DEGREES(30));
    view.layer.affineTransform = transform;
    
}

#pragma mark ------------ 3D变换

//绕y轴旋转50度
- (void)test2 {
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 80, 80)];
    view.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:view];
    
    //绕Y轴旋转45度
    CATransform3D transform = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    view.layer.transform = transform;
    
}

#pragma mark ------------ 透视投影

- (void)test3 {
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 80, 80)];
    [self.view addSubview:view];
    UIImage *image = [UIImage imageNamed:@"image.png"];
    view.layer.contents = (__bridge id)image.CGImage;
    
    //创建单位矩阵
    CATransform3D transform = CATransform3DIdentity;
    //应用透视perspective,改变单位矩阵的m34的值
    transform.m34 = -1.0 / 50.0;
    //绕着Y轴旋转45度
    transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
    view.layer.transform = transform;
    
}


#pragma mark ------------ sublayerTransform属性

/**
 灭点:
 
 在透视绘图中，当物体远离到极限时，就变成一个点，于是所有的物体最后都会聚到一个点，通常这个点是视图的中心。所以在应用中灭点应该是屏幕中心或是包含所有3D对象的视图中点。
 */

//CALayer的属性sublayerTransform，是CATransform3D类型，他影响所有的子图层，好处是一次性对设置包含这些图层的容器做变换，于是所有的子图层都自动继承这个变换方法
- (void)test4 {
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(10, 150, self.view.frame.size.width - 20, 400)];
    [self.view addSubview:view];
    
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(5, 10, self.view.frame.size.width / 2 - 20, 380)];
    [view addSubview:view1];
    UIImage *image1 = [UIImage imageNamed:@"image.png"];
    view1.layer.contents = (__bridge id)image1.CGImage;
    
    
    
    UIView *view2 = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 + 5, 10, self.view.frame.size.width / 2 - 30, 380)];
    [view addSubview:view2];
    UIImage *image2 = [UIImage imageNamed:@"image.png"];
    view2.layer.contents = (__bridge id)image2.CGImage;
    
    
    //对父图层即图层容器应用perspective
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0/250.0;
    view.layer.sublayerTransform = transform;
    
    
    //对View1沿着Y轴旋转45度
    CATransform3D transform1 = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    view1.layer.transform = transform1;
    
    //对View2沿着y轴旋转45度
    CATransform3D transform2 = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
    view2.layer.transform = transform2;
    
    
}


#pragma mark ------------ 扁平化图层

//如果内部图层相对外部图层做了相反的变换（这里是绕Z轴的旋转），那么按照逻辑这两个变换将被相互抵消
- (void)test5 {
    //布局，两个view,view1以及其子视图View11，view2以及其子视图view22
    UIView *view1  = [[UIView alloc]initWithFrame:CGRectMake(80, 200, 200,200)];
    UIView *view11 = [[UIView alloc]initWithFrame:CGRectMake(60, 60, 80, 80)];
    view1.backgroundColor  = [UIColor whiteColor];
    view11.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:view1];
    [view1 addSubview:view11];
    
    //View1外图层绕Z轴旋转45度
    CATransform3D outerTransform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
    view1.layer.transform = outerTransform;
    
    //view11外图层绕Z轴旋转45度
    CATransform3D interTransform = CATransform3DMakeRotation(-M_PI_4, 0, 0, 1);
    view11.layer.transform = interTransform;
}

#pragma mark ------------ 创建固体对象

- (void)test6 {
    
    [self szh_createSixView];
    [self szh_createTheCube];
    
    
    
}

//创建一个立方体
- (void)szh_createTheCube {
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0 / 500.0;
    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
    self.containnerView.layer.sublayerTransform = perspective;
    
    //face1
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
    [self addFace:0 wihtTransform:transform];
    
    //face2
    transform = CATransform3DMakeTranslation(100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addFace:1 wihtTransform:transform];
    
    //face3
    transform = CATransform3DMakeTranslation(0, -100, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addFace:2 wihtTransform:transform];
    
    //face4
    transform = CATransform3DMakeTranslation(0, 100, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self addFace:3 wihtTransform:transform];
    
    //face5
    transform = CATransform3DMakeTranslation(-100, 0, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    [self addFace:4 wihtTransform:transform];
    
    //face6
    transform = CATransform3DMakeTranslation(0, 0, -100);
    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
    [self addFace:5 wihtTransform:transform];
}


//添加transform
- (void)addFace:(NSInteger)index wihtTransform:(CATransform3D)transform {
    UIView *face = self.arrays[index];
    [self.containnerView addSubview:face];
    CGSize containerSize = self.containnerView.bounds.size;
    face.center = CGPointMake(containerSize.width * 0.5, containerSize.height * 0.5);
    face.layer.transform = transform;
    [self applyLightToFace:face.layer];
}

//添加光亮和阴影
- (void)applyLightToFace:(CALayer *)face {
    
    CALayer *layer = [CALayer layer];
    layer.frame = face.bounds;
    [face addSublayer:layer];
    
    CATransform3D transform = face.transform;
    GLKMatrix4 matrix4 = *(GLKMatrix4 *)&transform;
    GLKMatrix3 matrix3 = GLKMatrix4GetMatrix3(matrix4);
    //get face normal
    GLKVector3 normal = GLKVector3Make(0, 0, 1);
    normal = GLKMatrix3MultiplyVector3(matrix3, normal);
    normal = GLKVector3Normalize(normal);
    //get dot product with light direction
    GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));
    float dotProduct = GLKVector3DotProduct(light, normal);
    //set lighting layer opacity
    CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT;
    UIColor *color = [UIColor colorWithWhite:0 alpha:shadow];
    layer.backgroundColor = color.CGColor;
    
    
}

//创建六个视图，放进一个数组中
- (void)szh_createSixView {
    
    for (int i = 0; i < 6; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        view.backgroundColor = [UIColor redColor];
        [self.arrays addObject:view];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
