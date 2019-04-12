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
        NotificationCenter.default.addObserver(self, selector: #selector(notifChannelValueChanged), name: NSNotification.Name(rawValue: "channelValueCommited"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifSamplerStart), name: NSNotification.Name(rawValue: "samplerStart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notifSamplerStop), name: NSNotification.Name(rawValue: "samplerStop"), object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updateDestinationDeviceStatus"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "channelValueCommited"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "samplerStart"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "samplerStop"), object: nil)
        
        midi.dispose()
    }
    
    // button action
    
    @objc func actionRescan(sender: UICornerButton) {
        logTextView.text = ""
        scan()
    }
    @objc func actionSelectDestination(sender: UICornerButton) {
        if midi.isPlaying == true && sender.backgroundColor == UIColor.darkGray {
            return
        }

        midi.isPlaying = !midi.isPlaying
        if midi.isPlaying == true {
            midi.currentMidiDestinationEndpoint = midi.destinationEndpoints[sender.tag].id
            midi.currentChannel = midi.destinationEndpoints[sender.tag].channel
            midi.sendBegan()
            sender.backgroundColor = UIColor.red
        }
        else {
            midi.sendEnd()
            sender.backgroundColor = UIColor.darkGray
            midi.currentMidiDestinationEndpoint = 0
        }
    }
    @objc func actionChannelChange(sender: UICornerButton) {
        
        let channelCollectionViewController = ParamChannelCollectionViewController()
        channelCollectionViewController.modalPresentationStyle = .overFullScreen
        
        // param
        let channelInfo = ParamInfo()
        channelInfo.tag = sender.tag
        channelInfo.channel = sender.channel + 1
        channelCollectionViewController.channelInfo = channelInfo
        channelCollectionViewController.selValue = channelInfo.channel
        
        self.present(channelCollectionViewController, animated: true, completion: nil)
        channelCollectionViewController.paramLabel.text = "\(channelInfo.channel) ch"
    }

    // Notification action
    
    @objc func actionUpdateDestinationDeviceStatus(sender: Notification) {
        scan()
    }
    @objc func notifChannelValueChanged(sender: Notification) {
        
        let channelInfo = sender.object as! ParamInfo
        //元のchannelボタンはtagでindexを送っているのでidを特定する
        let id = midi.destinationEndpoints[channelInfo.tag].id
        
        for view in self.view.subviews {
            if let sendButton = view as? UICornerButton {
                // sendButtonはidを持ってるので特定する
                if sendButton.id == id {
                    for button in sendButton.subviews {
                        if let channelButton = button as? UICornerButton {
                            
                            channelButton.channel = channelInfo.channel - 1
                            
                            channelButton.setTitle("Ch:\(channelInfo.channel)", for: .normal)
                            
                            midi.destinationEndpoints[channelInfo.tag].channel = UInt8(channelButton.channel)
                            
                            if id == midi.currentMidiDestinationEndpoint {
                                midi.currentChannel = UInt8(channelButton.channel)
                            }
                            
                            break
                        }
                    }
                    
                    break
                }
            }
        }
        
    }
    @objc func notifSamplerStart(sender: Notification) {
        midi.sampler.setSamplerCondition(isStart: true)
    }
    @objc func notifSamplerStop(sender: Notification) {
        midi.sampler.setSamplerCondition(isStart: false)
    }

    func scan() {
        midi.destinationEndpoints = []
        midi.scanDestinationEndpoint()

        var endpoint: UInt32 = 0
        if midi.isSendingContinues() == false {
            midi.sendEnd()
            midi.isPlaying = false
        }
        else {
            endpoint = midi.currentMidiDestinationEndpoint
        }
        setDestinationButtonItems(activeEndpoint: endpoint)
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

            let sendButton = UICornerButton(frame: CGRect(x: 10, y: 260 + CGFloat(i * 44), width: self.view.frame.width - 20, height: 40))
            sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            sendButton.titleLabel?.textAlignment = .left
            sendButton.setTitle("  \(obj.name) (\(obj.id))", for: .normal)
            sendButton.tag = i // index
            sendButton.id = obj.id // endpoint
            sendButton.backgroundColor = UIColor.darkGray
            sendButton.setTitleColor(UIColor.white, for: .normal)
            sendButton.contentHorizontalAlignment = .left
            sendButton.addTarget(self, action: #selector(actionSelectDestination), for: .touchUpInside)
            
            if obj.id == activeEndpoint {
                sendButton.backgroundColor = UIColor.red
            }
            self.view.addSubview(sendButton)

            let channelButton = UICornerButton(frame: CGRect(x: sendButton.frame.width - 50 - 5, y: 5, width: 50, height: sendButton.frame.height - 10))
            channelButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            if obj.id == activeEndpoint {
                obj.channel = midi.currentChannel
            }
            channelButton.setTitle("Ch:\(obj.channel+1)", for: .normal)
            channelButton.tag = i // index
            channelButton.channel = Int(obj.channel)
            channelButton.backgroundColor = UIColor.white
            channelButton.setTitleColor(UIColor.black, for: .normal)
            channelButton.addTarget(self, action: #selector(actionChannelChange), for: .touchUpInside)
            sendButton.addSubview(channelButton)
            
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

class UICornerButton: UIButton {
    var id: UInt32 = 0
    var channel: Int = 0
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
