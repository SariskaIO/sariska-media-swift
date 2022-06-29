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
		stackView.spacing = 0.0
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(videoStackView)
		
        let tokens = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmYjc1MTJjZjgzYzdkYTRjMjM0Y2QzYWEyYWViOTUzMGNlZmUwMDg1YzRiZjljYzgwY2U5YmQ5YmRiNjA3ZjciLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJ5Y3V1a3dsbyIsImF2YXRhciI6IiNCNkRDRDgiLCJuYW1lIjoiZGlwYWtpb3MifSwiZ3JvdXAiOiIxIn0sInN1YiI6InVhdG5jb2U1djcybG5vaGxud2dxdjgiLCJyb29tIjoiKiIsImlhdCI6MTY1NjM5NzE4MiwibmJmIjoxNjU2Mzk3MTgyLCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNjU2NTY5OTgyfQ.hcWNZSM4Mfmm94h3bIKFN8bYzRFjcbnqFf6HXZM9Ge7n4baj6f43IatdXTW5jWlYU6dO1BHTj0T8h7CCfbmbxz3eWbCgdNb085Y9YSxLvYqf2TTIWHNRvIb0740al63Yb_36Q0ib7Ua2HglP5ox8y19vi2gD_bEb38_Igwax6q2Gn2nN_47GB6FBBwWyLsbDpEG93A64u__ZiSOwZ8xIzpGUeC0_QAh_JGMm0mTyAkLXddr-vzOIi8B_cgh5f_gLaoP-zATHlea7Ew-wEZHVg2tdDJ0KoDfkTlfhdnkU3MECadPsZ9i650HXKqqx8UxGuubMR2C4MQcZtOQGxbJVhA"
        
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
