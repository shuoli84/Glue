//
// Created by Li Shuo on 13-10-30.
// Copyright (c) 2013 Li Shuo. All rights reserved.
//


#import "Binding.h"
#import "NSObject+BlockObservation.h"

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2){
    return binding(object1, pathKey1, object2, pathKey2, nil, nil, nil);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, void (^valueUpdateBlock)(NSObject *)){
    return binding(object1, pathKey1, nil, nil, nil, nil, nil, valueUpdateBlock);
}


__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator){
    return binding(object1, pathKey1, object2, pathKey2, value1ToValue2Block, value2ToValue1Block, comparator, nil);
}

__attribute__((overloadable)) Binding* binding(NSObject* object1, NSString* pathKey1, NSObject* object2, NSString* pathKey2, NSObject* (^value1ToValue2Block)(NSObject*), NSObject* (^value2ToValue1Block)(NSObject*), NSComparator comparator, void (^valueUpdateBlock)(NSObject*)){

    Binding *binder = [[Binding alloc]init];
    binder.comparator = comparator;
    binder.valueUpdateBlock = valueUpdateBlock;

    [binder setObject1:object1 keyPath:pathKey1];

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

-(void)setValue:(NSObject*)value{
    NSObject *prevValue = _value;
    if([prevValue isEqual:value]){
        return;
    }
    _value = value;
    [self syncValue];
}

-(void)syncValue{
    NSLog(@"Sync value called");
    NSObject* value1 = [_object1 valueForKeyPath:_keyPath1];
    NSObject *value2 = [_object2 valueForKeyPath:_keyPath2];
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
        if([_value isEqual:[NSNull null]]){
            if(![value1 isEqual:[NSNull null]]){
                [_object1 setValue:_value forKeyPath:_keyPath1];
            }

            if(![value2 isEqual:[NSNull null]]){
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
    _identifier1 = [object addObserverForKeyPath:keyPath options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSObject *value = change[NSKeyValueChangeNewKey];
        weakSelf.value = value;
    }];
}

-(void)setObject2:(NSObject *)object keyPath:(NSString*)keyPath {
    _object2 = object;
    _keyPath2 = keyPath;

    typeof(self) __weak weakSelf = self;
    _identifier2 = [object addObserverForKeyPath:keyPath options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSObject *value = change[NSKeyValueChangeNewKey];
        weakSelf.value = value;
    }];
}

-(void)dealloc{
    NSObject *object1 = _object1;
    if(object1){
        [object1 removeObserversWithIdentifier:_identifier1];
    }

    NSObject *object2 = _object2;
    if(object2){
        [object2 removeObserversWithIdentifier:_identifier2];
    }
}
@end