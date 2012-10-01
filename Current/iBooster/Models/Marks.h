//
//  Marks.h
//  iBooster
//
//  Created by Arnaud BARISAIN MONROSE on 26/09/12.
//  Copyright (c) 2012 Arnaud Barisain Monrose. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_CREDITS 70

@interface Subject : NSObject {
    NSString *title;
    NSString *code;
    NSArray *marks;
    int credits;
    bool validated;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSArray *marks;
@property (nonatomic, assign) int credits;
@property (nonatomic, assign) bool validated;

@end

@interface Mark : NSObject {
    NSString *name;
    float mark;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float mark;

@end
