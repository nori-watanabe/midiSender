//
//  ViewController.swift
//  midiSender
//
//  Created by mbp on 2019/02/05.
//  Copyright © 2019 mbp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MidiDelegate {

    let midi = Midi()
    let sampler = Sampler()
    var logLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        midi.delegate = self
        setControllButton()
        scan()
    }
    @objc func actionSelectDestination(sender: UIButton) {
        midi.isPlaying = !midi.isPlaying
        if midi.isPlaying == true {
            midi.currentMidiDestinationEndpoint = midi.destinationEndpoints[sender.tag].id
            midi.sendBegan()
            sender.backgroundColor = UIColor.red
        }
        else {
            midi.sendEnd()
            sender.backgroundColor = UIColor.darkGray
        }
    }
    @objc func actionRescan(sender: UIButton) {
        scan()
    }
    func scan() {
        midi.sendEnd()
        midi.destinationEndpoints = []
        midi.scanDestinationEndpoint()
        midi.isPlaying = false

        setDestinationButtonItems()
        logLabel.text = ""
    }
    func setControllButton() {
        let rescanButton = UICornerButton(frame: CGRect(x: 10, y: 44, width: 60, height: 40))
        rescanButton.setTitle("rescan", for: .normal)
        rescanButton.tag = -1
        rescanButton.backgroundColor = UIColor.black
        rescanButton.setTitleColor(UIColor.white, for: .normal)
        rescanButton.addTarget(self, action: #selector(actionRescan), for: .touchUpInside)
        self.view.addSubview(rescanButton)
        
        logLabel = UILabel(frame: CGRect(x: 80, y: 44, width: self.view.frame.width - 90, height: 40))
        logLabel.textAlignment = .left
        logLabel.font = UIFont.systemFont(ofSize: 12)
        self.view.addSubview(logLabel)
    }
    func setDestinationButtonItems() {
        for view in self.view.subviews {
            if view.tag > 0 {
                view.removeFromSuperview()
            }
        }

        var i = 0
        for obj in midi.destinationEndpoints {

            let button = UICornerButton(frame: CGRect(x: 10, y: 100 + CGFloat(i * 44), width: self.view.frame.width - 20, height: 40))
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(obj.name + "(\(obj.id))", for: .normal)
            button.tag = i
            button.backgroundColor = UIColor.darkGray
            button.setTitleColor(UIColor.white, for: .normal)
            button.addTarget(self, action: #selector(actionSelectDestination), for: .touchUpInside)
            self.view.addSubview(button)
            
            i += 1
        }
    }
    func loggingMIDISend(channel: UInt8, note: UInt8, velocity: UInt8, destination: UInt32, timestamp: UInt64) {
        //display
        logLabel.text = "dest:\(destination), ch:\(channel), note:\(note), vel:\(velocity)"
        // sampler
        sampler.MIDISend(channel: channel, note: note, velocity: velocity, destination: destination, timestamp: timestamp)
    }
}

fileprivate class UICornerButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
