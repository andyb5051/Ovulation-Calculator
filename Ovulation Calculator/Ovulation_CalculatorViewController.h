//
//  Ovulation_CalculatorViewController.h
//  Ovulation Calculator
//
//  Created by Andy Brown on 06/01/2013.
//  Copyright (c) 2013 Andy Brown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ovulation_CalculatorViewController : UIViewController

- (IBAction)calculateButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIPickerView *dayPicker;
@property (strong, nonatomic) NSMutableArray *dayArray;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;

@end
