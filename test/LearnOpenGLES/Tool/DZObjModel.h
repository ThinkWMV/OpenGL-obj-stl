//
//  DZObjModel.h
//  LearnOpenGLES
//
//  Created by anycubic on 2020/5/12.
//  Copyright © 2020 loyinglin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>




NS_ASSUME_NONNULL_BEGIN

@interface DZObjModel : NSObject




- (NSMutableData *)loadObjModelDataFrompath:(NSString *)objFile;




@property (assign, nonatomic) int dataCount;




@end

NS_ASSUME_NONNULL_END
