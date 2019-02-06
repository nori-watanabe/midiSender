//
//  Sampler
//  midiSender
//
//  Created by mbp on 2019/02/05.
//  Copyright © 2019 mbp. All rights reserved.
//

import AudioToolbox

class Sampler: NSObject {

    var auGraph: AUGraph? = nil
    var samplerUnit: AudioUnit? = nil

    override init() {
        super.init()
        self.prepareAUGraph()
    }
    deinit {
        AUGraphUninitialize(auGraph!)
        AUGraphClose(auGraph!)
        DisposeAUGraph(auGraph!)
    }
    func prepareAUGraph() {
        var err: OSStatus = 0

        var samplerNode = AUNode()
        var remoteOutputNode = AUNode()
        err = NewAUGraph(&auGraph)
        err = AUGraphOpen(auGraph!)
        
        var cd = AudioComponentDescription()
        cd.componentType = kAudioUnitType_Output
        cd.componentSubType = kAudioUnitSubType_RemoteIO
        cd.componentManufacturer = kAudioUnitManufacturer_Apple
        cd.componentFlags = 0
        cd.componentFlagsMask = 0
        
        err = AUGraphAddNode(auGraph!, &cd, &remoteOutputNode)
        if err != 0 {
            print(err)
        }

        cd.componentType = kAudioUnitType_MusicDevice
        cd.componentSubType = kAudioUnitSubType_Sampler

        err = AUGraphAddNode(auGraph!, &cd, &samplerNode)
        if err != 0 {
            print(err)
        }

        err = AUGraphConnectNodeInput(auGraph!, samplerNode, 0, remoteOutputNode, 0)
        if err != 0 {
            print(err)
        }
        
        err = AUGraphInitialize(auGraph!)
        if err != 0 {
            print(err)
        }
    
        err = AUGraphStart(auGraph!)
        if err != 0 {
            print(err)
        }

        err = AUGraphNodeInfo(auGraph!, samplerNode, nil, &samplerUnit)
        if err != 0 {
            print(err)
        }
    }
    func MIDISend(channel: UInt8, note: UInt8, velocity: UInt8, destination: UInt32, timestamp: UInt64) {
        print("dest:\(destination), time:\(timestamp), ch:\(channel), note:\(note), vel:\(velocity)")
    }
}
