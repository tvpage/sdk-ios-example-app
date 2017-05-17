//
//  NSDictionary+NullReplacement.h
//  FPW
//
//  Created by    on 02/10/15.
//  Copyright (c) 2015   . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullReplacement)

- (NSDictionary *)dictionaryByReplacingNullsWithBlanks;

@end
