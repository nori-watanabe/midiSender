//
//  Midi.swift
//  midiSender
//
//  Created by mbp on 2019/04/13.
//  Copyright © 2019 mbp. All rights reserved.
//

import Foundation
import CoreMIDI

@objc protocol MidiDelegate {
    func loggingMIDISend(log: String)
}

class Midi: NSObject {

    let sampler = Sampler()
    var midiClient = MIDIClientRef()
    var midiOutputPort = MIDIPortRef()
    var currentMidiDestinationEndpoint = MIDIEndpointRef()
    var currentChannel: UInt8 = 0
    var destinationEndpoints: [DestinationEndpoint] = []
    var sourceEndpoint = MIDIEndpointRef()
    var isPlaying: Bool = false
    let maxNote: UInt8 = 100
    let minNote: UInt8 = 60
    var currentNote: UInt8 = 60
    var timer: Timer = Timer.init()
    var delegate: MidiDelegate!
    
    class DestinationEndpoint {
        var id: UInt32 = 0
        var name: String = ""
        var channel: UInt8 = 0
    }
    fileprivate class MidiSeqData {
        var key: UInt8 = 0
        var vel: UInt8 = 0
    }

    override init() {
        var err: OSStatus = 0

        let notifyMidiClient: MIDINotifyProc = {
            (notification: UnsafePointer<MIDINotification>, refcon: UnsafeMutableRawPointer?) in

            NotificationCenter.default.post(
                name: Notification.Name(rawValue: "updateDestinationDeviceStatus"),
                object: nil
            )

            print("midiSender notifyMidiClient \(notification) refcon \(String(describing: refcon))")
        }

        err = MIDIClientCreate(
            "MIDISenderClient" as CFString,
            notifyMidiClient,
            nil,
            &midiClient
        )
        if (err != 0) {
            print("midiSender MIDIClientCreate \(err)")
            return
        }

        err = MIDIOutputPortCreate(
            midiClient,
            "MIDISenderOutputPort" as CFString,
            &midiOutputPort
        )
        if err != 0 {
            print("midiSender MIDIOutputPortCreate \(err)")
            return
        }
        
        err = MIDISourceCreate(midiClient, "MIDISenderSourceEndpoint" as CFString, &sourceEndpoint)
        if err != 0 {
            print("midiSender MIDISourceCreate \(err)")
            return
        }

    }
    deinit {
        dispose()
    }
    func scanDestinationEndpoint() {
        
        // network session .. sorry this app can not connect
        let networkid = MIDINetworkSession.default().destinationEndpoint()

        // device or app
        
        let endpointCount: Int = MIDIGetNumberOfDestinations()
        for ld in 0..<endpointCount {
            let endpointRef = MIDIGetDestination(ld)
            if endpointRef != networkid {
                let name = midiPropertyDisplayName(endpoint: endpointRef)
                let deviceEndpoint = DestinationEndpoint()
                deviceEndpoint.id = endpointRef
                deviceEndpoint.name = name
                deviceEndpoint.channel = 0
                destinationEndpoints.append(deviceEndpoint)
            }
        }
        
        // network, bluetooth ....

    }
    func dispose() {
        var err: OSStatus = 0
        
        err = MIDIPortDispose(midiOutputPort)
        if err != 0 {
            print("midiSender MIDIPortDispose \(err)")
        }
        
        err = MIDIClientDispose(midiClient)
        if err != 0 {
            print("midiSender MIDIClientDispose \(err)")
        }
    }
    func isSendingContinues() -> Bool {
        for destination in destinationEndpoints {
            if currentMidiDestinationEndpoint == destination.id {
                return true
            }
        }
        return false
    }
    func sendBegan() {
        let duration: Double = 60 / 85 * 0.25

        self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
        self.timerFired()
    }
    func sendEnd() {
        self.timer.invalidate()
    }
    @objc func timerFired() {
        
        // generate sample note

        currentNote += 1
        if currentNote > maxNote {
            currentNote = minNote
        }

        let noteOff = MidiSeqData()
        let prevKey = (currentNote == minNote) ? maxNote : currentNote - 1
        noteOff.key = prevKey
        noteOff.vel = 0

        let noteOn = MidiSeqData()
        noteOn.key = currentNote
        noteOn.vel = 100
        
        midiSend(noteData: [noteOff, noteOn])
    }
    fileprivate func midiSend(noteData: [MidiSeqData]) {
        var err: OSStatus = 0

        // packetList initialize
        let bufferSize: Int = 1024 // byte size
        let packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: bufferSize)

        // packet initialize
        var packet = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
        packet = MIDIPacketListInit(packetList)
        
        for note in noteData {

            let timestamp: MIDITimeStamp = mach_absolute_time()
            
            // channel, note, velocity
            let packetData: [UInt8] = [0x90 + currentChannel, note.key, note.vel]
            
            // packet add to packetList
            packet = MIDIPacketListAdd(
                packetList,
                bufferSize,
                packet,
                timestamp,
                packetData.count,
                packetData
            )

            // sampler
            sampler.MIDISend(channel: currentChannel, note: note.key, velocity: note.vel, destination: currentMidiDestinationEndpoint, timestamp: timestamp)
            
            // display log
            let log = "dest: \(currentMidiDestinationEndpoint), time \(timestamp), ch: \(currentChannel+1), note: \(note.key), vel: \(note.vel)"
            self.delegate.loggingMIDISend(log: log)
        }

        // packetList send
        err = MIDISend(
            midiOutputPort,
            currentMidiDestinationEndpoint,
            packetList
        )
        if err != 0 {
            print("midiSender MIDISend \(err)")
        }

        packetList.deallocate()
    }
    fileprivate func midiPropertyDisplayName(endpoint: MIDIObjectRef) -> String {
        var param: Unmanaged<CFString>? = nil
        var name: String = "--"
        
        let err: OSStatus = MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDisplayName, &param)
        if err == 0 {
            name =  param!.takeRetainedValue() as String
        }
        return name
    }
}
