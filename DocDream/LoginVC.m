//
//  LoginVC.m
//  DocDream
//
//  Created by YDWY on 2017/10/11.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "LoginVC.h"
#import "MianVCTableViewController.h"
#import <AFNetworking.h>
@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;

@property (weak, nonatomic) IBOutlet UITextField *passTF;


@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _userNameTF.text = @"李强";
//    _passTF.text = @"lq123456";
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (IBAction)login:(id)sender {
    
    if (!_userNameTF.text || !_passTF.text || [_userNameTF.text isEqualToString:@""] || [_passTF.text isEqualToString:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入账户名和密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }else{
        AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
        manger.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manger POST:@"http://yxtest.xgyuanda.com/Api/index/dl" parameters:@{@"user":_userNameTF.text,@"pwd":_passTF.text} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",dict[@"status"]);
            if ([dict[@"status"] isEqual:@0]) {
                MianVCTableViewController * vc = [[MianVCTableViewController alloc] init];
                vc.ID = [dict[@"result"] integerValue];
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
                
                [self presentViewController:nav animated:YES completion:^{
                    
                }];
            }else{
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:dict[@"msg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
          
           
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
    }
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
