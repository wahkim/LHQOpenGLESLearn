//
//  GLESUtils.h
//  Learn_01_Triangle
//
//  Created by Xhorse_iOS3 on 2020/10/24.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

@interface GLESUtils : NSObject

+ (GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;
/**
 @param type 着色器类型
 @param shaderFilepath 着色器脚本路径
 */
+ (GLuint)loadShader:(GLenum)type withFilepath:(NSString *)shaderFilepath;
+ (GLuint)loadProgram:(NSString *)vertexShaderFilepath withFragmentShaderFilepath:(NSString *)fragmentShaderFilepath;

@end

