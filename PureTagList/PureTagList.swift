//
//  PureTagList.swift
//  PureTagList
//
//  Created by 孙凯峰 on 2017/8/17.
//  Copyright © 2017年 孙凯峰. All rights reserved.
//

import UIKit
let imageViewWH: CGFloat = 20

class PureTagList: UIView {
    /* 标签删除图片 */
    var tagDeleteimage: UIImage?
    /*   标签间距,和距离左，上间距,默认10 */
    var tagMargin: CGFloat = 10.0
    /* 标签颜色，默认红色 */
    var tagColor: UIColor = .red
    /*  标签背景颜色 */
    var tagBackgroundColor: UIColor?
    /*  标签背景图片   */
    var tagBackgroundImage: UIImage?
    var tagFont:UIFont = UIFont.systemFont(ofSize: 13)
    /* 标签按钮内容间距，标签内容距离左上下右间距，默认5 */
    var tagCornerRadius:CGFloat = 5
    var tagButtonMargin:CGFloat = 5
    var tagListH:CGFloat? {
        get {
            if self.tagButtons.count <= 0 {
                return 0
            }
            return (self.tagButtons.last?.frame)!.maxY + tagMargin
        }
    }
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .red
    /** 获取所有标签*/
    lazy private(set) var tagArray = [Any]()
    /* 是否需要自定义tagList高度，默认为true*/
    var isFitTagListH: Bool = true
    /* 是否需要排序功能*/
    var isSort: Bool = false
    var scaleTagInSort:CGFloat? {
        didSet {
            let scale:CGFloat = 1.0
            if  scaleTagInSort! < scale  {
                print("scaleTagInSort必须大于1")
            }
        }
    }
    var tagClass:UIButton?
    var tagSize:CGSize?
    /*标签间距会自动计算*/
    var tagListCols:Int = 4
    var clickTagBlock:((String) ->Void)?
    weak var  tagListView:UICollectionView?
    lazy var tags:[String:AnyObject] = [String:AnyObject]()
    lazy var tagButtons:[UIButton] = [UIButton]()
    /* 需要移动的矩阵 */
    var moveFinalRect:CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    var oriCenter:CGPoint?
    override init(frame:CGRect){
        super.init(frame: frame)
        self.clipsToBounds = true
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setScaleTagInSort(_ scaleTagInSort:CGFloat)  {
        if  scaleTagInSort < 1  {
            
        }
    }
    // 添加多个标签
    func addTags(_ tagStrs:Array<Any>)  {
        assert(self.frame.size.width != 0 , "先设置标签列表的frame")
        for tagStr in tagStrs{
            self.addTag(tagStr as! String)
        }
    }
    func addTag(_ tagStr:String)  {
        let tagButton = PureTagButton()
        tagButton.setTitle("fff", for: .normal)
        tagButton.margin = tagButtonMargin
        tagButton.layer.cornerRadius = tagCornerRadius
        tagButton.layer.borderWidth = borderWidth
        tagButton.layer.borderColor = borderColor.cgColor
        tagButton.clipsToBounds = true
        tagButton.tag = self.tagButtons.count
        tagButton.setImage(tagDeleteimage, for: .normal)
        tagButton.setTitle(tagStr, for: .normal)
        tagButton.backgroundColor = tagBackgroundColor
        tagButton.titleLabel?.font = tagFont
        tagButton.addTarget(self, action: #selector(clickTag(_:)), for: .touchUpInside)
        if isSort {
            let pan = UIPanGestureRecognizer.init(target: self, action:  #selector(pan(_:)))
            tagButton .addGestureRecognizer(pan)
        }
        self.addSubview(tagButton)
        self.tagButtons.append(tagButton)
        self.tags[tagStr]  = tagButton
        self.tagArray.append(tagStr)
        // 设置按钮的位置
        self.updateTagButtonFrame(tagButton.tag, extreMargin: true)
        if (isFitTagListH){
            var frame = self.frame
            frame.size.height = self.tagListH!
            UIView.animate(withDuration: 0.25, animations: {
                self.frame = frame
            })
        }
    }
    func clickTag(_ sender:UIButton)  {
        if (clickTagBlock != nil) {
            clickTagBlock!(sender.currentTitle!)
        }
    }
    func pan(_ sender:UIPanGestureRecognizer)  {
        //获取偏移量
        let transP = sender.translation(in: self)
        let tagButton = sender.view as! UIButton
        // 开始
        if sender.state == .began {
            oriCenter = tagButton.center
            UIView.animate(withDuration: 0.25, animations: {
                tagButton.transform = CGAffineTransform(scaleX: self.scaleTagInSort!, y: self.scaleTagInSort!)
            })
            self.addSubview(tagButton)
        }
        var center = tagButton.center
        center.x += transP.x
        center.y += transP.y
        tagButton.center = center
        // 改变
        if sender.state == .changed {
            let otherButton = self.buttonCenterInButtons(tagButton)
            if (otherButton != nil) { //插入到当前按钮的位置
                // 获取插入的角标
                let i = otherButton?.tag
                //获取当前角标
                let curI = tagButton.tag
                moveFinalRect = (otherButton?.frame)!
                //排序
                // 移除之前的按钮
                self.tagButtons.remove(at: curI)
                self.tagButtons.insert(tagButton, at: i!)
                self.tagArray .remove(at: curI)
                self.tagArray.insert(tagButton.currentTitle ?? "hh", at: i!)
                //更新tag
                self.updateTag()
                if curI > i! {//向前插入
                    //更新之后的标签frame
                    UIView.animate(withDuration: 0.25, animations: {
                        self.updateLaterTagButtonFrame(i!+1)
                    })
                } else { // 往后插入
                    UIView.animate(withDuration: 0.25, animations: {
                        self.updateBeforeTagButtonFrame(i!)
                    })
                }
            }
        }
        // 结束
        if sender.state == .ended {
            UIView.animate(withDuration: 0.25, animations: {
                tagButton.transform = CGAffineTransform.identity
                if self.moveFinalRect.size.width <= CGFloat(0) {
                    tagButton.center = self.oriCenter!
                } else {
                    tagButton.frame = self.moveFinalRect
                }
            }, completion: { (true) in
                self.moveFinalRect = .zero
            })
        }
        sender.setTranslation(.zero, in: self)
    }
    //更新标签
    func updateTag()  {
        for (i,button) in self.tagButtons.enumerated() {
            let tagButton = button
            tagButton.tag = i
        }
    }
    func deleteTag(_ tagStr:String) {
        //  获取对应的标签
        let button = self.tags[tagStr]
        button?.removeFromSuperview()
        self.tagButtons.remove(at: (button?.tag)!)
        self.tags.removeValue(forKey: tagStr)
        self.tagArray.remove(at: (button?.tag)!)
        self.updateTag()
        UIView.animate(withDuration: 0.25) {
            self.updateLaterTagButtonFrame((button?.tag)!)
        }
        if isFitTagListH {
            var frame = self.frame
            frame.size.height = self.tagListH!
            UIView.animate(withDuration: 0.25, animations: {
                self.frame = frame
            })
        }
    }
    
    func updateBeforeTagButtonFrame(_ beforeI: Int)  {
        for i in 0..<beforeI {
            // 更新按钮
            updateTagButtonFrame(i, extreMargin: false)
        }
    }
    //更新以后的按钮
    func updateLaterTagButtonFrame(_ laterI: Int) {
        let count: Int = tagButtons.count
        for i in laterI..<count {
            // 更新按钮
            updateTagButtonFrame(i, extreMargin: false)
        }
    }
    func updateTagButtonFrame(_ i:Int,extreMargin:Bool)  {
        //获取上一个按钮
        let preI = i - 1
        //定义上一个按钮
        var preButton:UIButton?
        //过滤上一个脚标
        if preI >= 0 {
            preButton = self.tagButtons[preI]
        }
        //获取当前按钮
        let tagButton = self.tagButtons[i]
        // 判断是否设置标签的尺寸
        if  tagSize == nil {
            // 没有设置标签尺寸
            self.setupTagButtonCustomFrame(tagButton, preButton: preButton, extreMargin: extreMargin)
        }
        else {
            // 按规律排布
            self.setupTagButtonRegularFrame(tagButton)
        }
    }
    // 看下当前按钮中心点在哪个按钮上
    func buttonCenterInButtons(_ curButton:UIButton) -> UIButton? {
        for button in self.tagButtons {
            if curButton == button{
                continue
            }
            if button.frame.contains(curButton.center) {
                return button
            }
        }
        return nil
    }
    
    
    func setupTagButtonRegularFrame(_ tagButton:UIButton)  {
        // 获取角标
        let i = tagButton.tag
        let col = i % tagListCols
        let row = i / tagListCols
        let btnW:CGFloat = (tagSize?.width)!
        let btnH:CGFloat = (tagSize?.height)!
        let margin = (self.bounds.size.width - CGFloat(tagListCols) * btnW - 2 * tagMargin) / CGFloat(tagListCols - 1)
        let btnX =  tagMargin + CGFloat(col) * (btnW + margin)
        let btnY = tagMargin + CGFloat(row) * (btnH + margin)
        tagButton.frame = CGRect(x: btnX, y: btnY, width: btnW, height: btnH)
        
    }
    func setupTagButtonCustomFrame(_ tagButton:UIButton,preButton:UIButton?,extreMargin:Bool)   {
        // 等于上一个按钮的最大X + 间距
        var btnX = (preButton != nil) ? ((preButton?.frame.maxX)!  + tagMargin) : tagMargin
        var btnY = (preButton != nil) ? preButton?.frame.origin.y : tagMargin
        // 获取按钮宽度
        let titleString: NSString = tagButton.titleLabel?.text as! NSString
        let titleSize: CGSize? = titleString.size(attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 14.0)])
        let titleH = titleSize?.height
        let titleW = titleSize?.width
        var btnW = extreMargin ? titleW! + 2 * tagButtonMargin : tagButton.bounds.size.width
        if ((tagDeleteimage != nil) && extreMargin == true) {
            btnW += imageViewWH
            btnW += tagButtonMargin
        }
        // 获取按钮高度
        var btnH = extreMargin ? titleH! + 2*tagButtonMargin:tagButton.bounds.size.height
        
        if  (tagDeleteimage != nil) && extreMargin == true {
            let height = (imageViewWH > titleH!) ? imageViewWH :titleH
            btnH = height! + 2 * tagButtonMargin
        }
        // 判断当前按钮是否足够显示
        let rightWidth = self.bounds.size.width - btnX
        if rightWidth < btnW {
            // 不够显示，显示到下一行
            btnX = tagMargin
            btnY = (preButton?.frame.maxY)! + tagMargin
            
        }
        tagButton.frame = CGRect(x: btnX, y: btnY!, width: btnW, height: btnH)
    }
}
class PureTagButton: UIButton {
    var margin:CGFloat?
    override func layoutSubviews() {
        super.layoutSubviews()
        if (self.imageView?.frame.size.width)! < CGFloat(0) {
            return
        }
        let btnW = self.bounds.size.width
        let btnH = self.bounds.size.height
        self.titleLabel?.frame = CGRect(x: margin!, y: (self.titleLabel?.frame.origin.y)!, width: (self.titleLabel?.frame.size.width)!, height: (self.titleLabel?.frame.size.height)!)
        let imageX = btnW - (self.imageView?.frame.size.width)! - margin!
        self.imageView?.frame = CGRect(x: imageX, y: (btnH - imageViewWH)*0.5, width: imageViewWH, height: imageViewWH)
    }
}
