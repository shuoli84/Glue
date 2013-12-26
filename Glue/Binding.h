//
// Created by Li Shuo on 13-10-30.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import <Foundation/Foundation.h>


@class Binding;

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2);
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, void (^valueUpdateBlock)(NSObject *));
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator);
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator, void (^valueUpdateBlock)(NSObject*));
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, BOOL (^)(NSObject*));
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, void (^valueUpdateBlock)(NSObject *), BOOL (^filterBlock)(NSObject*));
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator, BOOL (^filterBlock)(NSObject*));
__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator, void (^valueUpdateBlock)(NSObject*), BOOL (^filterBlock)(NSObject*));


@interface Binding : NSObject

@property (nonatomic, weak, readonly) NSObject *object1;
@property (nonatomic, strong, readonly) NSString *keyPath1;
@property (nonatomic, weak, readonly) NSObject *object2;
@property (nonatomic, strong, readonly) NSString *keyPath2;

@property (nonatomic, copy) void (^valueUpdateBlock)(NSObject *);

@property (nonatomic, copy) BOOL (^filterBlock)(NSObject *);

@property (nonatomic, copy) NSObject* (^value1ToValue2Block)(NSObject*);
@property (nonatomic, copy) NSObject* (^value2ToValue1Block)(NSObject*);
@property (nonatomic, copy) NSComparator comparator;

@property (nonatomic, strong) NSObject* value;

-(void)setObject1:(NSObject *)object keyPath:(NSString*)keyPath;
-(void)setObject2:(NSObject *)object keyPath:(NSString*)keyPath;
@end