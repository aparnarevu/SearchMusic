//
//  LyricsViewController.swift
//  Music
//
//  Created by Aparna Revu on 3/4/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AlamofireImage

class LyricsViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var lyricsTextView: UITextView!


    var selectedSong:Album?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Song"
        // Do any additional setup after loading the view.
        titleLabel.text = selectedSong?.name
        artistLabel.text = selectedSong?.artist
        albumNameLabel.text = selectedSong?.albumName

        self.previewView.requestDownloadImageForURL(imageUrlStr: (selectedSong?.previewUrl)!)
        
        downloadLyricsDetails()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadLyricsDetails()  {


        // 2
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // 3
        let expectedCharSet = CharacterSet.urlQueryAllowed
        let artist:String = (artistLabel.text?.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!)!

        let song:String = (titleLabel.text?.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!)!

        let urlStr = "http://lyrics.wikia.com/api.php?func=getSong&artist=\(artist)&song=\(song)&fmt=json"

        // 4
        let url = URL(string: urlStr)
        // 5
//        let dataTask = session.dataTask(with: url!, completionHandler: {
//            data, response, error in
//            // 6
//            DispatchQueue.main.async {
//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//            // 7
//            if let error = error {
//                print(error.localizedDescription)
//            } else if let httpResponse = response as? HTTPURLResponse {
//                if httpResponse.statusCode == 200 {
//                    print("Response:: ",data ?? "No data" )
//                    self.updateLyricsDetails(data)
//                }
//            }
//        })
//        // 8
//        dataTask.resume()
        
        Alamofire.request(url!).responseJSON { (responseData) -> Void in
            print("responseData:: ",responseData)
            if((responseData.result.value) != nil) {
                print("responseData.result.value :: ",responseData.result.value ?? "No data")

                let swiftyJsonVar = JSON(responseData.result.value!)
                print("swiftyJsonVar:: ",swiftyJsonVar)
                
            }
        }


    }
    
    func updateLyricsDetails(_ data: Data?) {
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
            print("parsedData:: ",parsedData )

        } catch let error as NSError {
            print(error)
        }

        

    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_".characters)
        return String(text.characters.filter {okayChars.contains($0) })
    }


}
