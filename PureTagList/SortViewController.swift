//
//  SortViewController.swift
//  PureTagList
//
//  Created by 五月 on 2017/8/20.
//  Copyright © 2017年 孙凯峰. All rights reserved.
//

import UIKit

class SortViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let arr = ["PureTaglist","111","222","444","5555","6666","7777","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist","PureTaglist"];
        let taglist = PureTagList(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 230))
        taglist.scaleTagInSort = 1.3
        taglist.isSort = true
        taglist.tagSize = CGSize(width: 80, height: 30)
        taglist.isFitTagListH = false
        self.view.addSubview(taglist)
        taglist.tagBackgroundColor = .red
        taglist.tagColor = .white
        taglist.addTags(arr)
        
        let arr1 = ["蒸羊羔","战狼2","河南省","烩海参","清蒸江瑶柱","神雕侠侣","笑傲江湖","飞雪连天射白鹿","哈哈哈","哦哦","嘿嘿嘿","笑书神侠倚碧鸳"];
        let taglist1 = PureTagList(frame: CGRect(x: 0, y: 300, width: self.view.frame.size.width, height: 200))
        taglist1.isSort = false
        taglist1.tagBackgroundColor = .orange
        taglist1.isFitTagListH = false
        self.view.addSubview(taglist1)
        taglist1.tagBackgroundColor = .blue
        taglist1.tagColor = .white
        taglist1.addTags(arr1)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
