//
//  DZCParsingData.h
//  LearnOpenGLES
//
//  Created by anycubic on 2020/5/14.
//  Copyright © 2020 loyinglin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DZStlModel : NSObject

@property (assign, nonatomic) int dataCount;


- (NSMutableData *)loadStlModelDataFrompath:(NSString *)path;


@end

NS_ASSUME_NONNULL_END
