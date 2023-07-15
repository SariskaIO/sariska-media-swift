// ContentView.swift
// Sariska-Demo-iOS
//
// Created by Dipak Sisodiya on 06/07/23.

import SwiftUI
import sariska

struct ContentView: View {

    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    @Binding var roomName: String
    
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
            
            VideoCallButtonsView(viewModel: viewModel, roomName: roomName)
        }

    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(roomName: "preview")
//    }
//}

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

    init() {
        initializeSdk()
    }

    func initializeSdk() {
        SariskaMediaTransport.initializeSdk()
    }
    
    func createConnection(room: String){
        
        setupLocalStream()
        
        let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1NjdlNjM5MTVhMjg0YzNmZjY3NzA0MjJkZjY2YjBiNTBhMDg1NjIwMmMxY2U5Y2ZhODA1ZDBlZGY1YjJjMTYiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJ1eWw1OTBobiIsIm5hbWUiOiJwYXNzaW5nX25pZ2h0aW5nYWxlIn0sImdyb3VwIjoiNDMyIn0sInN1YiI6ImV6d3lnNWFlemRocjVxbnJxdXRjbzciLCJyb29tIjoiKiIsImlhdCI6MTY4OTQyNzA0MSwibmJmIjoxNjg5NDI3MDQxLCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNjg5NTEzNDQxfQ.Fa6tRH5xb3nfMV8_ba1yDnY4Ngf5XH3Y5KtlQ_pQO_scD_S0mMV_7UFh7Us2Ybkr18aNxIsKOLKddyZBgZMJJJGlrvDJ_LiPwanmXnqiNCwuA9aYT_JmbQmRUXD95lgA0kuTmkjlvH8njIjimbGrHarv3pp3gVn7ZyY8YU80958ZwvXyycuTvCC8oAoIdodiGXp97B-6cfKFYJAGQadTgd1WRn6e75iKHVz5DiuOrI4OByyH-PAkMeUR2on3nk0S1SfaA9e1_BDLYdf0YeIaP_55ufxTEvDBNpH4Tnd931ETuEHmvLk7lDNCG2wnqAA1BwIIooMD0HLferHToNBSZQ"
        
        connection = SariskaMediaTransport.jitsiConnection(token, roomName: room, isNightly: false)

        connection?.addEventListener("CONNECTION_ESTABLISHED") {
            self.createConference()
        }

        connection?.addEventListener("CONNECTION_FAILED") {
        }

        connection?.addEventListener("CONNECTION_DISCONNECTED") {
        }

        connection?.connect()
    }
    

    func createConference() {
        guard let connection = connection else {
            return
        }

        conference = connection.initJitsiConference()

        conference?.addEventListener("CONFERENCE_JOINED") { [self] in
            for track in self.localTracks {
                conference?.addTrack(track: track)
                callStarted = true;
            }
        }

        conference?.addEventListener("CONFERENCE_FAILED"){
        }

        conference?.addEventListener("TRACK_ADDED") { track in
            DispatchQueue.main.async { [self] in
                guard let remoteTrack = track as? JitsiRemoteTrack else {
                    return
                }
                if(remoteTrack.getStreamURL() == localTracks[0].getStreamURL() || remoteTrack.getStreamURL() == localTracks[1].getStreamURL()){
                    print("returning")
                    return
                }
                if(remoteTrack.getType().elementsEqual("video") ){
                    let rtcRemoteView = remoteTrack.render()
                    numberOfParticipants = numberOfParticipants+1
                    participantViews[remoteTrack.getParticipantId()] = numberOfParticipants
                    rtcRemoteView.tag = numberOfParticipants
                    self.remoteViews.append(remoteTrack.render())
                }
            }
        }

        conference?.addEventListener("USER_LEFT") { id, participant in
            DispatchQueue.main.async { [self] in
                remoteViews.removeAll()
            }
        }

        conference?.addEventListener("CONFERENCE_LEFT") { [self] in
            callStarted = false
        }

        conference?.join()
    }

    func setupLocalStream() {
        var options: [String: Any] = [:]
        options["audio"] = true
        options["video"] = true
        options["resolution"] = 240

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
    
    init(viewModel: ContentViewModel, roomName: String) {
        self.viewModel = viewModel
        print("room Name")
        print(roomName)
        
        self.roomName = roomName
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
                    viewModel.isOnlyLocalView = false
                }else{
                    //viewModel.initializeSdk()
                    viewModel.isOnlyLocalView = true
                    viewModel.createConnection(room: roomName)
                }
                viewModel.callStarted.toggle()
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
