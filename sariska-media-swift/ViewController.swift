import UIKit
import sariska;
import OSLog;
import Foundation;

class ViewController: UIViewController {
	
    var connection: Connection? = nil
	var conference: Conference? = nil
	var stackView: UIStackView? = nil
	var localTracks: [JitsiLocalTrack] = []
    var token: String? = nil

    
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
    
        func getToken(){
            DispatchQueue.main.async {
                let tokenReq = tokenRequest()
                
                tokenReq.getToken{[weak self] result in
                                    switch result{
                                    case .failure(let error):
                                        print(error)
                                    case .success(let token2):
                                        SariskaMediaTransport.initializeSdk()
                                        
                                        self?.setupLocalStream()
                                        
                                        self?.connection = SariskaMediaTransport.jitsiConnection(token2, roomName: "dipak", isNightly: false)
                                        
                                        self?.connection?.addEventListener("CONNECTION_ESTABLISHED", callback: {
                                            self?.createConference()
                                        })
                                        
                                        self?.connection?.addEventListener("CONNECTION_FAILED", callback: {
                                        })
                                        
                                        self?.connection?.addEventListener("CONNECTION_DISCONNECTED", callback: {
                                        })
                                        
                                        self?.connection?.connect()
                                    }
                    }
            }
        }
        
        getToken()
	}
	
	func setupLocalStream() {
		var options:[String: Any] = [:]
		options["audio"] = true
		options["video"] = true
		options["resolution"] = 240
        SariskaMediaTransport.createLocalTracks(options) { tracks in
                    DispatchQueue.main.async {
                        self.localTracks = tracks as! [JitsiLocalTrack]
                        for track in self.localTracks {
                            if (track.getType() == "video")  {
                                let videoView =  track.render()
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
