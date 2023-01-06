import UIKit
import sariska;
import OSLog;
import Foundation;


struct Film: Codable {
  let title: String
  let episodeId: Int
  
  enum CodingKeys: String, CodingKey {
    case title
    case episodeId = "episode_id"
  }
  
  init(title: String,
       episodeId: Int) {
    self.title = title
    self.episodeId = episodeId
  }
}

struct FilmSummary: Codable {
  let count: Int?
  let results: [Film]?
}

class ViewController: UIViewController {
	
    var connection: Connection? = nil
	var conference: Conference? = nil
	var stackView: UIStackView? = nil
    private let domainUrlString = "https://swapi.co/api/"
    var films: [Film] = []
	var localTracks: [JitsiLocalTrack] = []
    var token: String? = nil
    
    let tokens = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRkMzc3ZDRjNTBiMDY1ODRmMGY4MDJhYmFiNTIyMjg5ODJiMTk2YzAzNzYwNzE4NDhiNWJlNTczN2JiMWYwYTUiLCJ0eXAiOiJKV1QifQ.eyJjb250ZXh0Ijp7InVzZXIiOnsiaWQiOiIxMjM0NSIsIm5hbWUiOiJKb2huIFNtaXRoIiwiZW1haWwiOiJleGFtcGxlQGVtYWlsLmNvbSIsIm1vZGVyYXRvciI6dHJ1ZX0sImdyb3VwIjoiMjAyIn0sInN1YiI6InF3ZnNkNTdwcTlkeGFrcXF1cTZzZXEiLCJyb29tIjoiKiIsImlhdCI6MTY3MjkzNDk0NSwibmJmIjoxNjcyOTM0OTQ1LCJpc3MiOiJzYXJpc2thIiwiYXVkIjoibWVkaWFfbWVzc2FnaW5nX2NvLWJyb3dzaW5nIiwiZXhwIjoxNjczMDIxMzQ1fQ.iIuCLng0bA8ILS_ajl2TCVPYTqAvsty66EBYc7Y_M6ZadrddsEsOvsopJtQlyK-Ikcx_Op2XLCpnoRhmzx03KYc_P0x95nKIU25xzFVpPwZ12dPZQsaMYKC1XOCzVQJSsPhOY3NmB0zFu_79LtSp0bLw-wbNw9JrCjGhcmRC-gRwQI9QatJkAj8ApW7S28Akm7WpF9tXWRcSj3klGZL8V00ExOLfdk4uRDvL3ER6-41KVX5Mf2AWFGiRh7vyqUOWH6pRnslPTVV8dWkmoxL1hr1lQPQVLW72jou2nIpJRyfBB-hAA7qTfvjhosWv4QhTazkUp2lLyS-SCVuGd04RWA"
    

	
	lazy var videoStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 20.0
		stackView.distribution = .fill
		stackView.alignment = .fill
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
    func fetchFilms(completionHandler: @escaping ([Film]) -> Void) {
        
        let url = URL(string: domainUrlString + "films/")!

            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
              if let error = error {
                print("Error with fetching films: \(error)")
                return
              }
              
              guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                  print("Error with the response, unexpected status code: \(String(describing: response))")
                return
              }

              if let data = data,
                let filmSummary = try? JSONDecoder().decode(FilmSummary.self, from: data) {
                completionHandler(filmSummary.results ?? [])
              }
            })
        
            task.resume()
    }
    
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
                                            os_log("Inside the first callback")
                                            self?.createConference()
                                        })
                                        
                                        self?.connection?.addEventListener("CONNECTION_FAILED", callback: {
                                            os_log("Inside the second callback")
                                        })
                                        
                                        self?.connection?.addEventListener("CONNECTION_DISCONNECTED", callback: {
                                            os_log("Inside the third callback")
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
        os_log("We are in setup local stream")
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
