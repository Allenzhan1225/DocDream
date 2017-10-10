//
//  MainDetailVC.m
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MainDetailVC.h"
#import "MainDetailCell.h"
#import <AFNetworking.h>
#import <JSONModel.h>
#import "MainModel.h"
@interface MainDetailVC ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray * dataSource;
@property (nonatomic,strong) AFHTTPSessionManager * httpMgr;
@end

@implementation MainDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"问答详情";
    [self.myTableView registerNib:[UINib nibWithNibName:@"MainDetailCell" bundle:nil] forCellReuseIdentifier:@"MainDetailCell"];
    [self loadData];
    

        
 


}

-(void)loadData{
    _httpMgr = [AFHTTPSessionManager manager];
    _httpMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString * url = [NSString stringWithFormat:@"http://yxtest.xgyuanda.com/Api/index/wenda_xq?id=%ld",_model.ID];
    [_httpMgr GET:url parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * arr =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        for (NSDictionary * dict in arr) {
        
        }
        NSLog(@"dataSource = %@",self.dataSource);
        [self.myTableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma UITableView 代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MainDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MainDetailCell"];
    return cell;
}



#pragma 懒加载
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}



@end
