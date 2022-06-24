import UIKit
import sariska;

class ViewController: UIViewController {
	
    var connection: Connection? = nil
	var conference: Conference? = nil
	var stackView: UIStackView? = nil
	var localTracks: [JitsiLocalTrack] = []
	
	lazy var videoStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 20.0
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(videoStackView)
		
        let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjNmYjc1MTJjZjgzYzdkYTRjMjM0Y2QzYWEyYWViOTUzMGNlZmUwMDg1YzRiZjljYzgwY2U5YmQ5YmRiNjA3ZjciLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiIxMDkzOTEzODEwNDc3NTkzNTI4NTQiLCJhdmF0YXIiOiIjMjkxMTVDIiwibmFtZSI6IkRpcGFrIFNpc29kaXlhIiwiZW1haWwiOiJkaXBhay5zaXNvNUBnbWFpbC5jb20ifSwiZ3JvdXAiOiIxIn0sInN1YiI6InVhdG5jb2U1djcybG5vaGxud2dxdjgiLCJyb29tIjoiKiIsImlhdCI6MTY1NjA2MjUxOSwibmJmIjoxNjU2MDYyNTE5LCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNjU2MjM1MzE5fQ.pI76IdcqGgko5vNJ4JaQfNCOhDK3C9nSr1mYkk6BI-qcibhafSQhh8kLanm8Bm5vT2oG0RntjBC7CBYu0zeAuYsgnh8ZNI1qckdXrd3Fz1Unu9Jg-T6XK_JFJPXSOQI5p7agIzmE_fFle7GkiUkvLgWFRugBTV_MeZZ_YWZ75V0oZPPoFKIYjjHyvm-KxXiedMkXGY7kFoih9TAkf2tTzRB8njAX1X_-EZsqL_wcSUN0zwzLqsVnZK1KLd5_gunZgxe26SGUgXZdB0_SGC-zanVijYmww1qt2AgCnYwpxEi6-n9meYgoHcENEwOsHocESTP3ZOpTvvokixjMLw44QA"
		
		
        SariskaMediaTransport.initializeSdk()
		
		setupLocalStream()
		
        let connections = SariskaMediaTransport.jitsiConnection(token, roomName: "dipak", isNightly: false)
        connections.connect();

            //(NSString *) roomName isNightly:  (BOOL)

//        connections.addEventListener("CONNECTION_ESTABLISHED") {
//            self.connection = connections;
//			self.createConference()
//		}
//
//        connections.addEventListener("CONNECTION_FAILED") {
//			print("CONNECTION_FAILED")
//		}
//
//        connections.addEventListener("CONNECTION_DISCONNECTED") {
//			print("CONNECTION_DISCONNECTED")
//		}
//
//		connections.connect()
	}
	
	func setupLocalStream() {
		var options:[String: Any] = [:]
		options["audio"] = true
		options["video"] = true
		options["resolution"] = 240
		
        SariskaMediaTransport.createLocalTracks(options) { tracks in
			DispatchQueue.main.async {
                self.localTracks = tracks as! [JitsiLocalTrack]
				for track in tracks {
                    if ((track as AnyObject).getType() == "video")  {
                        let videoView =  (track as AnyObject).render()
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
		guard let conference = conference else {
			return
		}
		
        conference.addEventListener("CONFERENCE_JOINED") {
			for track in self.localTracks {
				conference.addTrack(track: track)
			}
		}
		
        conference.addEventListener("TRACK_ADDED") { track in
			let track = track as! JitsiRemoteTrack
			DispatchQueue.main.async {
				if (track.getType() == "video") {
					let videoView =  track.render()
					self.attachVideo(videoView:  videoView, trackId: track.getId())
				}
			}
		}
		
        conference.addEventListener("TRACK_REMOVED") { track in
			let track = track as! JitsiRemoteTrack
			DispatchQueue.main.async {
				self.removeVideo(trackId: track.getId())
			}
		}
		
        conference.addEventListener("CONFERENCE_LEFT") {
			print("CONFERENCE_LEFT")
		}
		
		conference.join()
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
