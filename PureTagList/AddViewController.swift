//
//  AddViewController.swift
//  PureTagList
//
//  Created by 五月 on 2017/8/20.
//  Copyright © 2017年 孙凯峰. All rights reserved.
//

import UIKit
var i = 0
class AddViewController: UIViewController {
    var titlesArr:[String] = ["神雕侠侣","江湖","射雕英雄传"]
    var tagList:PureTagList!
    override func viewDidLoad() {
        super.viewDidLoad()
        tagList = PureTagList()
        tagList.backgroundColor = .gray
        tagList.clickTagBlock = {[weak self] (tag:String)  in
        self?.tagList.deleteTag(tag)
        }
        tagList.frame = CGRect(x: 0, y: 90, width: self.view.bounds.size.width, height: 0)
        tagList.tagBackgroundColor = UIColor.purple
        tagList.tagDeleteimage =  UIImage(named: "chose_tag_close_icon")
        view.addSubview(tagList)
        
        
        
        
 
        // Do any additional setup after loading the view.
    }

    @IBAction func addClick(_ sender: UIButton) {
        let tagStr: String = "\(titlesArr[Int(arc4random_uniform(3))])  \(i)"
        tagList.addTag(tagStr)
        i += 1

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
