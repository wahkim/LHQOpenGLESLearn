//
//  OpenGLDrawView.m
//  Learn_01_Triangle
//
//  Created by Xhorse_iOS3 on 2020/10/22.
// https://jingyan.baidu.com/article/20b68a889bdb58796dec6247.html

#import "OpenGLDrawView.h"

@implementation OpenGLDrawView

- (instancetype)init
{
    if (self = [super init])
    {
        [self setupContext];
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
    
    [self destoryFrameBuffer];
    [self createFrameBuffer];
    [self drawView];
}

#pragma mark - Setup Method

- (void)setupContext
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatSRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!self.context || ![EAGLContext setCurrentContext:self.context])
    {
        NSLog(@"setup context failed");
    }
    
    if (![self setupShader])
    {
        NSLog(@"setupShader failed");
    }
}

- (void)createFrameBuffer
{
    glGenFramebuffers(1, &_viewFrameBuffer);
    glGenRenderbuffers(1, &_viewRenderBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFrameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderBuffer);
    
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _viewRenderBuffer);
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _width, _height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);

    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to create frame buffer");
    }
}

- (void)destoryFrameBuffer
{
    glDeleteBuffers(1, &_viewFrameBuffer);
    _viewFrameBuffer = 0;
    
    glDeleteBuffers(1, &_viewRenderBuffer);
    _viewRenderBuffer = 0;
    
    if (_depthRenderBuffer)
    {
        glDeleteBuffers(1, &_depthRenderBuffer);
        _depthRenderBuffer = 0;
    }
}

- (BOOL)setupShader
{
    GLbyte vertexShaderStr[] =
    "uniform mat4 u_mvpMatrix;      \n"
    "attribute vec4 vertexPosition; \n"
    "void main()                    \n"
    "{                              \n"
    "   gl_Position = vertexPosition; \n"
    "}                              \n";
    
    GLbyte fragmentShaderStr[] =
    "precision mediump float; \n"
    "void main()                    \n"
    "{                              \n"
    "   gl_FragColor = vec4 (0.0, 0.0, 1.0, 1.0); \n"
    "}                              \n";
    
    GLuint vertexShader;
    GLuint fragmentShader;
    
    GLuint program;
    GLint linked;
    
    vertexShader = [self loadshader:(const char *)vertexShaderStr type:GL_VERTEX_SHADER];
    fragmentShader = [self loadshader:(const char *)fragmentShaderStr type:GL_FRAGMENT_SHADER];
    
    program = glCreateProgram();
    if (program == 0) {
        return NO;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glBindAttribLocation(program, 0, "vertextPosition");
    glLinkProgram(program);
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            free(infoLog);
        }
        glDeleteShader(program);
        return GL_FALSE;
    }
    
    _openGLESContext.program = program;
    glClearColor(1.0f, 0.0f, 0.0f, 0.0f);
    return YES;
}

- (GLuint)loadshader:(const char *)shaderSource type:(GLenum)type
{
    GLuint shader;
    GLint complied;
    
    shader = glCreateShader(type);
    
    if (shader == 0)
    {
        return 0;
    }
    
    glShaderSource(shader, 1, &shaderSource, NULL);
    glCompileShader(shader);
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complied);
    if (!complied)
    {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            free(infoLog);
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

- (void)drawView
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _viewFrameBuffer);
    
    _openGLESContext.width = _width;
    _openGLESContext.height = _height;
    
    GLfloat vVertices[] = {0.0f, 0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f};
    
    glViewport(0, 0, _openGLESContext.width, _openGLESContext.height);
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(_openGLESContext.program);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vVertices);
    
    glEnableVertexAttribArray(0);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderBuffer);
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
