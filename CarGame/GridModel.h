//
//  GridModel.h
//  AlientTeach
//
//  Created by admin on 2019/5/17.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GridModel : NSObject
@property (nonatomic,assign) NSInteger  x;
@property (nonatomic,assign) NSInteger  y;
@property (nonatomic,assign) NSInteger flag;
@property (nonatomic,copy) NSString * dires;
@end

NS_ASSUME_NONNULL_END
