//
//  MoviesVC.swift
//  Flicks
//
//  Created by Caroline Le on 2/16/17.
//  Copyright © 2017 The UNIQ. All rights reserved.
//

import UIKit
import Foundation
import AFNetworking
import MBProgressHUD


class MoviesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var networkErrorLabel: UILabel!

    
    
    var movies: [NSDictionary]?
    var selectedImageUrl = ""
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    var endpoint = "now_playing"
    var request: URLRequest!
    var image: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        networkErrorLabel.isHidden = true

        
// --- Pull to Refresh
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        
        
// --- Get Movie API Database 
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        
            request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Display Progress HUD before making the request
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask =
            session.dataTask(with: request!,
                             completionHandler: { (dataOrNil, response, error) in
                                
                                // Hide HUD after network request comes back
                                MBProgressHUD.hide(for: self.view, animated: true)
                                
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        print("response: \(responseDictionary)")
                                        
                                        self.movies = responseDictionary["results"] as? [NSDictionary]
                                        self.tableView.reloadData()
                                        
                                
                                        
                                    }
                                }
                               
                                if error != nil {
                                    self.networkErrorLabel.text = "Network Error"
                                    self.networkErrorLabel.isHidden = false
                                    
                                }
                                
            })
        task.resume()
     
    }
    
    
// --- Prepare segue - passing selected movie's API details to DetailsVC
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Cell Selection
        let cell = sender as! MovieCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![(indexPath!.row)]
        
        print ("prepare for segue is called")
        
        let detailVC = segue.destination as! DetailsVC
        detailVC.movie = movie
        

   
        
    }
 



// --- Refresh Controll Action

    func refreshControlAction (_ refreshControl: UIRefreshControl) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionTask = session.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in

        
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
        task.resume()
    }

}



// --- TableView

extension MoviesVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath) as! MovieCell

        let movie = movies?[indexPath.row]
        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        
        cell.titleLabel?.text = title
        cell.overviewLabel?.text = overview
        cell.overviewLabel.sizeToFit()
        
        
        if let posterPath = movie?["poster_path"] as? String {
            let imageUrl = (baseUrl + posterPath) as String
            cell.posterImageView?.setImageWith(NSURL(string: imageUrl) as! URL)
            
        } else {
            cell.posterImageView.image = nil
        }
        
        return cell
        
    }
  
}






