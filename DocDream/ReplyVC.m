//
//  ReplyVC.m
//  DocDream
//
//  Created by YDWY on 2017/10/11.
//  Copyright © 2017年 Allen. All rights reserved.
//

#import "ReplyVC.h"
#import <AFNetworking.h>
#import <UIView+Toast.h>
@interface ReplyVC ()<UITextViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ReplyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _textView.layer.borderWidth = 1;
}
//-(void)textViewDidBeginEditing:(UITextView *)textView{
//    textView.text = @"";
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   return [textField resignFirstResponder];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (IBAction)submit:(id)sender {
    
    NSLog(@"did = %ld iid = %ld ",_doc_id,_qustion_id);
    
    if (!_textView.text || [_textView.text isEqualToString:@""]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入回复内容" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }else{
        AFHTTPSessionManager * manger = [AFHTTPSessionManager manager];
        manger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
        manger.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manger POST:@"http://yxtest.xgyuanda.com/Api/index/doctor_hui" parameters:@{@"iid":[NSNumber numberWithInt:_qustion_id],@"did":[NSNumber numberWithInt:_doc_id],@"doc_statu":@"0",@"doctor":_textView.text} progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            NSLog(@"%@",responseObject);
            [[UIApplication sharedApplication].delegate.window.rootViewController.view makeToast:@"回复成功" duration:2.0 position:CSToastPositionCenter];
            [self.navigationController popViewControllerAnimated:YES];
//            if ([dict[@"status"] isEqual:@0]) {
//                MianVCTableViewController * vc = [[MianVCTableViewController alloc] init];
//                vc.ID = dict[@"result"];
//                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
//
//                [self presentViewController:nav animated:YES completion:^{
//
//                }];
//            }else{
//                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:dict[@"msg"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//
            
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
