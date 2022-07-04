import UIKit
import sariska;
import OSLog;

class ViewController: UIViewController {
	
    var connection: Connection? = nil
	var conference: Conference? = nil
	var stackView: UIStackView? = nil
	var localTracks: [JitsiLocalTrack] = []
	
	lazy var videoStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 0.2
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(videoStackView)
		
        let tokens = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmYjc1MTJjZjgzYzdkYTRjMjM0Y2QzYWEyYWViOTUzMGNlZmUwMDg1YzRiZjljYzgwY2U5YmQ5YmRiNjA3ZjciLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiI2YjFmZ2p4dSIsImF2YXRhciI6IiNENEI2NjIiLCJuYW1lIjoiZGlwYWtpb3MifSwiZ3JvdXAiOiIxIn0sInN1YiI6InVhdG5jb2U1djcybG5vaGxud2dxdjgiLCJyb29tIjoiKiIsImlhdCI6MTY1NjkyOTg2NywibmJmIjoxNjU2OTI5ODY3LCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNjU3MTAyNjY3fQ.ilIpGM7Z7IrZAitLVyXbE5eUBqHbGlMD0hewvDxpySydlwTKE5H8qRe62P-QxZeC46eYsBBQmcjM_nA03XBfxHN_JnFo5LVpBDjZhVlrULxftp241-XUj4STGXFBVR8CE8fBKPmJaEp1H9x9GFijELZ7y3WYBiNAJoaPODjNZ--O4RxlhDdil5XEX6UNMa_xf6gaR4KvXDgHoeZJE4DeCbLm0EJbtDkMCo2-L47O_c8TKWaPdPSI6lMnjuNiekn7kymnlwSuwlzb2-Efwrf6HJRYbbZPtLMMx9qWfNUFFxUxMpAAC9F0JKQpfdVxsaxMS8mdjO8r18xzY8ukmAhBOw"
        
        SariskaMediaTransport.initializeSdk()
        
		setupLocalStream()
        
        self.connection = SariskaMediaTransport.jitsiConnection(tokens, roomName: "dipak", isNightly: false)
        
        if(self.connection == nil){
            os_log("connection is nill")
        }
        
        self.connection?.addEventListener("CONNECTION_ESTABLISHED", callback: {
            os_log("Inside the first callback")
            self.createConference()
        })
        
        self.connection?.addEventListener("CONNECTION_FAILED", callback: {
            
            os_log("Inside the second callback")
        })
        
        self.connection?.addEventListener("CONNECTION_DISCONNECTED", callback: {
            os_log("Inside the third callback")
        })
        
        self.connection?.connect()
	}
	
	func setupLocalStream() {
		var options:[String: Any] = [:]
		options["audio"] = true
		options["video"] = true
		options["resolution"] = 720
        os_log("We are in setup local stream")
        SariskaMediaTransport.createLocalTracks(options) { tracks in
            DispatchQueue.main.async {
               self.localTracks = tracks as! [JitsiLocalTrack]
               for track in tracks {
                   if ((track as AnyObject).getType() == "video")  {
                       let videoView =  (track as AnyObject).render()
                       videoView.setMirror(true)
                       self.attachVideo(videoView:  videoView, trackId: (track as AnyObject).getId())
                   }
               }
           }
        }
	}
	
	
	func createConference() {
		
		guard let connection = connection else {
			return
		}
		
		conference = connection.initJitsiConference()
		
        conference?.addEventListener("CONFERENCE_JOINED") {
			for track in self.localTracks {
                self.conference?.addTrack(track: track)
			}
		}
		
        conference?.addEventListener("TRACK_ADDED") { track in
			let track = track as! JitsiRemoteTrack
            if(track.getStreamURL() == self.localTracks[1].getStreamURL()){
                return;
            }
			DispatchQueue.main.async {
				if (track.getType() == "video") {
					let videoView =  track.render()
					self.attachVideo(videoView:  videoView, trackId: track.getId())
				}
			}
		}
		
        conference?.addEventListener("TRACK_REMOVED") { track in
			let track = track as! JitsiRemoteTrack
			DispatchQueue.main.async {
				self.removeVideo(trackId: track.getId())
			}
		}
		
        conference?.addEventListener("CONFERENCE_LEFT") {
			print("CONFERENCE_LEFT")
		}
        
        conference?.join()
        
        var streamOptions:[String: Any] = [:]
        streamOptions["streamId"] = "vtpv-yt0u-pbc1-1fjp-5ps5"
        streamOptions["mode"] = "stream"
        
        conference?.startRecording(streamOptions)
	}
	
	
	
	func removeVideo( trackId: String) {
		if let first = self.videoStackView.arrangedSubviews.first(where: { $0.accessibilityLabel == trackId }) {
			UIView.animate(withDuration: 0.3, animations: {
				first.isHidden = true
				first.removeFromSuperview()
			}) { (_) in
				self.view.layoutIfNeeded()
			}
		}
	}
	
	func attachVideo(videoView: RTCVideoView, trackId: String){
		videoView.setObjectFit("cover")
		videoView.accessibilityLabel = trackId
		videoView.heightAnchor.constraint(equalToConstant: 240).isActive = true
		videoView.widthAnchor.constraint(equalToConstant: 360).isActive = true
		self.videoStackView.addArrangedSubview(videoView)
		self.view.layoutIfNeeded()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		conference?.leave()
		connection?.disconnect()
	}
	
}
