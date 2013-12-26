//
// Created by Li Shuo on 13-10-30.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "Binding.h"
#import "UIControl+BlocksKit.h"
#import "NSObject+BKBlockObservation.h"

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2){
    return binding(object1, pathKey1, object2, pathKey2, nil, nil, nil, nil, nil);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, void (^valueUpdateBlock)(NSObject *)){
    return binding(object1, pathKey1, nil, nil, nil, nil, nil, valueUpdateBlock, nil);
}


__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator){
    return binding(object1, pathKey1, object2, pathKey2, value1ToValue2Block, value2ToValue1Block, comparator, nil, nil);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator, void (^valueUpdateBlock)(NSObject*)){
    return binding(object1, pathKey1, object2, pathKey2, value1ToValue2Block, value2ToValue1Block, comparator, valueUpdateBlock, nil);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, BOOL (^filterBlock)(NSObject*)){
    return binding(object1, pathKey1, object2, pathKey2, nil, nil, nil, filterBlock);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, void (^valueUpdateBlock)(NSObject *), BOOL (^filterBlock)(NSObject*)){
    return binding(object1, pathKey1, nil, nil, nil, nil, nil, valueUpdateBlock, filterBlock);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator, BOOL (^filterBlock)(NSObject*)){
    return binding(object1, pathKey1, object2, pathKey2, value1ToValue2Block, value2ToValue1Block, comparator, nil, filterBlock);
}

__attribute__((overloadable)) Binding* binding(
                                               NSObject* object1,
                                               NSString* pathKey1,
                                               NSObject* object2,
                                               NSString* pathKey2,
                                               NSObject* (^value1ToValue2Block)(NSObject*),
                                               NSObject* (^value2ToValue1Block)(NSObject*),
                                               NSComparator comparator,
                                               void (^valueUpdateBlock)(NSObject*),
                                               BOOL (^filterBlock)(NSObject*)){

    Binding *binder = [[Binding alloc]init];
    binder.comparator = comparator;
    binder.valueUpdateBlock = valueUpdateBlock;
    binder.filterBlock = filterBlock;

    if(object1 != nil){
        [binder setObject1:object1 keyPath:pathKey1];
    }

    if(object2 != nil){
        binder.value1ToValue2Block = value1ToValue2Block;
        binder.value2ToValue1Block = value2ToValue1Block;

        [binder setObject2:object2 keyPath:pathKey2];
    }

    NSObject *value1 = [object1 valueForKeyPath:pathKey1];
    binder.value = value1;

    return binder;
}

@implementation Binding {
    NSString* _identifier1;
    NSString* _identifier2;
}

-(id)init{
    if(self = [super init]){
        self.value = nil;
    }
    return self;
}

-(void)setValue:(NSObject*)value{
    if(value == [NSNull null]){
        value = nil;
    }
    
    NSObject *prevValue = _value;
    if(prevValue == value || [prevValue isEqual:value]){
        return;
    }
    
    if(self.filterBlock && !self.filterBlock(value)){
        return;
    }
    _value = value;
    [self syncValue];
}

-(void)syncValue{
    NSObject *value1 = [_object1 valueForKeyPath:_keyPath1];
    NSObject *value2 = [_object2 valueForKeyPath:_keyPath2];

    if(value1 == [NSNull null]){
        value1 = nil;
    }

    if(value2 == [NSNull null]){
        value2 = nil;
    }

    if(self.value2ToValue1Block){
        value2 = self.value2ToValue1Block(value2);
    }

    if(_comparator){
        BOOL value1NotChanged = _comparator(value1, _value) == NSOrderedSame;
        BOOL value2NotChanged = _comparator(value2, _value) == NSOrderedSame;
        if(!value1NotChanged){
            [_object1 setValue:_value forKeyPath:_keyPath1];
        }
        if(!value2NotChanged){
            if(self.value1ToValue2Block){
                [_object2 setValue:self.value1ToValue2Block(_value) forKeyPath:_keyPath2];
            }
            else{
                [_object2 setValue:_value forKeyPath:_keyPath2];
            }
        }
    }
    else{
        if(_value == nil){
            if(value1 != nil){
                [_object1 setValue:_value forKeyPath:_keyPath1];
            }

            if(value2 != nil){
                if(self.value1ToValue2Block){
                    [_object2 setValue:self.value1ToValue2Block(_value) forKeyPath:_keyPath2];
                }
                else{
                    [_object2 setValue:_value forKeyPath:_keyPath2];
                }
            }
        }
        else{
            if( ![_value isEqual:value1]){
                [_object1 setValue:_value forKeyPath:_keyPath1];
            }

            if(![_value isEqual:value2]){
                if(self.value1ToValue2Block){
                    [_object2 setValue:self.value1ToValue2Block(_value) forKeyPath:_keyPath2];
                }
                else{
                    [_object2 setValue:_value forKeyPath:_keyPath2];
                }
            }
        }
    }

    if(self.valueUpdateBlock){
        self.valueUpdateBlock(_value);
    }
}

-(void)setObject1:(NSObject *)object keyPath:(NSString*)keyPath {
    _object1 = object;
    _keyPath1 = keyPath;

    typeof(self) __weak weakSelf = self;
    _identifier1 = [object bk_addObserverForKeyPath:keyPath options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSObject *value = change[NSKeyValueChangeNewKey];
        weakSelf.value = value;
    }];
}

-(void)setObject2:(NSObject *)object keyPath:(NSString*)keyPath {
    _object2 = object;
    _keyPath2 = keyPath;

    typeof(self) __weak weakSelf = self;
    _identifier2 = [object bk_addObserverForKeyPath:keyPath options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSObject *value = change[NSKeyValueChangeNewKey];
        if(weakSelf.value2ToValue1Block){
            value = weakSelf.value2ToValue1Block(value);
        }
        weakSelf.value = value;
    }];
}

-(void)dealloc{
    NSObject *object1 = _object1;
    if(object1){
        [object1 bk_removeObserversWithIdentifier:_identifier1];
    }

    NSObject *object2 = _object2;
    if(object2){
        [object2 bk_removeObserversWithIdentifier:_identifier2];
    }
}
@end