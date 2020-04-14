//
//  WebRTCClient.swift
//  test-storitios
//
//  Created by Amad Khan on 12/01/2020.
//  Copyright © 2020 Humaid Khan. All rights reserved.
//

import Foundation
import WebRTC
import SocketIO

public enum RTCClientState {
    case disconnected
    case connecting
    case connected
}

public protocol RTCClientDelegate: class {
    func rtcClient(client: WebRTCClient, startCallWithSdp sdp: String)
    func rtcClient(client: WebRTCClient, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack)
    func rtcClient(client: WebRTCClient, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack)
    func rtcClient(client: WebRTCClient,didReceiveError error: Error)
    func rtcClient(client: WebRTCClient, didChangeConnectionState connectionState: RTCIceConnectionState)
    func rtcClient(client: WebRTCClient, didChangeState state: RTCClientState)
    func rtcClient(client: WebRTCClient, didGenerateIceCandidate iceCandidate: RTCIceCandidate)
    func rtcClient(client: WebRTCClient, didCreateLocalCapturer capturer: RTCCameraVideoCapturer)
    
}

public extension RTCClientDelegate {
    func rtcClient(client: WebRTCClient, didReceiveError error: Error) {
        
    }
    func rtcClient(client: WebRTCClient, didChangeConnectionState connectionState: RTCIceConnectionState) {
        
    }
    func rtcClient(client: WebRTCClient, didChangeState state: RTCClientState) {
        
    }
}

public class WebRTCClient:NSObject {
    var connectionFactory:RTCPeerConnectionFactory = RTCPeerConnectionFactory()
    var peerConnection:RTCPeerConnection?
    let iceServers:[RTCIceServer] = [RTCIceServer(urlStrings: [ "stun:stun.l.google.com:19302"], username: "", credential: ""),RTCIceServer(urlStrings: [ "stun:23.21.150.121"], username: "", credential: ""),RTCIceServer(urlStrings: [ "stun:stun1.l.google.com:19302"], username: "", credential: ""),RTCIceServer(urlStrings: ["stun:stun2.l.google.com:19302"], username: "", credential: ""),RTCIceServer(urlStrings: ["stun:stun3.l.google.com:19302"], username: "", credential: "")]
    let manager = SocketManager(socketURL: URL(string: "https://www.vrpacman.com")!, config: [.log(false), .compress])
    var socket:SocketIOClient?
    var fromId:String?
    var delegate:RTCClientDelegate?
    var remoteId:String = ""
    var remoteIceCandidates: [RTCIceCandidate] = []
    var defaultConstraint = RTCMediaConstraints(mandatoryConstraints: ["OfferToReceiveAudio": "false", "OfferToReceiveVideo": "false"], optionalConstraints: ["DtlsSrtpKeyAgreement": "true"])
    var defaultDataConfiguration = RTCDataChannelConfiguration()
    var localDataChannel: RTCDataChannel?
    var remoteDataChannel: RTCDataChannel?
    var peerConnectionList: [String:RTCPeerConnection] = [:]
    var dataChannelList: [String:RTCDataChannel] = [:]
    var connections: [String:MyConnection] = [:]
    var img:UIImageView?
    var receivingFile:Bool = false
    var orderIndex = 0
    var requestType = ""
    var type = ""
    var data:Data? = Data()
    var configurationList:[String:RTCConfiguration] = [:]
    var fileUrl:URL?
    var chunks:[String:Data] = [:]
    var viewController:ClientViewController? = nil
    var fileId:Int? = -1
    var fileSize:Int? = -1
    var didDownloadList:[String:Bool] = [:]
    private var state: RTCClientState = .connecting {
        didSet {
            self.delegate?.rtcClient(client: self, didChangeState: state)
        }
    }
    init(viewController:ClientViewController) {
        super.init()
        self.type = "Client"
        self.viewController = viewController
        print("func called")
//        self.configuration = RTCConfiguration()
//        self.configuration.iceServers = self.iceServers
        RTCPeerConnectionFactory.initialize()
        self.connectionFactory = RTCPeerConnectionFactory()
        socket = manager.defaultSocket
        //configuration.iceServers = self.iceServers
        
        socket?.on("id", callback: self.onId)
        socket?.on("message", callback: self.onMessage)
        socket?.on("uploadList", callback: self.onUploadList)
        socket?.on("downloadList", callback: self.onDownloadList)
        socket?.connect()
//        socket?.on(clientEvent: .connect) {_,_ in
//            self.emitUpload(token: token, data: data)
//        }
        
    }
    init(img:UIImageView, token:String, storageSize:Int, devId:String) {
        super.init()
        self.type = "Server"
//        self.configuration = RTCConfiguration()
//        self.configuration.iceServers = self.iceServers
        RTCPeerConnectionFactory.initialize()
        self.connectionFactory = RTCPeerConnectionFactory()
        socket = manager.defaultSocket
        //configuration.iceServers = self.iceServers
        
        socket?.on("id", callback: self.onId)
        socket?.on("message", callback: self.onMessage)
        socket?.connect()
        socket?.on(clientEvent: .connect) {_,_ in
            self.emitServer(token: token, storageSize: storageSize, deviceId: devId)
        }
        self.img = img
        
    }
    
    
    func intializePeerConnection() {
        
        let configuration = RTCConfiguration()
        configuration.iceServers = self.iceServers
        self.peerConnection = self.connectionFactory.peerConnection(with: configuration, constraints: self.defaultConstraint, delegate: self)
        self.localDataChannel = self.peerConnection?.dataChannel(forLabel: "sendDataChannel", configuration: defaultDataConfiguration)
        self.localDataChannel?.delegate = self as RTCDataChannelDelegate
    }
    func doneSending(from:String, index:Int) {
//        for channel in dataChannelList {
//            channel.value.close()
//        }
//        peerConnectionList[from]?.close()
        print("done sending is called")
//        dataChannelList.removeValue(forKey: from)
//        peerConnectionList.removeValue(forKey: from)
        print("size of connections is ", connections.count)
        for (key, connection) in connections {
            if(!connection.doneUploading) {
                return
            }
        }
        for(key, connection) in peerConnectionList {
            connection.close()
        }
        dataChannelList.removeAll()
        peerConnectionList.removeAll()
        connections.removeAll()
        
//        connections.removeValue(forKey: from)
//        peerConnectionList.removeValue(forKey: from)
//        dataChannelList.removeValue(forKey: from)
        print("size of peerconnectionList is ", peerConnectionList.count)
//        dataChannelList.remove(at: dataChannelList.index(forKey: from)!)
//        peerConnectionList.remove(at: peerConnectionList.index(forKey: from)!)
    }
    func removePeer(from:String) {
//        var connection = connections[from]
//        connection = nil
        DispatchQueue.main.async {

//            peerConnectionList[from]?.close()
            self.dataChannelList.removeValue(forKey: from)
            self.peerConnectionList.removeValue(forKey: from)
            self.connections.removeValue(forKey: from)
            self.chunks.removeValue(forKey: from)
        }
    }
    func doneDownloading(from:String, imageFileBytes:Data) {
        didDownloadList[from] = true
        chunks[from] = imageFileBytes
        var i = 0
        for (key, didDownload) in didDownloadList {
            print("value at ",i, " is ", didDownload)
            if(!didDownload) {
                break
            } else if(i == didDownloadList.count - 1) {
                print("done receiving")
                mergePhoto()
                print(chunks.count)
                chunks.removeAll()
                didDownloadList.removeAll()
            }
            i+=1
        }

        removePeer(from:from)
    }
    func mergePhoto() {
        var mergedSize = 0
        for (key, chunk) in chunks {
            mergedSize += chunk.count
        }
        var mergedData = Data(capacity: mergedSize)
        for (key, chunk) in chunks {
            mergedData.append(chunk)
        }
        let saveFileStatus = saveImage(data: mergedData)
        print("file saving status = ", saveFileStatus)
    }
    func saveImage(data:Data) -> Bool {
        guard let directory = try?  FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("Image-" + String(fileId!) + ".png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func getSavedImage(name:String) -> Data{
        var fileData = Data()
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let fileURL = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name)
            do {
                let fileStream = InputStream(url:fileURL)
                fileStream!.open()
                let bufferSize = 1024
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                while fileStream!.hasBytesAvailable {
                    let read = fileStream?.read(buffer, maxLength: bufferSize)
                    if read! < 0 {
                        throw (fileStream?.streamError!)!
                    } else if read == 0 {
                        break
                    }
                    fileData.append(buffer,count:read!)
                }
                buffer.deallocate()
                fileStream?.close()
                    
                }catch{
                    print("Error: \(error)")
                }
        }
        return fileData
    }
    func addPeerConnection(from:String, requestType:String, chunk:Data) {
        self.didDownloadList[from] = false
        var fileName = self.fileUrl?.lastPathComponent
        var fileType = self.fileUrl?.pathExtension
//        let configuration = RTCConfiguration()
        configurationList[from] = RTCConfiguration()
        configurationList[from]?.iceServers = iceServers
        print("request type = ", requestType, " while type is ", type)
        let peer = MyConnection(orderIndex: (self.peerConnectionList.count ?? 0) - 1, requestType: requestType, id:from, socket:socket!, data:chunk, type:type, isFinalChunk:self.peerConnectionList.count == self.chunks.count - 1, controller:viewController, fileId: fileId, fileSize: fileSize, fileName:fileName, fileType: fileType, didDownloadList: didDownloadList, downloadChunks: chunks, doneSending: self.doneSending, removePeer: self.removePeer, doneDownloading: doneDownloading, saveImage: saveImage, getSavedImage: getSavedImage)
        self.peerConnectionList[from] = self.connectionFactory.peerConnection(with: self.configurationList[from]!, constraints: self.defaultConstraint, delegate: peer as RTCPeerConnectionDelegate)
        self.dataChannelList[from] = self.peerConnectionList[from]!.dataChannel(forLabel: "sendDataChannel", configuration: defaultDataConfiguration)
        self.dataChannelList[from]?.delegate =  peer as RTCDataChannelDelegate
        self.connections[from] = peer
    }
    
    
//    func divideData() {
////        print(self.fileUrl?.absoluteString)
//        let image = UIImage(data: self.data!);
//        let tmpImgRef = image?.cgImage
//        let topRect = CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height / 2.0)
//        let topImgRef = tmpImgRef!.cropping(to: topRect)
//        var topImage = UIImage(cgImage: topImgRef!)
//        chunks.append(topImage.pngData()!)
//        let bottomRect = CGRect(x: 0, y: image!.size.height / 2.0,  width: image!.size.width, height: image!.size.height / 2.0)
//        let bottomImgRef = tmpImgRef!.cropping(to: bottomRect)
//        var bottomImage = UIImage(cgImage: bottomImgRef!)
//        chunks.append(bottomImage.pngData()!)
//    }
//
    
    
    func onUploadList(args: Array<Any>, emitter:SocketAckEmitter) {
        
        let socketList = args[0] as! Array<[String:Any]>
        self.fileId = args[1] as! Int
        print("the file id is ",fileId)
        // so do two things
        // one is take the socket list and send an init to the requested server
        // we're going to send the requested chunk to that server
        // then the other thing is that u need to send the file id to firebase to update the file string
        // now look, u got a list of sockets for each chunk, maybe even the chunk sizes
        // right so divide te file that's in data an
        
        // shud later pass the number of chuks or like the whole socket list
        // or like a list of how much each chunk should have
//        divideData()
//        chunks.append(data!)
//        chunks.append(data!)
        for i in stride(from: 0, to: socketList.count, by: 1) {
            let socketId = socketList[i]["socketId"] as! String
            chunks[socketId] = data
        }
        for i in stride(from: 0, to: socketList.count, by: 1) {
            let socketId = socketList[i]["socketId"] as! String
            if(self.chunks.count != 0) {
                addPeerConnection(from: socketId, requestType: "serverUpload", chunk:self.chunks[socketId]!)
                sendMessage(to: socketId, type: "init", payload: [:])
                print("chunks is not empty")
            } else {
                print("chunks are empty")
            }
            print("socket id for ", i, " is ",socketId)
        }
        
    }
    func onDownloadList(args: Array<Any>, emitter:SocketAckEmitter) {
        print("download list")
        print("there are currently ", peerConnectionList.count, " peers connected")
            let socketList = args[0] as! Array<[String:Any]>
            for i in stride(from: 0, to: socketList.count, by: 1) {
                let socketId = socketList[i]["socketId"] as! String
                addPeerConnection(from: socketId, requestType: "serverDownload", chunk:Data())
                sendMessage(to: socketId, type: "init", payload: [:])
                print("socket id for ", i, " is ",socketId)
            }
            
        }
    func onId(args: Array<Any>, emitter:SocketAckEmitter) {
        let id = args[0]
        ///sendMessage
        print("id",id)
        sendMessage(to: id as! String, type: "init", payload: [:])
        
        
    }
    func onMessage(args: Array<Any>, emitter:SocketAckEmitter) {
        guard let jsonData = args[0] as? [String: Any] else {
            print("error decoding json")
            return
        }
        var from = jsonData["from"] as! String
        var type = jsonData["type"] as! String
        self.requestType = jsonData["requestType"] as! String
        self.orderIndex = jsonData["order"] as! Int
        var payload:[String:Any] = [:]
        
        if(type != "init") {
            payload = jsonData["payload"] as! [String:Any]
        }
        print("the type of message received is " + type + " from " + from)
        print(type)
//        if(self.remoteId == "") {
//            self.intializePeerConnection()
//            self.remoteId = from
//        }
        if(type == "init") {
            print("init")
            if(self.type == "Server") {
                addPeerConnection(from: from, requestType: self.requestType, chunk: Data())
            }
            sendMessage(to: from, type: "init", payload: [:])
        } else if(type == "offer") {
            print("offer")
            createAnswerForOfferReceived(from:from, withRemoteSDP: payload["sdp"] as! String)
        } else if(type == "answer") {
            print("answer")
            handleAnswerReceived(from: from, withRemoteSDP: payload["sdp"] as! String)
        } else if(type == "candidate") {
            print("candidate")
            print(self.peerConnectionList[from]?.remoteDescription)
            if self.peerConnectionList[from]?.remoteDescription != nil {
                addIceCandidate(from: from, iceCandidate: RTCIceCandidate(sdp: payload["candidate"] as! String, sdpMLineIndex: payload["label"] as! Int32, sdpMid: payload["id"] as! String))
            }
        }
        
    }
    func emitServer(token:String, storageSize:Int, deviceId:String) {
        print("emit server called")
        var message:[String:Any] = [:]
        message["token"] = token
        message["size"] = storageSize
        message["deviceId"] = deviceId
        //socket.em
        socket?.emit("addserver",  message)
    }
    func sendMessage(to:String, type:String, payload:[String:Any]) {
        var message:[String:Any] = [:]
        message["to"] = to
        message["type"] = type
        message["payload"] = payload
        message["requestType"] = self.requestType
        message["order"] = self.orderIndex
        //socket.em
        print("sending message of type " + type + " to " + to)
        socket?.emit("message",  message)
//        do{
//        let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
//            print("type of message sent", type, " sent to ", to)
//        socket?.emit("message",  jsonData)
//        } catch{
//            print(error.localizedDescription)
//        }
    
    }
    func emitUpload(token:String, data: Data, fileUrl:URL) {
        self.requestType = "serverUpload"
        self.data = data
        self.fileUrl = fileUrl
        self.fileSize = data.count
        var storageSize = data.count
        print("file size is ",storageSize)
        var message:[String:Any] = [:]
        message["token"] = token
        message["size"] = storageSize
        //socket.em
        socket?.emit("upload",  message)
    }
    func emitDownload(token:String, fileId:Int) {
        self.requestType = "serverDownload"
        self.fileId = fileId
        var message:[String:Any] = [:]
        message["token"] = token
        message["fileId"] = fileId
        socket?.emit("download",  message)
    }
    
    var currentIndexPointer = 0
    var imageFileBytes:Data?
    var incomingFileSize:Int = 0
    func readIncomingImage(buffer:RTCDataBuffer, sendingChannel: RTCDataChannel) {
        print("receiving image")
        
        if !self.receivingFile {
            print("first message")
            var firstMessage = String(bytes: buffer.data, encoding: String.defaultCStringEncoding)
            let subString = firstMessage?.prefix(2)
            print(firstMessage)
            let type = String(subString!)
            print(subString, "   ", type)
            if type == "-i" {
                print("initialization")
                let incomingFile = firstMessage?.suffix(firstMessage!.count - 2)
                let size = String(incomingFile!)
                self.incomingFileSize = Int(size)!
                print("file size = ", incomingFileSize)
                self.receivingFile = true
                self.imageFileBytes = Data(capacity: incomingFileSize)
            } else if type == "-d" {
                print("-d request received for download")
                let chunkData = getSavedImage(name: "Image-" + String(self.fileId!) + ".png")
//                    self.img?.image?.pngData() else {return}
                    //self.img?.image?.jpegData(compressionQuality: 1.0) else { return }
                sendingChannel.sendData(RTCDataBuffer(data: chunkData, isBinary: false))
                
            } else if type == "-f" {
                let incomingFile = firstMessage?.suffix(firstMessage!.count - 2)
                let fId = String(incomingFile!)
                self.fileId = Int(fId)
            }
        } else {
            
            self.imageFileBytes?.append(buffer.data)
            currentIndexPointer += buffer.data.count
            if currentIndexPointer == incomingFileSize {
                print("received image completely")
                DispatchQueue.main.async {
//                    self.img?.image = UIImage(data: self.imageFileBytes!, scale: 2.0)
                    self.saveImage(data: self.imageFileBytes!)
                }
                
                receivingFile = false
                currentIndexPointer = 0
            }
        }
        
        
        
    }
    func makeoffer(from:String) {
        print("making offer")
        guard let peerConnection = self.peerConnection else {
            return
        }
        peerConnection.offer(for: self.defaultConstraint, completionHandler: { [weak self] (sdp, error) in
            guard let this = self else{ return }
            if let error = error {
                print("error")
                print(error)
                this.delegate?.rtcClient(client: self!, didReceiveError: error)
            } else {
                this.handleSdpGenerated(from: from, sdpDescription: sdp, type: "offer")
            }
        })
    }
    func handleSdpGenerated(from:String, sdpDescription: RTCSessionDescription?, type: String) {
        print("handling sdp")
        guard let sdpDescription = sdpDescription,
            let pc = self.peerConnectionList[from] else {
                return
        }
        pc.setLocalDescription(sdpDescription, completionHandler: {[weak self](error) in
            guard let this = self, let error = error else { return }
            print("error", error)
            //this.delegate?.rtcClient(client: this, didReceiveError: error)
        })
        var payload:[String:Any] = [:]
        payload["type"] = type
        payload["sdp"] = sdpDescription.sdp
        sendMessage(to: from, type: type, payload: payload)
        //self.delegate?.rtcClient(client: self, startCallWithSdp: sdpDescription.sdp)
    }
    func createAnswerForOfferReceived(from:String, withRemoteSDP remoteSdp: String?) {
        guard let remoteSdp = remoteSdp,
            let pc = self.peerConnectionList[from] else {
                return
        }
        let sessionDescription = RTCSessionDescription(type: .offer, sdp: remoteSdp)
        pc.setRemoteDescription(sessionDescription, completionHandler: {[weak self] (error) in
            guard let this = self else {return}
            if let error = error {
                this.delegate?.rtcClient(client: this, didReceiveError: error)
            } else {
                this.handleRemoteDescriptionSet(from:from)
                pc.answer(for: this.defaultConstraint, completionHandler: {(sdp, error) in
                    if let error = error {
                        this.delegate?.rtcClient(client: this, didReceiveError: error)
                    } else {
                        this.handleSdpGenerated(from: from, sdpDescription: sdp, type: "answer")
                        this.state = .connected
                    }
                })
            }
        })
    }
    func handleAnswerReceived(from:String, withRemoteSDP remoteSdp: String?) {
        guard let remoteSdp = remoteSdp,
        let pc = self.peerConnectionList[from]  else {
            return
        }
        let sessionDescription = RTCSessionDescription.init(type: .answer, sdp: remoteSdp)
        pc.setRemoteDescription(sessionDescription, completionHandler: {[weak self] (error) in
            guard let this = self else { return }
            if let error = error {
                this.delegate?.rtcClient(client: this, didReceiveError: error)
            } else {
                this.handleRemoteDescriptionSet(from:from)
                this.state = .connected
                print("connected")
            }
        })
    }
    func addIceCandidate(from:String, iceCandidate: RTCIceCandidate) {
        guard let pc = self.peerConnectionList[from]  else {
            return
        }
        pc.add(iceCandidate)
    }
    func handleRemoteDescriptionSet(from:String) {
        guard let pc = self.peerConnectionList[from]  else {
            return
        }
        for iceCandidate in self.remoteIceCandidates {
            pc.add(iceCandidate)
        }
        self.remoteIceCandidates = []
    }
    
    
   
    
}
extension WebRTCClient:  RTCPeerConnectionDelegate {

    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
            
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCSignalingState) {
        print("new state is ", newState)
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove rtpReceiver: RTCRtpReceiver) {
        
    }
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        //self.delegate?.rtcClient(client: self, didChangeConnectionState: newState)
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        //self.delegate?.rtcClient(client:self, didGenerateIceCandidate: candidate)
        var message:[String:Any] = [:]
        message["label"] = candidate.sdpMLineIndex
        message["id"] = candidate.sdpMid
        message["candidate"] = candidate.sdp
        sendMessage(to: self.remoteId , type: "candidate", payload: message)
        
        
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
    }
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("open data channel")
        dataChannel.delegate = self as RTCDataChannelDelegate
        self.remoteDataChannel = dataChannel
    }
}
extension WebRTCClient: RTCDataChannelDelegate {
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print("data channel changed state")

    }
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
           print("I got some data")
        readIncomingImage(buffer: buffer, sendingChannel: self.localDataChannel!)
    }
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didChangeBufferedAmount amount: UInt64) {
        print("change buffered amount")
    }
}
class MyConnection:NSObject {
   
    
    var orderIndex:Int
    var requestType:String
    var id:String
    var socket:SocketIOClient?
    var data:Data
    var type:String
    var isFinalChunk:Bool
    var controller:ClientViewController?
    var fileId:Int = -1
    var fileSize:Int = -1
    var fileName:String = ""
    var fileType:String = ""
    var receivingFile:Bool = false
    var doneUploading:Bool = false
    var incomingFileSize = 0
    var imageFileBytes:Data?
    var currentIndexPointer = 0
    var didDownloadList:[String:Bool] = [:]
    var doneSending:(String, Int) -> Void
    var removePeer:(String) -> Void
    var doneDownloading: (String, Data) -> Void
    var saveImage: (Data) -> Bool
    var getSavedImage: (String) -> Data
    var downloadChunks:[String:Data] = [:]
    var remoteDataChannel:RTCDataChannel?
    var remoteDelegate:RTCDataChannelDelegate?
    init(orderIndex:Int, requestType:String, id:String, socket:SocketIOClient, data:Data, type:String, isFinalChunk:Bool, controller:ClientViewController?, fileId:Int?, fileSize:Int?, fileName:String?, fileType:String?, didDownloadList:[String:Bool], downloadChunks:[String:Data], doneSending:@escaping (String, Int) -> Void, removePeer:@escaping (String) -> Void, doneDownloading:@escaping (String, Data) -> Void, saveImage:@escaping (Data) -> Bool, getSavedImage:@escaping (String) -> Data) {
        print("connection created")
        self.orderIndex = orderIndex
        self.requestType = requestType
        self.id = id
        self.socket = socket
        self.data = data
        self.type = type
        self.isFinalChunk = isFinalChunk
        self.controller = controller
        self.fileId = fileId ?? -1
        self.fileSize = fileSize ?? -1
        self.fileName = fileName ?? ""
        self.fileType = fileType ?? ""
        self.didDownloadList = didDownloadList
        self.doneSending = doneSending
        self.removePeer = removePeer
        self.downloadChunks = downloadChunks
        self.doneDownloading = doneDownloading
        self.saveImage = saveImage
        self.getSavedImage = getSavedImage
    }
    
    func sendMessage(to:String, type:String, payload:[String:Any]) {
            var message:[String:Any] = [:]
            message["to"] = to
            message["type"] = type
            message["payload"] = payload
            message["requestType"] = self.requestType
            message["order"] = self.orderIndex
            //socket.em
            print("sending message of type " + type + " to " + to)
            socket?.emit("message",  message)
    //        do{
    //        let jsonData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
    //            print("type of message sent", type, " sent to ", to)
    //        socket?.emit("message",  jsonData)
    //        } catch{
    //            print(error.localizedDescription)
    //        }
        
        }
    let CHUNK_SIZE = 64000
    func sendImage(data:Data, dc:RTCDataChannel) {
       var numOfChunks = data.count / CHUNK_SIZE
       var metaString = "-f" + String(fileId)
       print(metaString)
       var meta = Data(metaString.utf8)
        dc.sendData(RTCDataBuffer(data: meta, isBinary: false))
        metaString = "-i" + String(data.count)
       print(metaString)
        meta = Data(metaString.utf8)
       dc.sendData(RTCDataBuffer(data: meta, isBinary: false))
       for i in stride(from: 0, to: numOfChunks, by: 1) {
           var subData = data.subdata(in: (i*CHUNK_SIZE)..<CHUNK_SIZE+(i*CHUNK_SIZE))
           dc.sendData(RTCDataBuffer(data: subData, isBinary: false))
       }
       var remainder = data.count % CHUNK_SIZE
       if remainder > 0 {
           var subData = data.subdata(in: (numOfChunks*CHUNK_SIZE)..<remainder+(numOfChunks * CHUNK_SIZE))
           dc.sendData(RTCDataBuffer(data: subData, isBinary: false))
       }
       
    }
    func downloadRequest(dc:RTCDataChannel) {
        print("download request")
        var metaString = "-d" + String(self.fileId)
        var meta = Data(metaString.utf8)
        dc.sendData(RTCDataBuffer(data: meta, isBinary: false))
    }
    
    func readIncomingMessageForClient(buffer:RTCDataBuffer, dc:RTCDataChannel) {
        print("receiving image")
        if !self.receivingFile {
            print("first message")
            var firstMessage = String(bytes: buffer.data, encoding: String.defaultCStringEncoding)
            let subString = firstMessage?.prefix(2)
            print(firstMessage)
            let type = String(subString!)
            print(subString, "   ", type)
            if type == "-i" {
                print("initialization")
                let incomingFile = firstMessage?.suffix(firstMessage!.count - 2)
                let size = String(incomingFile!)
                self.incomingFileSize = Int(size)!
                print("file size = ", incomingFileSize)
                self.receivingFile = true
                self.imageFileBytes = Data(capacity: incomingFileSize)
            }
        } else {
            
            self.imageFileBytes?.append(buffer.data)
            currentIndexPointer += buffer.data.count
            if currentIndexPointer == incomingFileSize {
                print("received image completely")
//                DispatchQueue.main.async {
//                    self.img?.image = UIImage(data: self.imageFileBytes!, scale: 2.0)
//                }
                
                receivingFile = false
                currentIndexPointer = 0
//                didDownloadList[id] = true
                DispatchQueue.main.async {
                    self.doneDownloading(self.id, self.imageFileBytes!)
                }
                // checkDone()
//                print("check")
//                var completelyReceived = false
//                var i = 0
//                for (key, didDownload) in didDownloadList {
//                    print("value at ",i, " is ", didDownload)
//                    if(!didDownload) {
//                        break
//                    } else if(i == didDownloadList.count - 1) {
//                        print("done receiving")
//                        completelyReceived = true
//                    }
//                    i+=1
//                }
//                if(completelyReceived) {
//                    //mergePhoto()
//                    print(downloadChunks.count)
//                    didDownloadList.removeAll()
//                    downloadChunks.removeAll()
////                }
//                removePeer(id)
            }
            
            
        }
    }
    func readIncomingMessage(buffer:RTCDataBuffer, sendingChannel: RTCDataChannel) {
            print("receiving image")
            
            if !self.receivingFile {
                print("first message")
                var firstMessage = String(bytes: buffer.data, encoding: String.defaultCStringEncoding)
                let subString = firstMessage?.prefix(2)
                print(firstMessage)
                let type = String(subString!)
                print(subString, "   ", type)
                if type == "-i" {
                    print("initialization")
                    let incomingFile = firstMessage?.suffix(firstMessage!.count - 2)
                    let size = String(incomingFile!)
                    self.incomingFileSize = Int(size)!
                    print("file size = ", incomingFileSize)
                    self.receivingFile = true
                    self.imageFileBytes = Data(capacity: incomingFileSize)
                } else if type == "-d" {
                    print("-d request received for download")
                    DispatchQueue.main.async {
                        //
                        
                        let chunkData = self.getSavedImage("Image-" + String(self.fileId) + ".png")
                        self.sendImage(data: chunkData, dc: sendingChannel)
                    }
//                    let chunkData = getSavedImage(name: "Image-" + String(self.fileId!) + ".png")
//    //                    self.img?.image?.pngData() else {return}
//                        //self.img?.image?.jpegData(compressionQuality: 1.0) else { return }
//                    sendingChannel.sendData(RTCDataBuffer(data: chunkData, isBinary: false))
                    
                } else if type == "-f" {
                    let incomingFile = firstMessage?.suffix(firstMessage!.count - 2)
                    let fId = String(incomingFile!)
                    self.fileId = Int(fId)!
                }
            } else {
                
                self.imageFileBytes?.append(buffer.data)
                currentIndexPointer += buffer.data.count
                if currentIndexPointer == incomingFileSize {
                    print("received image completely")
                    DispatchQueue.main.async {
    //                    self.img?.image = UIImage(data: self.imageFileBytes!, scale: 2.0)
                        let savingStatus = self.saveImage(self.imageFileBytes!)
                        print("file saving status = ", savingStatus)
                    }
                    
                    receivingFile = false
                    currentIndexPointer = 0
                    removePeer(id)
                }
            }
            
            
            
        }
    
}

extension MyConnection:RTCDataChannelDelegate {
    
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
         print("data channel did change state")
         if(dataChannel.readyState == RTCDataChannelState.open) {
             print("data channel state is open")
             if(requestType == "serverUpload" && type == "Client") {
                 print("sending image")
                 sendImage(data: data, dc: dataChannel)
                 print("is this the final chunk",isFinalChunk)
                doneUploading = true
                 if(isFinalChunk) {
                     // done uploading
                     print("done uploading")
                    self.controller!.doneUploading(fileId: self.fileId, fileSize: self.fileSize, fileType: self.fileType, fileName: self.fileName)
                 }
             } else if(requestType == "serverDownload" && type == "Client") {
                 downloadRequest(dc: dataChannel)
             }
         }
     }
        
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
         print("data buffer received")
         if(type == "Client") {
             readIncomingMessageForClient(buffer:buffer, dc:dataChannel)
         }
    }
}



extension MyConnection:RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("peerconnectionstate changed")
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        if(newState == RTCIceConnectionState.new) {
            print("ice new for ", id)
        } else if(newState == RTCIceConnectionState.checking) {
            print("ice checking for ", id)
        } else if(newState == RTCIceConnectionState.connected) {
            print("ice connected for ", id)
        } else if(newState == RTCIceConnectionState.disconnected) {
            print("ice disconnected for ", id)
        } else if(newState == RTCIceConnectionState.closed) {
            print("ice closed for ", id)
        } else if(newState == RTCIceConnectionState.failed) {
            print("ice failed for ",id)
        }
//
//
//        if(peerConnection.connectionState == RTCPeerConnectionState.disconnected && type == "Server") {
//            // remove server
//            print("ice server disconnected")
//            self.doneSending(id)
//        } else
        if(newState == RTCIceConnectionState.disconnected && requestType == "serverUpload" && type == "Client") {
            print("ice done sending, disconnecting")
//            doneUploading = true
                self.removePeer(id)
//            self.doneSending(id, orderIndex)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("ice candidate gathering changed state")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        
        print("ice candidate generated")
        if(!doneUploading) {
            var message:[String:Any] = [:]
           message["label"] = candidate.sdpMLineIndex
           message["id"] = candidate.sdpMid
           message["candidate"] = candidate.sdp
           sendMessage(to: self.id , type: "candidate", payload: message)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        
        print("peer connection removed")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print("peer connection opened")
        self.remoteDelegate = ReceivingChannel(readIncomingMesssage: readIncomingMessage, readIncomingMessageForClient: readIncomingMessageForClient, type: self.type)
        dataChannel.delegate = self.remoteDelegate
        self.remoteDataChannel = dataChannel
//        dataChannel.delegate = self as RTCDataChannelDelegate
//        self.remoteDataChannel = dataChannel
    }
}
class ReceivingChannel:NSObject,RTCDataChannelDelegate {
    
    var readIncomingMesssage:(RTCDataBuffer, RTCDataChannel) -> Void
    var readIncomingMessageForClient:(RTCDataBuffer, RTCDataChannel) -> Void
    var type:String
    init(readIncomingMesssage:@escaping (RTCDataBuffer, RTCDataChannel) -> Void, readIncomingMessageForClient:@escaping (RTCDataBuffer, RTCDataChannel) -> Void, type:String) {
        self.readIncomingMesssage = readIncomingMesssage
        self.readIncomingMessageForClient = readIncomingMessageForClient
        self.type = type
    }
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        if(type == "Server") {
            self.readIncomingMesssage(buffer, dataChannel)
        } else if(type == "Client") {
            self.readIncomingMessageForClient(buffer, dataChannel)
        }
    }
    
}

