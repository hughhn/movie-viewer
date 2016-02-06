//
//  Utils.swift
//  MovieViewer
//
//  Created by Hugo Nguyen on 2/5/16.
//  Copyright © 2016 Hugo Nguyen. All rights reserved.
//

import UIKit

func fadeInImg(imageView: UIImageView, imageUrl: String) {
    let imageRequest = NSURLRequest(URL: NSURL(string: imageUrl)!)
    
    imageView.setImageWithURLRequest(
        imageRequest,
        placeholderImage: nil,
        success: { (imageRequest, imageResponse, image) -> Void in
            
            // imageResponse will be nil if the image is cached
            if imageResponse != nil {
                print("Image was NOT cached, fade in image")
                imageView.alpha = 0.0
                imageView.image = image
                UIView.animateWithDuration(1.0, animations: { () -> Void in
                    imageView.alpha = 1.0
                })
            } else {
                print("Image was cached so just update the image")
                imageView.image = image
            }
        },
        failure: { (imageRequest, imageResponse, error) -> Void in
            // do something for the failure condition
    })
}

func loadLowResThenHighResImg(imageView: UIImageView, smallImageUrl: String, largeImageUrl: String) {
    let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageUrl)!)
    let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageUrl)!)
    
    imageView.setImageWithURLRequest(
        smallImageRequest,
        placeholderImage: nil,
        success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
            
            // smallImageResponse will be nil if the smallImage is already available
            // in cache (might want to do something smarter in that case).
            imageView.alpha = 0.0
            imageView.image = smallImage;
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                
                imageView.alpha = 1.0
                
                }, completion: { (sucess) -> Void in
                    
                    // The AFNetworking ImageView Category only allows one request to be sent at a time
                    // per ImageView. This code must be in the completion block.
                    imageView.setImageWithURLRequest(
                        largeImageRequest,
                        placeholderImage: smallImage,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            
                            imageView.image = largeImage;
                            
                        },
                        failure: { (request, response, error) -> Void in
                            // do something for the failure condition of the large image request
                            // possibly setting the ImageView's image to a default image
                    })
            })
        },
        failure: { (request, response, error) -> Void in
            // do something for the failure condition
            // possibly try to get the large image
    })
}