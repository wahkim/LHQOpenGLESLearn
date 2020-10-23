//
//  OpenGLDrawView.h
//  Learn_01_Triangle
//
//  Created by Xhorse_iOS3 on 2020/10/22.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGL.h>

struct OpenGLESContext {
    GLuint program;
    GLint width;
    GLint height;
};

@interface OpenGLDrawView : UIView

@property (nonatomic, assign) GLint width; /// 窗口宽度
@property (nonatomic, assign) GLint height; /// 窗口高度

@property (nonatomic, assign) GLuint viewRenderBuffer; /// 渲染缓冲区
@property (nonatomic, assign) GLuint viewFrameBuffer; /// 帧缓冲区
@property (nonatomic, assign) GLuint depthRenderBuffer; /// 深度缓冲区

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) struct OpenGLESContext openGLESContext;

@end

