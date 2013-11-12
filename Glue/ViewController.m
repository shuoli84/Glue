//
//  ViewController.m
//  Glue
//
//  Created by Li Shuo on 13-10-30.
//  Copyright (c) 2013年 Li Shuo. All rights reserved.
//

#import "ViewController.h"
#import "Binding.h"
#import "UIControl+BlocksKit.h"
#import "NSObject+BlockObservation.h"
#import "UIGestureRecognizer+BlocksKit.h"


@interface Contact : NSObject

@property (nonatomic, strong) NSString* name;

@end

@implementation Contact

@end


@interface ViewController ()
@property (nonatomic, strong) Contact* contact;
@property (nonatomic, strong) NSMutableArray* binders;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.binders = [NSMutableArray array];

    Contact *contact = [Contact new];
    contact.name = @"";
    self.contact = contact;

    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 300, 40)];
    UITextField *textField1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 80, 300, 40)];

    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 50, 300, 40)];
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(100, 120, 300, 40)];

    [self.binders addObject:binding(contact, @"name", label1, @"text")];
    Binding *editing = binding(contact, @"name", textField1, @"text");
    [self.binders addObject:editing];
    [textField1 addEventHandler:^(UITextField *sender) {
        editing.value = sender.text;
    } forControlEvents:UIControlEventEditingChanged];

    [self.binders addObject:binding(contact, @"name", label2, @"text")];
    [self.binders addObject:binding(contact, @"name", label3, @"text", ^(NSObject* value1){
        int value = [(NSString*)value1 integerValue];
        return [NSString stringWithFormat:@"%d", value];
    },
    ^(NSObject *value2){
        int value = [(NSString*)value2 integerValue];
        return [NSString stringWithFormat:@"%d", value];
    },
    nil)];

    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor redColor];
        button.frame = CGRectMake(30, 100, 40, 40);
        button.titleLabel.text = @"press";
        [button addEventHandler:^(id sender) {
            label1.text = [NSString stringWithFormat:@"%@%@", label1.text,@"1"];
        } forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = [UIColor redColor];

        [self.view addSubview:button];
    }

    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(60, 100, 40, 40);
        button.backgroundColor = [UIColor greenColor];
        button.tintColor = [UIColor greenColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addEventHandler:^(id sender) {
            label3.text = [NSString stringWithFormat:@"%d", label3.text.integerValue + 2];
        } forControlEvents:UIControlEventTouchUpInside];

        UIButton* __weak weakButton = button;
        [self.binders addObject: binding(contact, @"name", ^(NSObject* value){
            [weakButton setTitle:(NSString *)value forState:UIControlStateNormal];
        })];

        [self.view addSubview:button];
    }

    UILabel *formatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 300, 30)];

    Binding *formatedBinding = binding(contact, @"name", formatedLabel, @"text", ^(NSObject *value1){
        NSString* string = (NSString*)value1;
        int integer = string.integerValue;
        return [NSString stringWithFormat:@"%d.0", integer];
    }, ^(NSObject *value2){
        NSString* string = (NSString*) value2;
        int integer = string.integerValue;
        return [NSString stringWithFormat:@"%d", integer];
    },
    ^(NSObject *obj1, NSObject *obj2){
        int i1 = [(NSString *)obj1 integerValue];
        int i2 = [(NSString *)obj2 integerValue];

        if(i1 == i2){
            return NSOrderedSame;
        }

        return NSOrderedAscending;
    });

    [self.binders addObject:formatedBinding];

    [self.view addSubview:formatedLabel];


    [self.view addSubview:label1];
    [self.view addSubview:label2];
    [self.view addSubview:label3];
    [self.view addSubview:textField1];
    
    Binding *animBinding = binding(contact, @"name", ^(NSObject *value){
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat v = [(NSString*)value floatValue];
            CGRect f = label1.frame;
            f.origin.x = v;
            label1.frame = f;
        }];
    });
    [self.binders addObject:animBinding];
    
    Binding *animBinding2 = binding(contact, @"name", ^(NSObject *value){
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat v = [(NSString*)value floatValue];
            label1.alpha = v/500;
        }];
    });
    [self.binders addObject:animBinding2];
    
    UIPanGestureRecognizer *panGestureRecognizer = [UIPanGestureRecognizer.alloc initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        static CGPoint startPoint;
        if(state == UIGestureRecognizerStateBegan){
            startPoint = location;
        }
        else{
            CGPoint t = CGPointMake(location.x - startPoint.x, location.y - startPoint.y);
            contact.name = [NSString stringWithFormat:@"%d", (int)t.x];
            
            if(state == UIGestureRecognizerStateEnded){
                if(location.x > 300){
                    contact.name = [NSString stringWithFormat:@"%d", 500];
                }
                else{
                    contact.name = @"0";
                }
            }
        }
    }];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
