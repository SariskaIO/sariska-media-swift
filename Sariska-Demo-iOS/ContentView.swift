// ContentView.swift
// Sariska-Demo-iOS
//
// Created by Dipak Sisodiya on 06/07/23.

import SwiftUI
import sariska
import Alamofire

struct ContentView: View {
    
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    @Binding var roomName: String
    @Binding var userName: String
    
    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .frame(height: 720)  // Adjust the height as per your layout
                    .cornerRadius(10)

                if !viewModel.isOnlyLocalView {
                    if let view = viewModel.videoView {
                        UIViewWrapper(view: view)
                    }
                }

                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.remoteViews, id: \.self) { item in
                            Rectangle()
                                    .foregroundColor(.none)
                                    .frame(width: 150, height: 150)
                                    .overlay(
                                            UIViewWrapper(view: item), alignment: .bottom
                                    )
                                    .cornerRadius(10)
                        }
                    } .offset(y: 200)
                            .padding()

                }
            }
            
            VideoCallButtonsView(viewModel: viewModel, roomName: roomName, userName: userName)
            
        }.alert("Allow?", isPresented: $viewModel.isShowingPopup) {
            Button("Approve") {
                viewModel.approveAccess(id: viewModel.getId())
            }
            Button("Deny", role: .cancel) {
                viewModel.denyAccess(id: viewModel.getId())
            }
        } message: {
            Text("Approve to let the participant in.")
        }
    }
}

struct UIViewWrapper: UIViewRepresentable {
    let view: UIView

    func makeUIView(context: Context) -> UIView {
        view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the UIView if needed
    }
}

class ContentViewModel: ObservableObject {
    @Published var isAudioMuted = false
    @Published var isVideoMuted = false
    @Published var isOnlyLocalView = true
    @Published var isRemoteViewHidden = true
    @Published var videoView: UIView? = nil
    @Published var remoteVideoView: UIView? = nil
    @Published var connection: Connection? = nil
    @Published var localTracks: [JitsiLocalTrack] = []
    @Published var conference: Conference? = nil
    @Published var callStarted = false
    @Published var remoteViews: [RTCVideoView] = []
    @Published var participantViews: [String: Int] = [:]
    @Published var numberOfParticipants = 0
    @Published var roomName: String? = nil
    @Published var isShowingPopup=false
    @Published var id: String? = nil

    init() {
        initializeSdk()
        setupLocalStream()
    }

    func initializeSdk() {
        SariskaMediaTransport.initializeSdk()
    }
    
    func createConnection(room: String, userName: String){
        makeAPIRequest(apiKey: "249202aabed00b41363794b526eee6927bd35cbc9bac36cd3edcaa", room: room, userName: userName)
    }
    
    func approveAccess(id: String){
        self.conference?.lobbyApproveAccess(id)
    }
    
    func denyAccess(id: String){
        self.conference?.lobbyDenyAccess(id)
    }
    
    func getId() -> String{
        return self.id ?? "null"
    }
    
    func makeAPIRequest(apiKey: String, room: String, userName: String){
        let url = "https://api.sariska.io/api/v1/misc/generate-token"
        
        let parameters: [String: Any] = [
            "apiKey": apiKey,
            "user": [
                "name": userName,
            ]
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    // Handle successful response
                    if let json = value as? [String: Any], let token = json["token"] as? String {
                        // Extracted token value
                        
                        self.connection = SariskaMediaTransport.jitsiConnection(token, roomName: room, isNightly: false)

                        connection?.addEventListener("CONNECTION_ESTABLISHED") {
                            self.createConference()
                        }

                        self.connection?.addEventListener("CONNECTION_FAILED") {
                        }

                        self.connection?.addEventListener("CONNECTION_DISCONNECTED") {
                        }

                        self.connection?.connect()
                    } else {
                        print("Invalid response format.")
                    }
                    
                case .failure(let error):
                    // Handle error
                    print("Error: \(error)")
                }
            }
    }
    
    func createConference() {
        guard let connection = connection else {
            return
        }

        conference = connection.initJitsiConference()

        conference?.addEventListener("CONFERENCE_JOINED") { [self] in
            for track in self.localTracks {
                conference?.addTrack(track: track)
                callStarted = true
            }
        }

        conference?.addEventListener("CONFERENCE_FAILED"){
            print("conference failed")
            self.conference?.joinLobby(self.conference?.getUserName() ?? "Default User", email: "emailer@gmail.com")
        }

        conference?.addEventListener("TRACK_ADDED") { track in
            DispatchQueue.main.async { [self] in
                guard let remoteTrack = track as? JitsiRemoteTrack else {
                    return
                }
                if(remoteTrack.getStreamURL() == localTracks[0].getStreamURL() || remoteTrack.getStreamURL() == localTracks[1].getStreamURL()){
                    return
                }
                if(remoteTrack.getType().elementsEqual("video") ){
                    let rtcRemoteView = remoteTrack.render()
                    numberOfParticipants = numberOfParticipants+1
                    participantViews[remoteTrack.getParticipantId()] = numberOfParticipants
                    rtcRemoteView.tag = numberOfParticipants
                    self.remoteViews.append(remoteTrack.render() )
                }
            }
        }

        conference?.addEventListener("USER_JOINED", callback2: {
            id, participant in
                print("USER_JOINED")
        })
        
        conference?.addEventListener("USER_LEFT") { id in
            print("It was real")
            DispatchQueue.main.async { [self] in
                            remoteViews.removeAll()
            }
        }

        conference?.addEventListener("USER_ROLE_CHANGED", callback1: {id in
            print("User role changed")
            print(self.conference?.getUserRole() ?? "Don't know")
            if(self.conference?.getUserRole() == "moderator"){
                self.conference?.enableLobby()
                print("enabled lobby")
            }
        })
        
        conference?.addEventListener("LOBBY_USER_JOINED", callback2: {id, name in
            print("id for lobby user: ", id)
            print("name: ", name)
            self.id = id as? String
            self.isShowingPopup = true
        })

        conference?.addEventListener("CONFERENCE_LEFT") { [self] in
            callStarted = false
            DispatchQueue.main.async { [self] in
                            remoteViews.removeAll()
            }
        }

        conference?.join()
    }

    func setupLocalStream() {
        var options: [String: Any] = [:]
        options["audio"] = true
        options["video"] = true
        options["resolution"] = 720

        SariskaMediaTransport.createLocalTracks(options) { tracks in
            DispatchQueue.main.async {
                self.localTracks = tracks as! [JitsiLocalTrack]
                for track in self.localTracks {
                    if track.getType() == "video" {
                        let sdasd = track.render()
                        self.videoView = sdasd
                        self.isOnlyLocalView.toggle()
                    }
                }
            }
        }
    }
}

struct VideoCallButtonsView: View {
    @ObservedObject var viewModel: ContentViewModel
    var roomName: String
    var userName: String
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: ContentViewModel, roomName: String, userName: String) {
        self.viewModel = viewModel
        self.roomName = roomName
        self.userName = userName
    }

    var body: some View {
        HStack {
            Button(action: {
                if viewModel.isAudioMuted {
                    viewModel.localTracks[0].unmute()
                } else {
                    viewModel.localTracks[0].mute()
                }
                viewModel.isAudioMuted.toggle()
            }) {
                Image(systemName: viewModel.isAudioMuted ? "mic.slash.fill" : "mic.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
            }

            Spacer()

            Button(action: {
                // End call button action
                if(viewModel.callStarted){
                    viewModel.conference?.leave()
                    viewModel.connection?.disconnect()
                    dismiss()
                }else{
                    viewModel.createConnection(room: roomName, userName: userName)
                    viewModel.callStarted = true
                }
            }) {
                Image(systemName: viewModel.callStarted ? "phone.down.fill": "phone.fill.arrow.up.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(viewModel.callStarted ? .red : .green)
            }

            Spacer()

            Button(action: {
                if viewModel.isVideoMuted {
                    viewModel.localTracks[1].unmute()
                    viewModel.localTracks = viewModel.conference?.getLocalTracks() as! [JitsiLocalTrack]
                    viewModel.videoView = viewModel.localTracks[1].render()
                } else {
                    viewModel.localTracks[1].mute()
                }
                viewModel.isVideoMuted.toggle()
                if viewModel.isVideoMuted {
                    viewModel.videoView = nil
                }
            }) {
                Image(systemName: viewModel.isVideoMuted ? "video.slash.fill" : "video.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
            }
        }.padding([.horizontal], 20)
    }

    private func createVideoClosedImageView() -> UIView? {
        let imageView = UIImageView(image: UIImage(named: "video_closed"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
