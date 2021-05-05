import UIKit


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
		
		let token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjI0ZmQ2ZjkyZDZkMDE3NDkyZTNlOThlMzM0ZWJhZmM3NmRkMzUwYmI5M2EwNzI5ZDM4IiwidHlwIjoiSldUIn0.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiJjZG00b2R6eiIsIm5hbWUiOiJvcHBvc2l0ZV9waW5uaXBlZCJ9LCJncm91cCI6Imc3cWtua205YWJ0cDFuYWd2eXk1ZnUifSwic3ViIjoiMiIsInJvb20iOiI5czdmc3ljeHViIiwiaWF0IjoxNjE5ODMwMTU3LCJuYmYiOjE2MTk4MzAxNTcsImlzcyI6InNhcmlza2EiLCJhdWQiOiJtZWRpYV9tZXNzYWdpbmdfc2FyaXNrYSIsImV4cCI6MTYxOTkxNjU1N30.tRyC5ec5DneQd1E8mU_nNwN8-WnfadNY-HYy8fSZe6ZtG4NDypC0dRngUZFa8zGdxRVzQRri_jPit3ua11zvfkiixDJFJ0q2vlcD72680z03FAS8YrFHpJOgJ0kxZW4NZ0gw_94IvEYXOCqDelP_gEYDQ3qPRhsasEKf6KYD1WL3SsYV70dkhj9evsSdTxUjUBX0Krp1Ou41Q44GGBEuiYwxqZwsFoP6zN9xflrioZ-R8cCV838WHn68k8luUyx2uPWvsFDpGoQ2nnKkqyYt0k5SNzmZq4Wc76iJU5FiMNpR_eqgdO1FqXZG14qSGCEo1RxJrYT9euY5QiIVEmAzjA"
		
		
		SariskaMediaTransport.initializeSdk()
		
		setupLocalStream()
		
		let connection =  SariskaMediaTransport.JitsiConnection(token: token)
		
		connection.addEventListener(event: "CONNECTION_ESTABLISHED") {
			self.connection = connection
			self.createConference()
		}
		
		connection.addEventListener(event: "CONNECTION_FAILED") {
			print("CONNECTION_FAILED")
		}
		
		connection.addEventListener(event: "CONNECTION_DISCONNECTED") {
			print("CONNECTION_DISCONNECTED")
		}
		
		connection.connect()
	}
	
	func setupLocalStream() {
		var options:[String: Any] = [:]
		options["audio"] = true
		options["video"] = true
		options["resolution"] = 240
		
		SariskaMediaTransport.createLocalTracks(options: options) { tracks in
			DispatchQueue.main.async {
				self.localTracks = tracks
				for track in tracks {
					if (track.getType() == "video")  {
						let videoView =  track.render()
						self.attachVideo(videoView:  videoView, trackId: track.getId())
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
		
		conference.addEventListener(event: "CONFERENCE_JOINED") {
			for track in self.localTracks {
				conference.addTrack(track: track)
			}
		}
		
		conference.addEventListener(event: "TRACK_ADDED") { track in
			let track = track as! JitsiRemoteTrack
			DispatchQueue.main.async {
				if (track.getType() == "video") {
					let videoView =  track.render()
					self.attachVideo(videoView:  videoView, trackId: track.getId())
				}
			}
		}
		
		conference.addEventListener(event: "TRACK_REMOVED") { track in
			let track = track as! JitsiRemoteTrack
			DispatchQueue.main.async {
				self.removeVideo(trackId: track.getId())
			}
		}
		
		conference.addEventListener(event: "CONFERENCE_LEFT") {
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
