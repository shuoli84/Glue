Glue binds data, keep them sync all the time
============================================
Bind means keep the values same. One value change, the other one updated too. Glue is a thin wrapper 
upon KVO. 

E.g, object A, B, bind A's name with B's text property, then you can do whatever change on A or B, the
other object's value will be updated automatically. 

What Glue did is create 2 observers, 1 for A, the other for B, when any value changed, it will try to 
update both A & B's value. It will only set object's value if the new value and original value are different,
this prevents recursive setting loop. 

Bind property for objects
-------------------------
Bind contact's name to a label, which is a common task we do everyday.

    Contact *contact = [Contact new];
    contact.name = @"";
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(100, 20, 300, 40)];
    
    // bind property for objects
    self.nameBinding = binding(contact, @"name", label1, @"text");
    
Bind property to a block
------------------------
Instead of bind the value to another value, would like to run some arbitrary code? 

    // bind block to object's property
    self.animateBinding = binding(contact, @"age", ^(NSObject *value){
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat v = [(NSString*)value floatValue];
            label1.alpha = v/500;
        }];
    });
    
Bind property with customized logic
----------------------------------
The value sync logic is complicated? Then just provide 3 blocks, value1 -> value2, value2 -> value1, 
and equality compare block.

    // customized value mapping
    self.formatedBinding = binding(contact, @"name", formatedLabel, @"text", 
    // Convert from object1's value to object2's
    ^(NSObject *value1){
        NSString* string = (NSString*)value1;
        int integer = string.integerValue;
        return [NSString stringWithFormat:@"%d.0", integer];
    },
    // Convert from object2's to object1's
    ^(NSObject *value2){
        NSString* string = (NSString*) value2;
        int integer = string.integerValue;
        return [NSString stringWithFormat:@"%d", integer];
    },
    // Are they equal?
    ^(NSObject *obj1, NSObject *obj2){
        int i1 = [(NSString *)obj1 integerValue];
        int i2 = [(NSString *)obj2 integerValue];

        if(i1 == i2){
            return NSOrderedSame;
        }

        return NSOrderedAscending;
    });

Install CocoaPods
--------------------------

    pod 'Glue', :podspec => "https://raw.github.com/shuoli84/Glue/master/Glue.podspec"
    
License
--------------------------
MIT license.
