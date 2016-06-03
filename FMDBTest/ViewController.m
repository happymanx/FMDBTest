//
//  ViewController.m
//  FMDBTest
//
//  Created by Jason on 2016/6/2.
//  Copyright © 2016年 HT. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 建立資料庫和表格
    [self createDatabaseAndTable];
    
    // 插入資料
    [self insertData];
    
    // 更新資料
    [self updateData];
    
    // 丟棄表格
//    [self dropTable];
    
    // 選擇資料
    [self selectData];
    
    // 使用佇列
    [self useQueue];
}

-(void)createDatabaseAndTable
{
    // 1.獲得數據庫文件的路徑
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    
    // 2.獲得數據庫
    db = [FMDatabase databaseWithPath:fileName];
    
    // 3.使用如下語句，如果打開失敗，可能是權限不足或者資源不足。通常打開完操作操作後，需要調用close方法來關閉數據庫。在和數據庫交互之前，數據庫必須是打開的。如果資源或權限不足無法打開或創建數據庫，都會導致打開失敗。
    if ([db open])
    {
        // 4.創建表單
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_student (number integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, age integer NOT NULL);"];
        if (result)
        {
            NSLog(@"創建表單成功");
        }
    }
}

-(void)insertData
{
    NSString *name = @"HappyGirl";
    int age = 16;
    
    // 1.executeUpdate:不確定的參數用？來佔位（後面參數必須是oc對象，；代表語句結束）
    [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);", name, @(age)];
    
    // 2.executeUpdateWithForamat：不確定的參數用%@，%d等來佔位（參數為原始數據類型，執行語句不區分大小寫）
    //    [db executeUpdateWithFormat:@"insert into t_student (name, age) values ​​(%@,%i);", name, age];
    
    // 3.參數是數組的使用方式
    [db executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);" withArgumentsInArray:@[name, @(age)]];
}

-(void)updateData
{
    // 1.不確定的參數用？來佔位（後面參數必須是OC對象，需要將int包裝成OC對象）
    int idNum = 3;
    [db executeUpdate:@"delete from t_student where number = ?;", @(idNum)];
    
    // 2.不確定的參數用%@，%d等來佔位
    [db executeUpdateWithFormat:@"delete from t_student where name = %@;", @"Happyboy"];
    
    // 修改學生的名字
    [db executeUpdate:@"update t_student set name = ? where name = ?", @"HappyGL", @"Happygirl"];
}

-(void)dropTable
{
    // 如果表格存在則銷毀
    [db executeUpdate:@"drop table if exists t_student;"];
}

-(void)selectData
{
    // 查詢整個表
    FMResultSet *resultSet = [db executeQuery:@"select * from t_student;"];
    
    // 根據條件查詢
//    FMResultSet *resultSet = [db executeQuery:@"select * from t_student where number <?;", @(20)];
    
    NSString *resultStr = @"";
    // 遍歷結果集合
    while ([resultSet next]) {
        int idNum = [resultSet intForColumn:@"number"];
        NSString *name = [resultSet stringForColumn:@"name"];
        int age = [resultSet intForColumn:@"age"];
        
        NSString *rowStr = [NSString stringWithFormat:@"number: %i, name: %@, age: %i\n", idNum, name, age];
        
        resultStr = [resultStr stringByAppendingString:rowStr];
        
        resultTV.text = resultStr;
        
        NSLog(@"%@", rowStr);
    }
}

-(void)useQueue
{
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [doc stringByAppendingPathComponent:@"student.sqlite"];
    
    NSString *name = @"HappyJoy";
    int age = 36;

    // 1.創建隊列
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:fileName];
    __block BOOL whoopsSomethingWrongHappened = YES;
    
    // 2.把任務包裝到事務裡
    [queue inTransaction:^(FMDatabase *dbx, BOOL *rollback)
     {
         whoopsSomethingWrongHappened &= [dbx executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);", name, @(age)];
         whoopsSomethingWrongHappened &= [dbx executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);", name, @(age+1)];
         whoopsSomethingWrongHappened &= [dbx executeUpdate:@"INSERT INTO t_student (name, age) VALUES (?,?);", name, @(age+2)];
         // 如果有錯誤返回
         if (!whoopsSomethingWrongHappened)
         {
             *rollback = YES ;
             return ;
         }
     }];
}

@end
