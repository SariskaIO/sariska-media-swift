// ContentView.swift
// Sariska-Demo-iOS
//
// Created by Dipak Sisodiya on 06/07/23.

import SwiftUI
import sariska

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()

    var body: some View {
        VStack {
            ZStack {
                Color.white
                    .frame(height: 700)  // Adjust the height as per your layout
                    .cornerRadius(10)

                if !viewModel.isViewHidden {
                    if let view = viewModel.videoView {
                        UIViewWrapper(view: view)
                    }
                }

                if !viewModel.isViewHidden {
                    VStack{
                        if let view = viewModel.videoView {
                            UIViewWrapper(view: view)
                        }

                        if let view = viewModel.remoteVideoView {
                            UIViewWrapper(view: view)
                        }
                    }
                }
            }
            VideoCallButtonsView(viewModel: viewModel)
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
    @Published var isViewHidden = true
    @Published var isRemoteViewHidden = true
    @Published var videoView: UIView? = nil
    @Published var remoteVideoView: UIView? = nil
    @Published var connection: Connection? = nil
    @Published var localTracks: [JitsiLocalTrack] = []
    @Published var conference: Conference? = nil
    @Published var callStarted = false

    init() {
        initializeSdk()
    }

    func initializeSdk() {
        SariskaMediaTransport.initializeSdk()
        setupLocalStream()

        let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRkMzc3ZDRjNTBiMDY1ODRmMGY4MDJhYmFiNTIyMjg5ODJiMTk2YzAzNzYwNzE4NDhiNWJlNTczN2JiMWYwYTUiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJqdmd5MXNlbiIsIm5hbWUiOiJjcmltaW5hbF9tb25nb29zZSJ9LCJncm91cCI6IjIwMiJ9LCJzdWIiOiJxd2ZzZDU3cHE5ZHhha3FxdXE2c2VxIiwicm9vbSI6IioiLCJpYXQiOjE2ODkwMDIzMTIsIm5iZiI6MTY4OTAwMjMxMiwiaXNzIjoic2FyaXNrYSIsImF1ZCI6Im1lZGlhX21lc3NhZ2luZ19jby1icm93c2luZyIsImV4cCI6MTY4OTA4ODcxMn0.eiZ1QI84ImsOQQetQics3gmvABxusabiE0OFiJxTED7z_WD0zcGk8WsIz377HJI5Dfnx1WBuMsRMTCcd3RJ6nOW7IA-qLmCDZ_ZNMbjCqQ3TAwQvPNO6A81HUIPEPkGDaqJQWGwsLWWWcArYJJuGhNwFxClNs0Qs03JgkndRfNrIBzM9GbmixdoukOWbwKauPPjkWWLXZaWTulyCcdGgPXovTFbcXlXePaAjLgvLmF7nUSSWTES22NIWetN5-y4nI7WojOWfMDKZXtCV5u-drCtdmav0Do7eoM-nfkKpvTcTzhrg7XM9UV71xrrgDoNM2xnLTGpPcyPxvBPc1ghlAQ"
        connection = SariskaMediaTransport.jitsiConnection(token, roomName: "dasdsad", isNightly: false)

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
                print("Type of video: " + remoteTrack.getType())
                if(remoteTrack.getStreamURL() == localTracks[0].getStreamURL()){
                    print("returning")
                    return
                }else if (remoteTrack.getStreamURL() == localTracks[1].getStreamURL()){
                    print("returning video")
                    return
                }
                if(remoteTrack.getType().elementsEqual("video") ){
                    self.remoteVideoView = remoteTrack.render()
                    self.isRemoteViewHidden.toggle()
                }
            }
        }

        conference?.addEventListener("USER_LEFT") { _, _ in
            print("User left")
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
        options["resolution"] = 720

        SariskaMediaTransport.createLocalTracks(options) { tracks in
            DispatchQueue.main.async {
                self.localTracks = tracks as! [JitsiLocalTrack]
                for track in self.localTracks {
                    if track.getType() == "video" {
                        let sdasd = track.render()
                        self.videoView = sdasd
                        self.isViewHidden.toggle()
                    }
                }
            }
        }
    }
}

struct VideoCallButtonsView: View {
    @ObservedObject var viewModel: ContentViewModel

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
                viewModel.isViewHidden.toggle()
                if(viewModel.callStarted){
                    viewModel.conference?.leave()
                    viewModel.connection?.disconnect()
                }else{
                    viewModel.initializeSdk()
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
