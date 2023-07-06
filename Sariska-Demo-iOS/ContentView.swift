//
//  ContentView.swift
//  Sariska-Demo-iOS
//
//  Created by Dipak Sisodiya on 06/07/23.
//

import SwiftUI
import sariska

struct ContentView: View {

  @State private var isAudioMuted = false
  @State private var isVideoMuted = false
  @State private var isViewHidden = false
  @State private var videoView: UIView? = nil
  @State private var connection: Connection? = nil
  @State private var localTracks: [JitsiLocalTrack] = []

  var body: some View {
    VStack {
      ZStack {
        Color.white
          .frame(height: 700)  // Adjust the height as per your layout
          .cornerRadius(10)
        if !isViewHidden {
          if let view = videoView {
            UIViewWrapper(view: view)
          }
        }
      }
      Spacer()
      videoCallButtons()
    }.onChange(of: videoView) { newValue in
      // React to changes in videoView and update the view
      if newValue != nil {
        isViewHidden = false
      } else {
        isViewHidden = true
      }
    }
  }

  func initializeSdk() {
    SariskaMediaTransport.initializeSdk()
    setupLocalStream()

    var token = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRkMzc3ZDRjNTBiMDY1ODRmMGY4MDJhYmFiNTIyMjg5ODJiMTk2YzAzNzYwNzE4NDhiNWJlNTczN2JiMWYwYTUiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJoc3QxbHVlYSIsIm5hbWUiOiJlZmZpY2llbnRfc3dhbiJ9LCJncm91cCI6IjIwMiJ9LCJzdWIiOiJxd2ZzZDU3cHE5ZHhha3FxdXE2c2VxIiwicm9vbSI6IioiLCJpYXQiOjE2ODg2NDAxMTIsIm5iZiI6MTY4ODY0MDExMiwiaXNzIjoic2FyaXNrYSIsImF1ZCI6Im1lZGlhX21lc3NhZ2luZ19jby1icm93c2luZyIsImV4cCI6MTY4ODcyNjUxMn0.uK6tnIDhd3ZzpIqffh79DiAMYD9KpAgDxRGg6-4ffrH7Ur4vGRvSvwAWq_EgmgO7yhLWwnKmHL6JvAui0rOTL-XgvvLsEIvXbk8alpdlCQNJ1WFx2sN30xoDaHnc231dvRyixuYXBn4-L_vny_NGmlNAWbsbyDp918BG-nZZnQrl6NqhdP25KIogeKzZe9zdwEbUpN-EIWwL2VOpnXCBcnOJPf7Be8-4sGAut1_JJDtiCmeJgK6ms0DqrJIX01EAFIR1LKmPLys-fXF9BJOaoderGhb6GoRdS1_D1M2N6O1p35GKyFWDoMSmWEXQh_5aNzwLpalQbSTQ9zG7nQwouQ";

    self.connection = SariskaMediaTransport.jitsiConnection(token, roomName: "dasdsad", isNightly: false)

        connection?.addEventListener("CONNECTION_ESTABLISHED") {
            createConference()
        }

        connection?.addEventListener("CONNECTION_FAILED") {
        }

        connection?.addEventListener("CONNECTION_DISCONNECTED") {
        }

        connection?.connect()
  }

  func createConference() {

    let conference = self.connection?.initJitsiConference()

    conference?.addEventListener("CONFERENCE_JOINED") {
      for track in self.localTracks {
        conference?.addTrack(track: track)
      }
    }

    conference?.addEventListener("TRACK_ADDED") { track in
      // TODO
    }

//    conference?.addEventListener("TRACK_REMOVED") { track in
//      // TODO
//    }

    conference?.addEventListener("CONFERENCE_LEFT") {
      // TODO
    }

    conference?.join()

  }
    
    func setupLocalStream(){
        var options: [String: Any] = [:]
        options["audio"] = true
        options["video"] = true
        options["resolution"] = 720
      
        SariskaMediaTransport.createLocalTracks(options) { tracks in
          DispatchQueue.main.async {
            self.localTracks = tracks as! [JitsiLocalTrack]
            for track in self.localTracks {
              if track.getType() == "video" {
                let videoView = track.render()
                self.videoView = videoView
              }
            }
          }
        }
    }

  fileprivate func videoCallButtons() -> some View {
    return HStack {

      Button(action: {
        // Switch camera button action
      }) {
        Image(systemName: "camera.rotate")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
      }

      Spacer()

      Button(action: {
        // End call button action
        isViewHidden.toggle()
        initializeSdk()
      }) {
        Image(systemName: "phone.down.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
          .foregroundColor(.red)

      }

      Spacer()

      Button(action: {
        isAudioMuted.toggle()
      }) {
        Image(systemName: isAudioMuted ? "mic.slash.fill" : "mic.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
      }

      Spacer()

      Button(action: {
        isVideoMuted.toggle()
      }) {
        Image(systemName: isVideoMuted ? "video.slash.fill" : "video.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 30)
      }
    }
    .padding()
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
