//
//  SearchViewController.swift
//  Music
//
//  Created by Aparna Revu on 3/5/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import AlamofireImage

extension UIImageView {
    func requestDownloadImageForURL(imageUrlStr:String) {
        // the data was received and parsed to String
        let imageURL = URL(string: imageUrlStr)!
        
        Alamofire.request(imageURL, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                return
            }
            // Do stuff with your image
            DispatchQueue.main.async{
                self.image = image
            }

        }
    }
    
}

class SearchViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [Album]()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(SearchViewController.dismissKeyboard))
        return recognizer
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        dismissKeyboard()
        
        if !searchBar.text!.isEmpty {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            
            Alamofire.request("https://itunes.apple.com/search?term=\(searchTerm)").responseJSON { (responseData) -> Void in
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    
                    if let array: AnyObject = swiftyJsonVar["results"].arrayObject as AnyObject? {
                        for trackDictonary in array as! [AnyObject] {
                            if let trackDictonary = trackDictonary as? [String: AnyObject], let previewUrl = trackDictonary["artworkUrl100"] as? String {
                                // Parse the search result
                                let name = trackDictonary["trackName"] as? String
                                let artist = trackDictonary["artistName"] as? String
                                let albumName = trackDictonary["collectionName"] as? String
                                
                                self.searchResults.append(Album(name: name, artist: artist, albumName: albumName, previewUrl: previewUrl))
                            } else {
                                print("Not a dictionary")
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.setContentOffset(CGPoint.zero, animated: false)
                        }

                    } else {
                        print("Results key not found in dictionary")
                    }

                }
            }
        }
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

// MARK: UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as!AlbumCell
        
        let album = searchResults[indexPath.row]
        
        // Configure title and artist labels
        cell.titleLabel.text = album.name
        cell.artistLabel.text = album.artist
        cell.albumNameLabel.text = album.albumName
        cell.previewView.requestDownloadImageForURL(imageUrlStr: album.previewUrl!)
        cell.selectionStyle = UITableViewCellSelectionStyle.gray
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
}


// MARK: UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let album = searchResults[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let lyricsViewController = storyboard.instantiateViewController(withIdentifier: "LyricsViewController") as? LyricsViewController
        lyricsViewController?.selectedSong = album
        self.navigationController?.pushViewController(lyricsViewController!, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
