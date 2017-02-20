//
//  MoviesVC.swift
//  Flicks
//
//  Created by Caroline Le on 2/16/17.
//  Copyright © 2017 The UNIQ. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class MoviesVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    var endpoint = "now_playing"
    var request: URLRequest!
    var filteredMovies: [NSDictionary]? // additional var, represents rows of data that match search text
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.networkErrorLabel.isHidden = true
        hideTableView()

        
        
        
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
                                        self.filteredMovies = self.movies
                                        self.tableView.reloadData()
                                        self.collectionView.reloadData()
                                        
                                        
                                    }
                                }
                               
                                if error != nil {
                                    self.networkErrorLabel.text = "No Internet Connection"
                                    self.networkErrorLabel.isHidden = false
                                    
                                }
                                
            })
        task.resume()
     
        
        
// --- Pull to Refresh
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        collectionView.insertSubview(refreshControl, at: 0)
        
        
    }

                            // --- End of ViewDidLoad ---
    

// --- Switch to/from TableView CollectionView
    
    func hideTableView() {
        UIView.transition(from: tableView, to: collectionView, duration: 1.0, options: .showHideTransitionViews, completion: nil)
        navigationItem.rightBarButtonItem?.image = UIImage(named: "list_view")
    }
    
    
    func hideColectionView() {
        UIView.transition(from: collectionView, to: tableView, duration: 1.0, options: .showHideTransitionViews, completion: nil)
        navigationItem.rightBarButtonItem?.image = UIImage(named: "grid_view")
    }

   
    @IBAction func viewStyleButtonTapped(_ sender: Any) {
   
        if collectionView.isHidden {
            hideTableView()
        } else {
            hideColectionView()
        }
    
    }
    

    
    
// --- Prepare segue - passing selected movie's API details to DetailsVC
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Cell Selection
        
            // For Table View
        if tableView.isHidden == false {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            let movie = filteredMovies![(indexPath!.row)]
            
            print ("prepare for segue is called")
            
            let detailVC = segue.destination as! DetailsVC
            detailVC.movie = movie
            
            // For Collection View
        } else {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPath(for: cell)
            let movie = filteredMovies![(indexPath!.row)]
            
            print ("prepare for segue is called")
            
            let detailVC = segue.destination as! DetailsVC
            detailVC.movie = movie
            
        }
       
    }
 

    

// --- Refresh Controll Action

    func refreshControlAction (_ refreshControl: UIRefreshControl) {
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionTask = session.dataTask(with: request) {(data: Data?, response: URLResponse?, error: Error?) in

        
            self.tableView.reloadData()
            self.collectionView.reloadData()
            refreshControl.endRefreshing()
        }
        task.resume()
    }

}





// --- TableView config.

extension MoviesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "moviesCell", for: indexPath) as! MovieCell

        let movie = filteredMovies?[indexPath.row]
        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        let date = movie?["release_date"] as! String
        
        cell.titleLabel?.text = title
        cell.dateLabel?.text = date
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



// --- Collection View cofig.

extension MoviesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moviesGridCell", for: indexPath) as! CollectionViewCell
        
        let movie = filteredMovies?[indexPath.row]
        
        if let posterPath = movie?["poster_path"] as? String {
            let imageUrl = (baseUrl + posterPath) as String
            cell.posterImageView?.setImageWith(NSURL(string: imageUrl) as! URL)
            
            
        } else {
            cell.posterImageView.image = nil
        }
        
        
        return cell
    }
    
    
}


// --- Search bar

extension MoviesVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredMovies = searchText.isEmpty ? movies : movies!.filter { (movie: NSDictionary) -> Bool in
            
            let title = movie["title"] as! String
            // If title matches the searchText, return true to include it
            return title.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
                    
        }
        
        tableView.reloadData()
        collectionView.reloadData()
        
    }
 
}









