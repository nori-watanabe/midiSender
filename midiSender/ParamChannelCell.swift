//
//  ParamChannelCell.swift
//  Sampler
//
//  Created by mbp on 2019/03/12.
//  Copyright © 2019年 mbp. All rights reserved.
//

import UIKit

class ParamChannelCell: UICollectionViewCell {
    
    var channelLabel = UILabel()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        channelLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        channelLabel.backgroundColor = UIColor.clear
        channelLabel.layer.cornerRadius = 3.0
        channelLabel.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        channelLabel.clipsToBounds = true
        channelLabel.textColor = UIColor.white
        channelLabel.textAlignment = NSTextAlignment.center
        channelLabel.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.thin)
        self.addSubview(channelLabel)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    deinit {
        //print(" deinit ParamChannelCell")
    }
}
