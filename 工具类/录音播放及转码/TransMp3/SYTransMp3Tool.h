//
//  SYTransMp3Tool.h
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/7/8.
//  Copyright © 2019 bsy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYTransMp3Tool : NSObject
- (BOOL) convertMp3from:(NSString *)wavpath topath:(NSString *)mp3path;
@end

NS_ASSUME_NONNULL_END
