//
//  Midi.swift
//  midiSender
//
//  Created by mbp on 2019/02/05.
//  Copyright © 2019 mbp. All rights reserved.
//

import Foundation
import CoreMIDI

@objc protocol MidiDelegate {
    func loggingMIDISend(channel: UInt8, note: UInt8, velocity: UInt8, destination: UInt32, timestamp: UInt64)
}

class Midi: NSObject {

    var midiClient = MIDIClientRef()
    var midiOutputPort = MIDIPortRef()
    var currentMidiDestinationEndpoint = MIDIEndpointRef()
    var destinationEndpoints: [DestinationEndpoint] = []
    var isPlaying: Bool = false
    var maxNote: UInt8 = 100
    var minNote: UInt8 = 60
    var currentNote: UInt8 = 60
    var timer: Timer = Timer.init()
    var delegate: MidiDelegate!
    
    class DestinationEndpoint {
        var id: UInt32 = 0
        var name: String = ""
    }
    fileprivate class MidiSeqData {
        var key: UInt8 = 0
        var vel: UInt8 = 0
    }

    override init() {
        var err: OSStatus = 0

        err = MIDIClientCreate(
            "MIDIClientCreate" as CFString,
            nil,
            nil,
            &midiClient
        )
        if (err != 0) {
            print("[err]MIDIClientCreate \(err)")
            return
        }

        err = MIDIOutputPortCreate(
            midiClient,
            "MIDIOutputPortCreate" as CFString,
            &midiOutputPort
        )
        if err != 0 {
            print("[err]MIDIOutputPortCreate \(err)")
            return
        }
    }
    deinit {
        dispose()
    }
    func scanDestinationEndpoint() {
        
        // network
        
        let networkid = MIDINetworkSession.default().destinationEndpoint()
        let networkname = midiPropertyDisplayName(networkid)! as String
        let newworkEndpoint = DestinationEndpoint()
        newworkEndpoint.id = networkid
        newworkEndpoint.name = networkname
        destinationEndpoints.append(newworkEndpoint)
        
        // device or app
        
        let endpointCount: Int = MIDIGetNumberOfDestinations()
        for ld in 0..<endpointCount {
            let endpointRef = MIDIGetDestination(ld)
            if endpointRef != networkid {
                let name = midiPropertyDisplayName(endpointRef)! as String
                let deviceEndpoint = DestinationEndpoint()
                deviceEndpoint.id = endpointRef
                deviceEndpoint.name = name
                destinationEndpoints.append(deviceEndpoint)
            }
        }
        
        // network, bluetooth ....

    }
    func dispose() {
        var err: OSStatus = 0
        
        err = MIDIPortDispose(midiOutputPort)
        if err != 0 {
            print("[err]MIDIPortDispose \(err)")
        }
        
        err = MIDIClientDispose(midiClient)
        if err != 0 {
            print("[err]MIDIClientDispose \(err)")
        }
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
        let prevKey = (currentNote == minNote) ? minNote : currentNote - 1
        noteOff.key = prevKey
        noteOff.vel = 0

        let noteOn = MidiSeqData()
        noteOn.key = currentNote
        noteOn.vel = 100

        let channel: UInt8 = 0
        
        midiSend(noteData: [noteOff, noteOn], channel: channel)
    }
    fileprivate func midiSend(noteData: [MidiSeqData], channel: UInt8) {
        var err: OSStatus = 0

        // packetList initialize
        let bufferSize: Int = 1024 // byte size
        let packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: bufferSize)

        for note in noteData {

            let timestamp: MIDITimeStamp = mach_absolute_time()

            // packet initialize
            var packet = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
            packet = MIDIPacketListInit(packetList)
            
            // channel, note, velocity
            let packetData: [UInt8] = [0x90 + channel, note.key, note.vel]
            
            // packet add to packetList
            packet = MIDIPacketListAdd(
                packetList,
                bufferSize,
                packet,
                timestamp,
                packetData.count,
                packetData
            )

            self.delegate.loggingMIDISend(channel: channel, note: note.key, velocity: note.vel, destination: currentMidiDestinationEndpoint, timestamp: timestamp)
        }

        // packetList send

        err = MIDISend(
            midiOutputPort,
            currentMidiDestinationEndpoint,
            packetList
        )
        if err != 0 {
            print("[err]MIDISend \(err)")
        }
    }
    fileprivate func midiPropertyDisplayName(_ object: MIDIObjectRef) -> NSString? {
        var name: Unmanaged<CFString>? = nil
        if (0 != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name) ){
            return nil
        }
        return name?.takeUnretainedValue() as NSString?
    }
}
