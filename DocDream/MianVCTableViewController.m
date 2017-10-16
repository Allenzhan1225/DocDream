//
//  MianVCTableViewController.m
//  DocDream
//
//  Created by YDWY on 2017/10/10.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "MianVCTableViewController.h"
#import "MainCell.h"
#import "AFNetworking.h"
#import <MJRefresh.h>
#import <UIImageView+WebCache.h>
#import "MainModel.h"
#import "MainDetailVC.h"

@interface MianVCTableViewController ()
@property (nonatomic,strong) NSMutableArray * dataSource;
@property (nonatomic,strong) AFHTTPSessionManager * httpMgr;
@property(nonatomic,assign) BOOL isHeaderRF;
@end

@implementation MianVCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"热门问答";
    [self.tableView registerNib:[UINib nibWithNibName:@"MainCell" bundle:nil] forCellReuseIdentifier:@"maincell"];

    [self loadData];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _isHeaderRF = YES;
        [self loadData];

    }];
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//
//    }];
    
}
-(void)loadData{
    _httpMgr = [AFHTTPSessionManager manager];
    _httpMgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_httpMgr GET:@"http://yxtest.xgyuanda.com/Api/index/rm_wenda" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray * arr =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if(_isHeaderRF){
            [self.dataSource removeAllObjects];
        }
        [self.tableView.mj_header endRefreshing];
//        [self.tableView.tableFooterView endEditing:YES];
        for (NSDictionary * dict in arr) {
            NSError *  error;
           MainModel * model =  [[MainModel alloc] initWithDictionary:dict error:&error];
            NSLog(@"error = %@",error);
           [self.dataSource addObject:model];
        }
        NSLog(@"dataSource = %@",self.dataSource);
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainCell" forIndexPath:indexPath];
    MainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"maincell"];
    MainModel * model = _dataSource[indexPath.row];
    cell.model = model;
    
    // Configure the cell...
    
    return cell;
}

#pragma 懒加载
-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MainModel * model = _dataSource[indexPath.row];
    
    MainDetailVC * vc = [[MainDetailVC alloc] init];
    vc.model = model;
    vc.doc_id = self.ID;
    [self.navigationController pushViewController:vc animated:YES];
}


@end
