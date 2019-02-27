//
//  ViewController.swift
//  midiSender
//
//  Created by mbp on 2019/02/27.
//  Copyright © 2019 mbp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MidiDelegate {
    
    let midi = Midi()
    var logTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        midi.delegate = self
        setNotificationObserver()
        setControllButton()
        scan()
    }
    func setNotificationObserver() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(actionUpdateDestinationDeviceStatus), name: NSNotification.Name(rawValue: "updateDestinationDeviceStatus"), object: nil)
    }
    @objc func actionSelectDestination(sender: UIButton) {
        if midi.isPlaying == true && sender.backgroundColor == UIColor.darkGray {
            return
        }

        midi.isPlaying = !midi.isPlaying
        if midi.isPlaying == true {
            midi.currentMidiDestinationEndpoint = midi.destinationEndpoints[sender.tag].id
            midi.sendBegan()
            sender.backgroundColor = UIColor.red
        }
        else {
            midi.sendEnd()
            sender.backgroundColor = UIColor.darkGray
            midi.currentMidiDestinationEndpoint = 0
        }
    }
    @objc func actionRescan(sender: UIButton) {
        logTextView.text = ""
        scan()
    }
    @objc func actionUpdateDestinationDeviceStatus() {
        scan()
    }
    func scan() {
        midi.destinationEndpoints = []
        midi.scanDestinationEndpoint()

        var tag: UInt32 = 0
        if midi.isSeningContinues() == false {
            midi.sendEnd()
            midi.isPlaying = false
        }
        else {
            tag = midi.currentMidiDestinationEndpoint
        }
        setDestinationButtonItems(activeEndpoint: tag)
    }
    func setControllButton() {
        let rescanButton = UICornerButton(frame: CGRect(x: 10, y: 44, width: 60, height: 40))
        rescanButton.tag = -1
        rescanButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rescanButton.backgroundColor = UIColor.black
        rescanButton.setTitleColor(UIColor.white, for: .normal)
        rescanButton.setTitle("reset", for: .normal)
        rescanButton.addTarget(self, action: #selector(actionRescan), for: .touchUpInside)
        self.view.addSubview(rescanButton)
        
        let deviceInfoLabel = UILabel(frame: CGRect(x: 75, y: 44, width: self.view.frame.width - 75, height: 40))
        deviceInfoLabel.tag = -2
        deviceInfoLabel.numberOfLines = 2
        deviceInfoLabel.textAlignment = .left
        deviceInfoLabel.font = UIFont.systemFont(ofSize: 12)
        deviceInfoLabel.text = "midiSender midiClient: \(midi.midiClient.description)\noutputPort: \(midi.midiOutputPort), sourceEndpoint: \(midi.sourceEndpoint.description)"
        self.view.addSubview(deviceInfoLabel)
        
        logTextView = UITextView(frame: CGRect(x: 10, y: 90, width: self.view.frame.width - 20, height: 150))
        logTextView.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .regular)
        logTextView.isEditable = false
        logTextView.layer.cornerRadius = 5
        logTextView.layer.masksToBounds = true
        logTextView.textColor = UIColor.white
        logTextView.tag = -3
        logTextView.backgroundColor = UIColor.black
        self.view.addSubview(logTextView)
    }
    func setDestinationButtonItems(activeEndpoint: UInt32) {
        for view in self.view.subviews {
            if view.tag >= 0 {
                view.removeFromSuperview()
            }
        }

        var i = 0
        for obj in midi.destinationEndpoints {

            let button = UICornerButton(frame: CGRect(x: 10, y: 260 + CGFloat(i * 44), width: self.view.frame.width - 20, height: 40))
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(obj.name + "(\(obj.id))", for: .normal)
            button.tag = i
            button.backgroundColor = UIColor.darkGray
            button.setTitleColor(UIColor.white, for: .normal)
            button.addTarget(self, action: #selector(actionSelectDestination), for: .touchUpInside)
            
            if obj.id == activeEndpoint {
                button.backgroundColor = UIColor.red
            }
            
            self.view.addSubview(button)
            
            i += 1
        }
    }
    func loggingMIDISend(log: String) {
        let oldlines = logTextView.text.components(separatedBy: CharacterSet(charactersIn: "\n"))
        var logs: [String] = []
        logs.append(log)
        for line in oldlines {
            logs.append(line)
            if logs.count > 20 {
                break
            }
        }
        logTextView.text = logs.joined(separator: "\n")
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
