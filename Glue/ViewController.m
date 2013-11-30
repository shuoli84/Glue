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


@interface ScrollAnimEntry : NSObject
@property (nonatomic, strong) NSObject *object;
@property (nonatomic, strong) NSString *keypath;
@property (nonatomic, assign) CGFloat fromValue;
@property (nonatomic, assign) CGFloat toValue;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic, assign) CGPoint startContentOffset;
@property (nonatomic, assign) CGPoint endContentOffset;

+(ScrollAnimEntry*)entryWithObject:(NSObject*)object
                           keyPath:(NSString*)keyPath
                              from:(CGFloat)fromValue
                                to:(CGFloat)toValue
                startContentOffset:(CGPoint)startContentOffset
                  endContentOffset:(CGPoint)endContentOffset;

-(CGFloat)valueForContentOffset:(CGPoint)contentOffset;

-(void)setContentOffset:(CGPoint)contentOffset;
@end

@implementation ScrollAnimEntry

+(ScrollAnimEntry*)entryWithObject:(NSObject *)object keyPath:(NSString *)keyPath from:(CGFloat)fromValue to:(CGFloat)toValue startContentOffset:(CGPoint)startContentOffset endContentOffset:(CGPoint)endContentOffset{
    ScrollAnimEntry *entry = [ScrollAnimEntry.alloc init];
    entry.object = object;
    entry.keypath = keyPath;
    entry.fromValue = fromValue;
    entry.toValue = toValue;
    entry.startContentOffset = startContentOffset;
    entry.endContentOffset = endContentOffset;
    return entry;
}

-(CGFloat)valueForContentOffset:(CGPoint)contentOffset{
    float ys = _startContentOffset.y;
    float ye = _endContentOffset.y;
    float y = contentOffset.y;
    float ration = (y - ys) / (ye - ys);
    if(ration < 0){
        return INFINITY;
    }
    else{
        return _fromValue + (_toValue - _fromValue) * ration;
    }
}

-(void)setContentOffset:(CGPoint)contentOffset{
    float v = [self valueForContentOffset:contentOffset];
    if(v == INFINITY){
        return;
    }
    _currentValue = v;
    [_object setValue:@(_currentValue) forKey:_keypath];
}
@end

@interface ScrollAnim : NSObject
@property (nonatomic, strong) NSMutableArray *animEntries;

-(void)setContentOffset:(CGPoint)contentOffset;
@end

@implementation ScrollAnim
-(id)init{
    if((self = super.init)){
        self.animEntries = [NSMutableArray array];
    }
    return self;
}

-(void)setContentOffset:(CGPoint)contentOffset{
    for(ScrollAnimEntry *entry in _animEntries){
        [entry setContentOffset:contentOffset];
    }
}

@end

@interface Contact : NSObject

@property (nonatomic, strong) NSString* name;

@end

@implementation Contact

@end


@interface ViewController ()
@property (nonatomic, strong) Contact* contact;
@property (nonatomic, strong) NSMutableArray* binders;
@property (nonatomic, strong) ScrollAnim* anim;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.anim = [ScrollAnim.alloc init];

    self.binders = [NSMutableArray array];

    Contact *contact = [Contact new];
    contact.name = @"100";
    self.contact = contact;

    UILabel *title1 = [UILabel.alloc initWithFrame:CGRectMake(20, 20, 80, 40)];
    title1.text = @"title";
    [self.view addSubview:title1];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 300, 40)];
    label1.backgroundColor = [UIColor colorWithRed:52/255.f green:152/255.f blue:219/255.f alpha:1.f];
    label1.textColor = [UIColor whiteColor];
    [self.binders addObject:binding(contact, @"name", label1, @"text")];
    [self.view addSubview:label1];
    
    UILabel *title2 = [UILabel.alloc initWithFrame:CGRectMake(20, 70, 80, 40)];
    title2.text = @"frame";
    [self.view addSubview:title2];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 70, 300, 40)];
    Binding *animBinding = binding(contact, @"name", ^(NSObject *value){
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat v = [(NSString*)value floatValue];
            CGRect f = label2.frame;
            f.origin.x = v;
            label2.frame = f;
        }];
    });
    [self.binders addObject:animBinding];
    [self.view addSubview:label2];
    
    {
        UILabel *title2 = [UILabel.alloc initWithFrame:CGRectMake(20, 120, 80, 40)];
        title2.text = @"alpha";
        [self.view addSubview:title2];
    }
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(100, 120, 300, 40)];
    label3.backgroundColor = [UIColor colorWithRed:46/255.f green:204/255.f blue:113/255.f alpha:1.f];
    [self.binders addObject:binding(contact, @"name", label2, @"text")];
    [self.view addSubview:label3];
    [self.binders addObject:binding(contact, @"name", label3, @"text", ^(NSObject* value1){
        int value = [(NSString*)value1 integerValue];
        return [NSString stringWithFormat:@"%d", value];
    },
    ^(NSObject *value2){
        int value = [(NSString*)value2 integerValue];
        return [NSString stringWithFormat:@"%d", value];
    },
    nil)];
    Binding *animBinding2 = binding(contact, @"name", ^(NSObject *value){
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat v = [(NSString*)value floatValue];
            label3.alpha = v/500;
            label3.alpha = MAX(0.3, label3.alpha);
        }];
    });
    [self.binders addObject:animBinding2];
    
    
    {
        UILabel *title2 = [UILabel.alloc initWithFrame:CGRectMake(20, 170, 80, 40)];
        title2.text = @"edit it";
        [self.view addSubview:title2];
    }
    UITextField *textField1 = [[UITextField alloc] initWithFrame:CGRectMake(100, 170, 300, 40)];
    textField1.borderStyle = UITextBorderStyleLine;
    [self.binders addObject:binding(contact, @"name", textField1, @"text")];
    typeof(self) __weak weakSelf = self;
    [textField1 addEventHandler:^(UITextField *sender) {
        weakSelf.contact.name = sender.text;
    } forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:textField1];
    
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor redColor];
        button.frame = CGRectMake(100, 220, 80, 40);
        [button setTitle:@"1+" forState:UIControlStateNormal];
        [button addEventHandler:^(id sender) {
            label1.text = [NSString stringWithFormat:@"%@%@", label1.text,@"1"];
        } forControlEvents:UIControlEventTouchUpInside];
        button.tintColor = [UIColor redColor];

        [self.view addSubview:button];
    }

    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(100, 270, 80, 40);
        button.backgroundColor = [UIColor colorWithRed:26/255.f green:188/255.f blue:156/255.f alpha:1.f];
        [button setTitle:@"+2" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addEventHandler:^(id sender) {
            label3.text = [NSString stringWithFormat:@"%d", label3.text.integerValue + 2];
        } forControlEvents:UIControlEventTouchUpInside];

        [self.view addSubview:button];
    }

    
    {
        UILabel *title2 = [UILabel.alloc initWithFrame:CGRectMake(20, 320, 80, 40)];
        title2.text = @"format";
        [self.view addSubview:title2];
    }
    UILabel *formatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 320, 300, 30)];
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
    
    
    {
        UILabel *title2 = [UILabel.alloc initWithFrame:CGRectMake(20, 350, 300, 40)];
        title2.text = @"Pan gesture, try it by pan on view";
        [self.view addSubview:title2];
    }
    UIPanGestureRecognizer *panGestureRecognizer = [UIPanGestureRecognizer.alloc initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        static float start;
        static CGPoint startPoint;
        if(state == UIGestureRecognizerStateBegan){
            start = contact.name.floatValue;
            startPoint = location;
        }
        else{
            float v = location.x - startPoint.x + start;
            contact.name = [NSString stringWithFormat:@"%d", (int)v];
            
            if(state == UIGestureRecognizerStateEnded){
                if(contact.name.integerValue > 300){
                    contact.name = [NSString stringWithFormat:@"%d", 500];
                }
                else{
                    contact.name = @"100";
                }
            }
        }
    }];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    {
        UILabel *title2 = [UILabel.alloc initWithFrame:CGRectMake(20, 400, 300, 40)];
        title2.text = @"dynamic content in scroll view";
        [self.view addSubview:title2];
    }
    UIScrollView *scrollView = [UIScrollView.alloc initWithFrame:CGRectMake(100, 450, 500, 500)];
    scrollView.backgroundColor = [UIColor grayColor];
    
    [self.anim.animEntries addObjectsFromArray:@[
                                                 [ScrollAnimEntry entryWithObject:label1 keyPath:@"alpha" from:0.3 to:1.0 startContentOffset:CGPointMake(0, 0) endContentOffset:CGPointMake(0, 300)],
                                                 [ScrollAnimEntry entryWithObject:label2 keyPath:@"alpha" from:0.2 to:0.8 startContentOffset:CGPointMake(0, 0) endContentOffset:CGPointMake(0, 300)],
                                                 ]];
    
    scrollView.contentSize = CGSizeMake(500, 2000);
    
    {
        UILabel *label1 = [UILabel.alloc initWithFrame:CGRectMake(0, 500, 500, 50)];
        [scrollView addSubview:label1];
        
        Binding *binding1 = binding(scrollView, @"contentOffset", ^(NSObject*value){
            CGPoint offset = [(NSValue*)value CGPointValue];
            label1.frame = CGRectMake(offset.y, offset.y, 500, 50);
            label1.text = [NSString stringWithFormat:@"%f", offset.y];
            
            [weakSelf.anim setContentOffset:offset];
        });
        [self.binders addObject:binding1];
    }
    [self.view addSubview:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
