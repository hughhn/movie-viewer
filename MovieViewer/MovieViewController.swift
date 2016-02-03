//
//  MovieViewController.swift
//  MovieViewer
//
//  Created by Hieu Nguyen on 2/2/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    
    func successFetchCb(responseDictionary: NSDictionary) -> Void {
        self.movies = responseDictionary["results"] as! [NSDictionary]
        self.tableView.reloadData()
    }
    
    func errorFetchCb(error: NSError?) -> Void {
        if error != nil {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view.
        
        fetchMovies(
            successFetchCb,
            errorCallback: errorFetchCb
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWithURL(imageUrl!)
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.posterView.image = nil
        }
        
        cell.titleLable.text = title
        cell.overviewLabel.text = overview
        
        return cell
    }
    
    func fetchMovies(successCallback: (NSDictionary) -> Void, errorCallback: ((NSError?) -> Void)?) {
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, responseOrNil, errorOrNil) in
                if let requestError = errorOrNil {
                    errorCallback?(requestError)
                } else {
                    if let data = dataOrNil {
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                            data, options:[]) as? NSDictionary {
                                NSLog("response: \(responseDictionary)")
                                successCallback(responseDictionary)
                        }
                    }
                }
        });
        task.resume()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
    }

}
