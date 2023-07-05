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
		stackView.spacing = 20.0
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(videoStackView)


		let tokens = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRkMzc3ZDRjNTBiMDY1ODRmMGY4MDJhYmFiNTIyMjg5ODJiMTk2YzAzNzYwNzE4NDhiNWJlNTczN2JiMWYwYTUiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJ6cm12aHZidSIsIm5hbWUiOiJmaWVyY2Vfc25haWwifSwiZ3JvdXAiOiIyMDIifSwic3ViIjoicXdmc2Q1N3BxOWR4YWtxcXVxNnNlcSIsInJvb20iOiIqIiwiaWF0IjoxNjg4NTQzMDM5LCJuYmYiOjE2ODg1NDMwMzksImlzcyI6InNhcmlza2EiLCJhdWQiOiJtZWRpYV9tZXNzYWdpbmdfY28tYnJvd3NpbmciLCJleHAiOjE2ODg2Mjk0Mzl9.XSuPg6mfg8h1e4R9f3TG2CLZcbj9n41gy_rOd8kTeiPBpktpOBmwL0yK1BLy-J46XM8WZDyUcwhymCc6PCzxGUmNAQDGyFwxjHuMVhneBOtdAxdooQmxk24W5PXnZtTZWT3AlrZc0ysMG5mOWGmh1KVbTVGMahyui7SeHg9d1DJtPIWLd2RKkg3talkRXhonwsvZ_VzxUN76myfGRw7q_AlvvugyXcnQ7j40Ck-mNtnLvndvT4stEtUNXMwGrsU7tTga-jDIiAPXtInAk6fHWbUwNvTsPKTj4s8a9YdQFZCe68aT3d3eW7BeP-sMo4Ohs1EauN-9T5VlatBzaaCjog"

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
		options["resolution"] = 240
		os_log("We are in setup local stream")
		SariskaMediaTransport.createLocalTracks(options) { tracks in
			DispatchQueue.main.async {
				self.localTracks = tracks as! [JitsiLocalTrack]
				for track in self.localTracks {
					if (track.getType() == "video")  {
						let videoView =  track.render()
						self.attachLocalVideo(videoView:  videoView, trackId: (track as AnyObject).getId())
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

	func attachLocalVideo(videoView: RTCVideoView, trackId: String){
		videoView.setObjectFit("cover")
		videoView.accessibilityLabel = trackId
		videoView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(videoView)

		// Set video view constraints
		NSLayoutConstraint.activate([
			videoView.topAnchor.constraint(equalTo: self.view.topAnchor),
			videoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			videoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			videoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])

		self.view.layoutIfNeeded()
	}

	func attachVideo(videoView: RTCVideoView, trackId: String) {
		videoView.setObjectFit("cover")
		videoView.accessibilityLabel = trackId
		videoView.translatesAutoresizingMaskIntoConstraints = false

		// Create a container view for the video view
		let containerView = UIView()
		containerView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(containerView)

		// Set container view constraints
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
			containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			containerView.widthAnchor.constraint(equalToConstant: 120),
			containerView.heightAnchor.constraint(equalToConstant: 90)
		])

		// Add the video view to the container view
		containerView.addSubview(videoView)

		// Set video view constraints within the container view
		NSLayoutConstraint.activate([
			videoView.topAnchor.constraint(equalTo: containerView.topAnchor),
			videoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			videoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			videoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
		])

		self.view.layoutIfNeeded()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		conference?.leave()
		connection?.disconnect()
	}

}