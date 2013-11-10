//
//  Ovulation_CalculatorViewController.m
//  Ovulation Calculator
//
//  Created by Andy Brown on 06/01/2013.
//  Copyright (c) 2013 Andy Brown. All rights reserved.
//

#import "Ovulation_CalculatorViewController.h"
#import <EventKit/EKEventStore.h>
#import <EventKit/EKEvent.h>

@interface Ovulation_CalculatorViewController ()

@end

@implementation Ovulation_CalculatorViewController

@synthesize dayArray, dayPicker, datePicker;
//initialise getters and setters on properties

//Collection of the calculated dates that
//are passed on to the next class
NSMutableArray *calculatedDatesArray;
int dayPickerDay;
NSDate *lastOvulationDate;
NSDate *nextOvulationDate;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //dayPicker.delegate = self;
    
    dayArray = [[NSMutableArray alloc] init];
    
    for(int i = 1; i <= 31; i++){
        [dayArray addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return dayArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [dayArray objectAtIndex:row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Gets fired when the next button is pressed
- (IBAction)calculateButton:(id)sender {
    [self calculateFutureDates];
}

//Adds an event into iCal
- (void)addCalendarEvent{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        NSLog(@"Was not able to access the calendar db");
    }];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    event.calendar = [eventStore defaultCalendarForNewEvents];
    event.notes = @"We have calculated that you are ovulating today.";
    event.title = @"Ovulation day";
    event.startDate = [[NSDate alloc]init];
    event.endDate = [[NSDate alloc ]init];
    event.allDay = YES;
    
    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
    
    NSError *error = [[NSError alloc]init];
    [eventStore saveEvent:event span:EKSpanThisEvent error:&error];
    
    if(error.code == noErr){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Event Created"
                              message:@"The following event has been added to your calendar."
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
		[alert show];
    }
    
    
}

//Adds days to the given date
- (NSDate *)addDaysToDate:(NSDate *)currentDate{
    //Set up the components and calendar
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    
    NSUInteger componentFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *currentDateComponents = [[NSCalendar currentCalendar] components:componentFlags fromDate:currentDate];
    
    //Set the hour and minutes to zero to avoid
    //picking up the system time, i.e. 02:57am et cetera
    [currentDateComponents setHour:0];
    [currentDateComponents setMinute:0];
    
    //Do the same for the dayComponents
    [dayComponent setHour:0];
    [dayComponent setMinute:0];
    
    //Now set the new date object to have the exact same date as was
    //picked up from the user
    [currentDateComponents setYear:[currentDateComponents year]];
    [currentDateComponents setMonth:[currentDateComponents month]];
    [currentDateComponents setDay:[currentDateComponents day]];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    //Sets the new current date with midnight as the default time
    NSDate *currentDateWithZeroedTime = [calendar dateFromComponents:currentDateComponents];
    
    //Choose the number of days to add to the date
    //but first ensure that there is a default value
    //in case the user has not made a selection
    if(dayPickerDay < 1){
        dayPickerDay = 1;
    }
    
    dayComponent.day = dayPickerDay;
    
    //Get the new date by adding the number of days to the current date
    NSDate *futureDate = [calendar dateByAddingComponents:dayComponent toDate:currentDateWithZeroedTime options:0];
    
    return futureDate;
}

//Called from calculateButton - controls all of the events
- (void)calculateFutureDates{
    
    //Initialise the array
    calculatedDatesArray = [[NSMutableArray alloc] init];
    
    //sets the ovulation date
    lastOvulationDate = datePicker.date;
    
    for(int i = 1; i < 25; i++){
        //work out the next ovulation date
        nextOvulationDate = [self addDaysToDate:lastOvulationDate];
        
        //add to the array
        [calculatedDatesArray addObject:nextOvulationDate];
        
        //set the future date as the current date
        lastOvulationDate = nextOvulationDate;
    }
    
    //Set the date format that will be displayed to the user
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    
    //Initialise string ready for building the dates
    NSMutableString *dateString = [[NSMutableString alloc] init];
    
    NSInteger arrayCount = calculatedDatesArray.count;
    
    for(int i = 0; i < arrayCount; i++){
        [dateString appendFormat:@"%@\n",[formatter stringFromDate:[calculatedDatesArray objectAtIndex:i]]];
    }
    
    //Display the output to the user
    UIAlertView *popupResuts = [[UIAlertView alloc] init];
    [popupResuts setTitle:@"Calculated dates"];
    [popupResuts setMessage:dateString];
    [popupResuts show];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSString *dayPickerStringValue = [dayArray objectAtIndex:row];
    dayPickerDay = [dayPickerStringValue intValue];
}

@end
