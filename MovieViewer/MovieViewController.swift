//
//  MovieViewController.swift
//  MovieViewer
//
//  Created by Hieu Nguyen on 2/2/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorMsgView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var filteredMovies: [NSDictionary]?
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredMovies = movies
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredMovies = movies
        } else {
            // The user has entered text into the search box
            // Poor man's way of filtering
            filteredMovies?.removeAll()
            if let movies = movies {
                for movie in movies {
                    if let title = movie["title"] as? String {
                        if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                            filteredMovies?.append(movie)
                        }
                    }
                }
            }
        }
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func showError() {
        self.errorMsgView.hidden = false
        
        UIView.animateWithDuration(1.0, delay: 2.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                self.errorMsgView.alpha = 0.0
            }, completion: { finished in
                self.errorMsgView.alpha = 1.0
                self.errorMsgView.hidden = true
        })
        
    }
    
    func fetchMovies(refreshControl: UIRefreshControl?) {
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let requestError = errorOrNil {
                    self.showError()
                    print(requestError)
                } else {
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                //NSLog("response: \(responseDictionary)")
                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                self.filteredMovies = self.movies
                                self.tableView.reloadData()
                                self.collectionView.reloadData()
                        }
                    }
                }
                if let refreshControl = refreshControl {
                    refreshControl.endRefreshing()
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchMovies(refreshControl)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        let screenRect = UIScreen.mainScreen().bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        tableView.frame = CGRectMake(0, tableView.frame.origin.y, screenWidth, screenHeight - tableView.frame.origin.y)
        collectionView.frame = CGRectMake(0, collectionView.frame.origin.y, screenWidth, screenHeight - collectionView.frame.origin.y)
        tableView.hidden = false
        collectionView.hidden = true
        //collectionView.contentInset = UIEdgeInsetsMake(0.0, 10.0, 50.0, 10.0)
        
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        segmentedControl.frame = CGRectMake(0, segmentedControl.frame.origin.y, screenWidth, segmentedControl.frame.size.height)
        
        errorMsgView.frame = CGRectMake(0, errorMsgView.frame.origin.y, screenWidth, errorMsgView.frame.size.height)
        errorMsgView.hidden = true
        
        // Do any additional setup after loading the view.
        
        fetchMovies(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTabChange(sender: AnyObject) {
        if segmentedControl.selectedSegmentIndex == 0 {
            tableView.hidden = false
            collectionView.hidden = true
        } else {
            tableView.hidden = true
            collectionView.hidden = false
        }
    }
    
    func getNumMovies() -> Int {
        if let filteredMovies = filteredMovies {
            return filteredMovies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        // No color when the user selects cell
        cell.selectionStyle = .None
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        // Use a red color when the user selects the cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = backgroundView
    }
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell

    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = backgroundView
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getNumMovies()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as! MovieCollectionCell
        
        let movie = filteredMovies![indexPath.row]
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = "http://image.tmdb.org/t/p/w500" + posterPath
            fadeInImg(cell.posterView, imageUrl: imageUrl)
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getNumMovies()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = "http://image.tmdb.org/t/p/w500" + posterPath
            fadeInImg(cell.posterView, imageUrl: imageUrl)
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        cell.titleLable.text = title
        cell.overviewLabel.text = overview
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        var index: NSIndexPath? = nil
        if let cell = sender as? UITableViewCell {
            index = tableView.indexPathForCell(cell)
        } else if let cell = sender as? UICollectionViewCell {
            index = collectionView.indexPathForCell(cell)
        }
        
        var movie = filteredMovies![0]
        if let index = index {
            movie = filteredMovies![index.row]
        }
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
    }

}
