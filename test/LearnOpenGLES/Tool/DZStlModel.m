//
//  DZCParsingData.m
//  LearnOpenGLES
//
//  Created by anycubic on 2020/5/14.
//  Copyright © 2020 loyinglin. All rights reserved.
//

#import "DZStlModel.h"
#import <OpenGLES/ES2/glext.h>

@implementation DZStlModel


// stl文件
- (NSMutableData *)loadStlModelDataFrompath:(NSString *)path
{
      _dataCount = 6;
      NSMutableData *node = [[NSMutableData alloc] init];
      NSData * data = [NSData dataWithContentsOfFile:path];
      if (data.length > 80)
      {
          //为什么取前80个字节请查看前面的STL文件解析
          NSData *headerData = [data subdataWithRange:NSMakeRange(0, 80)];
          NSString *headerStr = [[NSString alloc] initWithData:headerData encoding:NSASCIIStringEncoding];
          if ([headerStr containsString:@"solid"])
          {
              //ASCII编码的STL文件
               node = [self loadASCIISTLWithData:data];
          }
          else
          {
              //载入二进制的STL文件
            node = [self loadBinarySTLWithData:[data subdataWithRange:NSMakeRange(84, data.length - 84)]];
          }
      }
      return node;
}
//ASCII编码的STL文件
- (NSMutableData *)loadASCIISTLWithData:(NSData *)data
{
    //顶点信息
    NSMutableData *vertices = [NSMutableData data];
    NSString *asciiStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSArray *asciiStrArr = [asciiStr componentsSeparatedByString:@"\n"];

    for (int i = 0; i < asciiStrArr.count; i ++)
    {
        NSString *currentStr = asciiStrArr[i];
        
        if ([currentStr containsString:@"facet"])
        {
            if ([currentStr containsString:@"normal"])
            {
                NSArray *subNormal = [currentStr componentsSeparatedByString:@" "];
                GLfloat oneValue = [subNormal[subNormal.count - 3] floatValue];
                GLfloat twoValue = [subNormal[subNormal.count - 2] floatValue];
                GLfloat threeValue = [subNormal[subNormal.count - 1] floatValue];
                
                for (int j = 1; j <= 3; j++)
                {
                     NSArray *subVertice = [asciiStrArr[i+j+1] componentsSeparatedByString:@" "];
                     GLfloat oneValuevertice = [subVertice[subVertice.count - 3] floatValue];
                     GLfloat twoValuevertice = [subVertice[subVertice.count - 2] floatValue];
                     GLfloat threeValuevertice = [subVertice[subVertice.count - 1] floatValue];
                     [vertices appendBytes:&oneValuevertice length:sizeof(GLfloat)];
                     [vertices appendBytes:&twoValuevertice length:sizeof(GLfloat)];
                     [vertices appendBytes:&threeValuevertice length:sizeof(GLfloat)];
                     [vertices appendBytes:&oneValue length:sizeof(GLfloat)];
                     [vertices appendBytes:&twoValue length:sizeof(GLfloat)];
                     [vertices appendBytes:&threeValue length:sizeof(GLfloat)];
                }
                i = i+6;
            }
        }
    }
    
      return vertices;
}


- (NSMutableData *)loadBinarySTLWithData:(NSData *)data
{
    //顶点信息
     NSMutableData *vertices = [NSMutableData data];
     if (data.length % 50 != 0)
     {
         NSLog(@"STL(二进制)文件错误");
         return vertices;
     }
     NSInteger allCount = data.length/50;
     for (int i = 0; i < allCount; i ++)
     {
         for (int j = 1; j <= 3; j ++)
         {
             [vertices appendData:[data subdataWithRange:NSMakeRange(i * 50 + j*12, 12)]];//坐标
             [vertices appendData:[data subdataWithRange:NSMakeRange(i * 50, 12)]];//法线
         }
     }
    return vertices;
    
}


@end
