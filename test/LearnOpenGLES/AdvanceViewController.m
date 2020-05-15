//
//  AdvanceViewController.m
//  LearnOpenGLES
//
//  Created by loyinglin on 16/3/25.
//  Copyright © 2016年 loyinglin. All rights reserved.
//

#import "AdvanceViewController.h"
#import <OpenGLES/ES2/glext.h>

#import "DZObjModel.h"
#import "DZStlModel.h"
@interface AdvanceViewController ()

@property (nonatomic , strong) EAGLContext* mContext;
@property (nonatomic , strong) GLKBaseEffect* mEffect;

@property (nonatomic , assign) int mCount;




@property(nonatomic, assign)CGFloat degreeY;
@property(nonatomic, assign)CGFloat degreeX;


@property (strong, nonatomic) NSMutableData * vertexData;
@property (assign, nonatomic) int dataCount;

@end

@implementation AdvanceViewController
{
  
    
    GLKMatrix4 projectionMatrix; // 投影矩阵
    
    GLKMatrix4 modelMatrix; // 模型矩阵
    
    GLKMatrix4 cameraMatrix; // 观察矩阵
    
    GLuint program;
    
    GLuint vertexVBO;

}
- (void)setupEAGLContext {
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.preferredFramesPerSecond = 60;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;//颜色缓存区
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;//深度缓存区
//    view.drawableMultisample = GLKViewDrawableMultisample4X; //反锯齿
    view.drawableStencilFormat = GLKViewDrawableStencilFormat8;//投影显示
    [EAGLContext setCurrentContext:view.context];
     glEnable(GL_DEPTH_TEST); //开启深度测试
           
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupEAGLContext];
    [self genBuffersVertexModelname:@"ch" ofType:@"obj"];
    [self setupanEffect];
    [self setupBaseTransform];
}
/**
 设置初始的视图变换
 */
- (void)setupBaseTransform{
    
    // 设置基础变换
    GLKMatrix4 mat = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -35.0f);
    
    mat = GLKMatrix4RotateY(mat, GLKMathDegreesToRadians(0));
    
    GLKMatrix4 temMat = GLKMatrix4RotateX(mat, GLKMathDegreesToRadians(0));
    
    self.mEffect.transform.modelviewMatrix = temMat;
    
    // 设置视角变换（添加该方法后可解决图形因屏幕而被拉伸的问题）
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    GLKMatrix4 matPersPective = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90.0), aspect, 0.1f, 100.0f);
    
    self.mEffect.transform.projectionMatrix = matPersPective;
    
}
- (void)setupanEffect
{
        self.mEffect = [[GLKBaseEffect alloc] init];
//        self.mEffect.useConstantColor = GL_TRUE;
      self.mEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    GLKFogModeExp=0,
//     GLKFogModeExp2,
//     GLKFogModeLinear
//
//      self.mEffect.light0.enabled = YES;//开启光照
//      self.mEffect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);    // 设置环境光
    
// 光照：设置漫反射灯光

//     self.mEffect.lightingType = GLKLightingTypePerPixel;
//     self.mEffect.light0.enabled = YES;
//     self.mEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//     //第四个参数非0表示从该位置发散光线，0表示无穷远处光线的发射方向
//     self.mEffect.light0.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//
//          //添加散射光
//         self.mEffect.light0.enabled = YES;
//         self.mEffect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//         self.mEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//
////          //镜面光
//         self.mEffect.light0.enabled = GL_TRUE;
//         self.mEffect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//         self.mEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//         // 这里需要注意，而在GLKit中材质的镜面光默认值是{0.0f, 0.0f, 0.0f, 1.0f}，这样设置光照的镜面光是没有效果的,所以这里我们需要设置材质的镜面光
//         self.mEffect.material.specularColor = GLKVector4Make(0.8f, 0.8f, 0.8f, 0.0f);
//         // 材质的发光值，发光值越高，聚光效果越好
//         self.mEffect.material.shininess = 32;
//         // 设置光照的镜面光
//         self.mEffect.light0.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 0.0f);
    
    
//    // 多光源
//    self.mEffect.light0.enabled = GL_TRUE;
//    self.mEffect.light0.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.mEffect.light0.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.mEffect.material.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.mEffect.material.shininess = 32;
//    self.mEffect.light0.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    // 第二个光源
//    self.mEffect.light1.enabled = YES;
//    self.mEffect.light1.position = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.mEffect.light1.ambientColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.mEffect.light1.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//    self.mEffect.light1.specularColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
//
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch * touch = touches.anyObject;
    CGPoint currentPoint = [touch locationInView:self.view];
    CGPoint previousPoint = [touch previousLocationInView:self.view];
    self.degreeY += currentPoint.y - previousPoint.y;
    self.degreeX += currentPoint.x - previousPoint.x;

}
/**
 *  场景数据变化
 */
/**
 *  场景数据变化
 */
- (void)update {
    // 设置物体变换 （让物体远离是为了能看全，因为摄像机默认在0，0，0点，即在物体内部）
     GLKMatrix4 mat = GLKMatrix4Translate(GLKMatrix4Identity, 0.0f, 0.0f, -35.0f);
     
     mat = GLKMatrix4RotateX(mat, GLKMathDegreesToRadians(self.degreeY));
     
     GLKMatrix4 temMat = GLKMatrix4RotateY(mat, GLKMathDegreesToRadians(self.degreeX));
     
     self.mEffect.transform.modelviewMatrix = temMat;
    
}
/**
 *  渲染场景代码
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.mEffect prepareToDraw];

    glDrawArrays(GL_TRIANGLES, 0, (GLuint)_vertexData.length/sizeof(GLuint)/_dataCount);

}

- (void)genBuffersVertexModelname:(NSString *)fileName ofType:(NSString *)fileType;
{
    if ([fileType isEqualToString:@"obj"]) {
        DZObjModel * objModel = [[DZObjModel alloc] init];
        _vertexData = [objModel loadObjModelDataFrompath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileType]];
        _dataCount = objModel.dataCount;
    }else if ([fileType isEqualToString:@"stl"]){
        DZStlModel * dataload = [[DZStlModel alloc] init];
        _vertexData = [dataload loadStlModelDataFrompath:[[NSBundle mainBundle] pathForResource:fileName ofType:fileType]];
        _dataCount = dataload.dataCount;
    }
     GLuint bufferVBO;
     glGenBuffers(1, &bufferVBO);
     glBindBuffer(GL_ARRAY_BUFFER, bufferVBO);
     glBufferData(GL_ARRAY_BUFFER, _vertexData.length, _vertexData.bytes, GL_STATIC_DRAW);

    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * _dataCount, NULL);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    if (_dataCount == 3) {
        // 设置顶点指针数据参数
            glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, NULL);
            glEnableVertexAttribArray(GLKVertexAttribNormal);
    }else if(_dataCount == 5){
            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 5, (GLfloat *)NULL + 6);
            glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    }else if(_dataCount == 6){
            glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 6, (GLfloat *)NULL + 3);
            glEnableVertexAttribArray(GLKVertexAttribNormal);
          }else if(_dataCount == 8){
            glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 3);
            glEnableVertexAttribArray(GLKVertexAttribNormal);
            glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 8, (GLfloat *)NULL + 6);
            glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    }
}

@end
