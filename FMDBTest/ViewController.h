//
//  ViewController.h
//  FMDBTest
//
//  Created by Jason on 2016/6/2.
//  Copyright © 2016年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

@interface ViewController : UIViewController
{
    FMDatabase *db;
    IBOutlet UITextView *resultTV;
}

@end

