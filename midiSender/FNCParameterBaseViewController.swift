//
//  FNCParameterView.swift
//  Sampler
//
//  Created by mbp on 2019/03/12.
//  Copyright © 2019年 mbp. All rights reserved.
//

import UIKit

class FNCParameterBaseViewController: UIViewController, UIScrollViewDelegate {

    internal var contentHeight: CGFloat = 0
    internal var mainViewY: CGFloat = 0

//    var backgroundImageView: UIImageView!
    var mainView: UIView!
    var titlebar: UIView!
    var titleLabel: UILabel!
    var parambar: UIView!
    var contentbar: UIView!
    var commitbar: UIView!
    var paramLabel:UILabel!
    var commitButton: UIButton!
    let minViewWidth: CGFloat = 300
    let minViewWidthMargin: CGFloat = 15
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black
        self.view.tag = 1001

        // 最低300 最高 画面の両脇余白残し
        viewWidth = max(self.view.frame.width - (minViewWidthMargin * 2), minViewWidth)

        let titleHeight: CGFloat = 50
        let paramHeight: CGFloat = 44
        let commitHeight: CGFloat = 80
        
        viewHeight = titleHeight + paramHeight + contentHeight + commitHeight
        let x: CGFloat = (self.view.frame.width - viewWidth) / 2 // 画面センタリング
        let y: CGFloat = mainViewY
        let viewWidthCenter = viewWidth / 2

        mainView = UIView(frame: CGRect(x: x, y: y, width: viewWidth, height: viewHeight))
        mainView.backgroundColor = UIColor.clear
        mainView.tag = 1001
        self.view.addSubview(mainView)

        titlebar = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: titleHeight))
        titlebar.backgroundColor = UIColor.clear
        titlebar.tag = 1001
        mainView.addSubview(titlebar)
        
        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.tag = 1001
        titlebar.addSubview(titleLabel)

        parambar = UIView(frame: CGRect(x: 0, y: titleHeight, width: viewWidth, height: paramHeight))
        parambar.backgroundColor = UIColor.clear
        parambar.tag = 1001
        mainView.addSubview(parambar)

        paramLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: paramHeight))
        paramLabel.textAlignment = .center
        paramLabel.textColor = UIColor.white
        paramLabel.tag = 1001
        parambar.addSubview(paramLabel)
        
        contentbar = UIView(frame: CGRect(x: 0, y: titleHeight + paramHeight, width: viewWidth, height: contentHeight))
        contentbar.backgroundColor = UIColor.clear
        contentbar.tag = 1001
        mainView.addSubview(contentbar)
        
        commitbar = UIView(frame: CGRect(x: 0, y: titleHeight + paramHeight + contentHeight, width: viewWidth, height: commitHeight))
        commitbar.backgroundColor = UIColor.clear
        commitbar.tag = 1001
        mainView.addSubview(commitbar)
        
        let commitButtonSize: CGFloat = 54
        let commitButtonY = (commitHeight - commitButtonSize) / 2

        commitButton = UIButton(frame: CGRect(x: viewWidthCenter - commitButtonSize / 2, y: commitButtonY, width: commitButtonSize, height: commitButtonSize))
        commitButton.setTitle("OK", for: .normal)
        commitButton.layer.cornerRadius = commitButtonSize / 2
        commitButton.clipsToBounds = true
        commitbar.addSubview(commitButton)
    }

    internal func mainViewAdjust() {
        let windowHeight = mainView.frame.width  - 20
        let mainViewHeight = mainView.frame.height
        var newY: CGFloat = 0
        let diff = windowHeight - mainViewHeight
        if diff > 0 {
            newY = diff / 2
        }
        else {
            newY = mainView.frame.origin.y
        }
        mainView.frame.origin = CGPoint(x: mainView.frame.origin.x, y: newY)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit {
        print("  deinit FNCParameterBaseViewController")
    }
    func titleAdjust() {
        
        titleLabel.sizeToFit()
        titleLabel.center = mainView.convert(titlebar.center, to: titlebar)

    }
}

