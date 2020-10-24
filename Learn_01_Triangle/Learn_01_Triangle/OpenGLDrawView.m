//
//  OpenGLDrawView.m
//  Learn_01_Triangle
//
//  Created by Xhorse_iOS3 on 2020/10/22.
// https://jingyan.baidu.com/article/20b68a889bdb58796dec6247.html
// https://www.cnblogs.com/kesalin/archive/2012/11/25/opengl_es_tutorial_02.html
// http://blog.oo87.com/opengl/9860.html#directory00979995203361112627

#import "OpenGLDrawView.h"

@interface OpenGLDrawView ()
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    GLuint _depthRenderBuffer;
    GLuint _program;
    GLuint _positionSlot;
    GLint _width; /// 窗口宽度
    GLint _height; /// 窗口高度
}

@end

@implementation OpenGLDrawView

- (instancetype)init
{
    if (self = [super init])
    {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
    }
    return self;
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [EAGLContext setCurrentContext:_context];
    [self destoryBuffers];
    [self setupBuffers];
    [self render];
//    [self setupLinker];

}

#pragma mark - Setup Method

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.opaque = YES; /// CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatSRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_context];
}

- (void)setupBuffers
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // 设置为当前 renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);

//    glGenRenderbuffers(1, &_depthRenderBuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

/// 初始化定时器
- (void)setupLinker
{
    CADisplayLink *linker = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    linker.frameInterval = 1;
    [linker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)destoryBuffers
{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;

    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)setupProgram
{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                  ofType:@"glsl"];
    NSString *fragShaderPath = [[NSBundle mainBundle] pathForResource:@"FragShader"
                                                                    ofType:@"glsl"];
    
    _program = [GLESUtils loadProgram:vertexShaderPath
                 withFragmentShaderFilepath:fragShaderPath];
    if (_program == 0) {
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    
    glUseProgram(_program);
}

#pragma mark - Render

- (void)render
{
    glClearColor(1.0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    glViewport(0, 0, _width, _height);
    
    GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f };

    // Load the vertex data
    GLuint positionSlot = glGetAttribLocation(_program, "vPosition");
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(positionSlot);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
