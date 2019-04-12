//
//  ParamChannelCollectionViewController.swift
//  midiSender
//
//  Created by mbp on 2019/04/13.
//  Copyright (c) 2019年 mbp. All rights reserved.
//

import UIKit

class ParamInfo {
    var tag: Int       = -1
    var index: Int     = -1
    var title: String  = ""
    var channel: Int   = 0
}

class ParamChannelCollectionViewController: FNCParameterBaseViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var channelCollectionView: UICollectionView!
    var channelInfo: ParamInfo!
    let channels: [Int] = Array(1...16)
    var selValue: Int = 1 // 1-16
    let collectionWidth: CGFloat = (44 + 8) * 4
    let contentMargin: CGFloat = 50
 
    override func loadView() {
        super.loadView()

        contentHeight = collectionWidth + contentMargin
        mainViewY = 220
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        
        paramLabel = UILabel(frame: CGRect(origin: CGPoint.zero, size: parambar.frame.size))
        paramLabel.textAlignment = .center
        paramLabel.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        paramLabel.textColor = UIColor.white
        paramLabel.tag = 1001
        parambar.addSubview(paramLabel)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 6.0
        flowLayout.itemSize = CGSize(width: 44, height: 44)
        flowLayout.headerReferenceSize = CGSize(width: 0, height: 0)
        flowLayout.footerReferenceSize = CGSize(width: 0, height: 0)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        
        let x: CGFloat = (contentbar.frame.width - collectionWidth) / 2
        let y: CGFloat = contentMargin / 2
        channelCollectionView = UICollectionView(
            frame: CGRect(x: x, y: y, width: collectionWidth, height: collectionWidth),
            collectionViewLayout: flowLayout
        )
        channelCollectionView.register(ParamChannelCell.self, forCellWithReuseIdentifier: "cell")
        channelCollectionView.showsHorizontalScrollIndicator = false
        channelCollectionView.dataSource = self
        channelCollectionView.delegate = self
        channelCollectionView.layer.cornerRadius = 5.0
        channelCollectionView.clipsToBounds = true
        channelCollectionView.backgroundColor = UIColor.clear
        channelCollectionView.isPagingEnabled = false
        channelCollectionView.isScrollEnabled = false
        contentbar.addSubview(channelCollectionView)
        
        commitButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        commitButton.addTarget(self, action: #selector(actionCommit), for: .touchUpInside)
        
        mainViewAdjust()
    }
    deinit {
        print(" deinit ParamChannelCollectionViewController")
    }
    func actionCancel(sender: UIButton) {
        doCancel()
    }
    func doCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case 1001 :
                doCancel()
            default:
                break
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.backgroundColor = UIColor.black
        paramLabel.text = selValue.description + " ch"
        
        titleLabel.text = "MIDI Channel"
        titleAdjust()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let indexPath = IndexPath(row: selValue - 1, section: 0)
        selectCell(indexPath)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    @objc func actionCommit(sender: UIButton) {
        channelInfo.channel = selValue
        NotificationCenter.default.post(name: Notification.Name(rawValue: "channelValueCommited"), object: channelInfo)
        self.dismiss(animated: true, completion: nil)
    }
    func selectCell(_ indexPath: IndexPath){
        let viewCells = channelCollectionView.visibleCells
        for cell in viewCells {
            let channelCell = cell as! ParamChannelCell
            channelCell.channelLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            channelCell.channelLabel.textColor = UIColor.white
        }
        let cell = channelCollectionView.cellForItem(at: indexPath) as! ParamChannelCell
        cell.channelLabel.backgroundColor = UIColor.white
        cell.channelLabel.textColor = UIColor.black
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        paramLabel.text = channels[indexPath.row].description + " ch"
        selValue = channels[indexPath.row]
        selectCell(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ParamChannelCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ParamChannelCell
        cell.channelLabel.text = channels[(indexPath as NSIndexPath).row].description
        return cell
    }
}
