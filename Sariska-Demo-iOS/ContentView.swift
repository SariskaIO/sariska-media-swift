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
  //var localTracks: [JitsiLocalTrack] = []

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

    var options: [String: Any] = [:]
    options["audio"] = true
    options["video"] = true
    options["resolution"] = 720

    SariskaMediaTransport.createLocalTracks(options) { tracks in
      DispatchQueue.main.async {
        let localTracks = tracks as! [JitsiLocalTrack]
        for track in localTracks {
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
