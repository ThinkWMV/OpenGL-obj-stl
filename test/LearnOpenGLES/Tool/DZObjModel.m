//
//  DZObjModel.m
//  LearnOpenGLES
//
//  Created by anycubic on 2020/5/12.
//  Copyright © 2020 loyinglin. All rights reserved.
//

#import "DZObjModel.h"
#import <OpenGLES/ES2/glext.h>

@interface DZObjModel ()



@property (strong, nonatomic) NSMutableData * vertexData;

@property (strong, nonatomic) NSMutableData *positionData;
@property (strong, nonatomic) NSMutableData *positionIndexData;

@property (strong, nonatomic) NSMutableData *normalData;
@property (strong, nonatomic) NSMutableData *normalIndexData;

@property (strong, nonatomic) NSMutableData *uvData;
@property (strong, nonatomic) NSMutableData *uvIndexData;


@end


@implementation DZObjModel
- (NSMutableData *)vertexData
{
    if (!_vertexData) {
        _vertexData = [[NSMutableData alloc] init];
    }
    return _vertexData;
}

- (NSMutableData *)loadObjModelDataFrompath:(NSString *)objFile
{
 
        _positionData = [[NSMutableData alloc] init];
        _positionIndexData = [[NSMutableData alloc] init];
        _uvData = [[NSMutableData alloc] init];
        _normalData = [[NSMutableData alloc] init];
        _uvIndexData = [[NSMutableData alloc] init];
        _normalIndexData = [[NSMutableData alloc] init];
        self.dataCount = 0;
        NSString *fileContent = [NSString stringWithContentsOfFile:objFile encoding:NSUTF8StringEncoding error:nil];
        NSArray<NSString *> *lines = [fileContent componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            if (line.length >= 2) {
                if ([line characterAtIndex:0] == 'v' && [line characterAtIndex:1] == ' ') {//几何体顶点
                    [self processVertexLine:line];
                }
                else if ([line characterAtIndex:0] == 'v' && [line characterAtIndex:1] == 'n') {//顶点的法线
                    [self processNormalLine:line];
                }
                else if ([line characterAtIndex:0] == 'v' && [line characterAtIndex:1] == 't') {//贴图坐标点
                    [self processUVLine:line];
                }
                else if ([line characterAtIndex:0] == 'f' && [line characterAtIndex:1] == ' ') {//f 顶点索引/UV索引/法线索引 顶点索引/UV索引/法线索引 顶点索引/UV索引/法线索引 这里的索引是从1开始的，在代码中，要记得减去1才能使用
                    [self processFaceIndexLine:line];
                }
            }
        }
        
        if (_positionData.length > 0 && _positionIndexData.length >0) {
            [self decompressToVertexArray];
        }
        return _vertexData;
}
- (void)decompressToVertexArray {
    NSInteger vertexCount = self.positionIndexData.length / sizeof(GLuint);
    
    if (self.positionIndexData.length > 0 && self.normalIndexData.length > 0 && self.uvIndexData.length > 0) {
        self.dataCount = 8;
    }else if(self.positionIndexData.length > 0 && self.normalIndexData.length > 0 && self.uvIndexData.length == 0){
        self.dataCount = 6;
    }else if(self.positionIndexData.length > 0 && self.normalIndexData.length == 0 && self.uvIndexData.length > 0){
        self.dataCount = 5;
    }else if(self.positionIndexData.length > 0 && self.normalIndexData.length == 0 && self.uvIndexData.length == 0){
        self.dataCount = 3;
    }
    for (int i = 0; i < vertexCount; ++i) {
        int positionIndex = 0;
        [self.positionIndexData getBytes:&positionIndex range:NSMakeRange(i * sizeof(GLuint), sizeof(GLuint))];
        positionIndex -= 1;
        [self.vertexData appendBytes:(void *)((char *)self.positionData.bytes + positionIndex * 3 * sizeof(GLfloat)) length: 3 * sizeof(GLfloat)];
        
        if (self.normalIndexData.length > 0) {
            int normalIndex = 0;
            [self.normalIndexData getBytes:&normalIndex range:NSMakeRange(i * sizeof(GLuint), sizeof(GLuint))];
             normalIndex -= 1;
            [self.vertexData appendBytes:(void *)((char *)self.normalData.bytes + normalIndex * 3 * sizeof(GLfloat)) length: 3 * sizeof(GLfloat)];
        }
        if (self.uvIndexData.length > 0) {
            int uvIndex = 0;
            [self.uvIndexData getBytes:&uvIndex range:NSMakeRange(i * sizeof(GLuint), sizeof(GLuint))];
            uvIndex -= 1;
            [self.vertexData appendBytes:(void *)((char *)self.uvData.bytes + uvIndex * 2 * sizeof(GLfloat)) length: 2 * sizeof(GLfloat)];
        }
               
      
    }
}

//顶点
- (void)processVertexLine:(NSString *)line {
    static NSString *pattern = @"v\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 4) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            GLfloat z = [[line substringWithRange: [result rangeAtIndex:3]] floatValue];
            [self.positionData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.positionData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.positionData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
        }
    }
}
- (void)processFaceIndexLine:(NSString *)line {
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray * sarr = [regex matchesInString:line options:NSMatchingReportCompletion range:NSMakeRange(0, line.length)];
    sarr = [[sarr reverseObjectEnumerator] allObjects];
    for (NSTextCheckingResult *str in sarr) {
        line = [line stringByReplacingCharactersInRange:[str range] withString:@" "];
    }
    NSArray * onearr = [line componentsSeparatedByString:@" "];
    if (onearr.count >= 4) {
        NSMutableArray * arr = [[NSMutableArray alloc] initWithObjects:onearr[1],onearr[2],onearr[3], nil];
        if (arr.count == 3) {
               for (NSString * positionStr in arr) {
                   NSArray * subonearr = [positionStr componentsSeparatedByString:@"/"];
                   if (subonearr.count >= 1) {
                        NSString * onevertex1 = subonearr[0];
                        GLint onevertexIndex1 = onevertex1.intValue;
                        [self.positionIndexData appendBytes:(void *)(&onevertexIndex1) length:sizeof(GLuint)];
                       if (subonearr.count >= 2) {
                           NSString * onevertex2 = subonearr[1];
                           GLint onevertexIndex2 = onevertex2.intValue;
                           [self.normalIndexData appendBytes:(void *)(&onevertexIndex2) length:sizeof(GLuint)];
                           if (subonearr.count >= 3) {
                               NSString * onevertex3 = subonearr[2];
                               GLint onevertexIndex3 = onevertex3.intValue;
                               [self.uvIndexData appendBytes:(void *)(&onevertexIndex3) length:sizeof(GLuint)];
                           }
                       }
                   }
               }
           }
    }
}
- (void)processNormalLine:(NSString *)line {
    static NSString *pattern = @"vn\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 4) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            GLfloat z = [[line substringWithRange: [result rangeAtIndex:3]] floatValue];
            [self.normalData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.normalData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
            [self.normalData appendBytes:(void *)(&z) length:sizeof(GLfloat)];
        }
    }
}

- (void)processUVLine:(NSString *)line {
    static NSString *pattern = @"vt\\s*([\\-0-9]*\\.[\\-0-9]*)\\s*([\\-0-9]*\\.[\\-0-9]*)";
    static NSRegularExpression *regexExp = nil;
    if (regexExp == nil) {
        regexExp = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSArray * matchResults = [regexExp matchesInString:line options:0 range:NSMakeRange(0, line.length)];
    for (NSTextCheckingResult *result in matchResults) {
        NSUInteger rangeCount = result.numberOfRanges;
        if (rangeCount == 3) {
            GLfloat x = [[line substringWithRange: [result rangeAtIndex:1]] floatValue];
            GLfloat y = [[line substringWithRange: [result rangeAtIndex:2]] floatValue];
            [self.uvData appendBytes:(void *)(&x) length:sizeof(GLfloat)];
            [self.uvData appendBytes:(void *)(&y) length:sizeof(GLfloat)];
        }
    }
}


@end
