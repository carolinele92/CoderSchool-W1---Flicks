//
//  DetailsVC.swift
//  Flicks
//
//  Created by Caroline Le on 2/16/17.
//  Copyright © 2017 The UNIQ. All rights reserved.
//

import UIKit
import AFNetworking

class DetailsVC: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailsView: UIView!
    
    var movie: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

// --- Scroll view
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: detailsView.frame.origin.y + detailsView.frame.size.height)
        
        
        
// --- Image Url
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            posterImageView.setImageWith(NSURL(string: baseUrl + posterPath) as! URL)
        } else {
            posterImageView.image = nil
        }
        
        
// --- Detail Labels
            
        let title = movie["title"] as! String
        let date = movie["release_date"] as! String
        let rating = movie["vote_average"] as! Double
        let voteCount = movie["vote_count"] as! Int
        let overview = movie["overview"] as! String
        
        
        titleLabel.text = title
        dateLabel.text = date
        ratingLabel.text = String(rating)
        voteCountLabel.text = String(voteCount)
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        
    }



}
