//
//  ImageViewController.swift
//  Cassini
//
//  Created by Sriharshaa Sammeta on 2/20/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController,UIScrollViewDelegate
{
    var imageURL: NSURL?{
        didSet{
            image = nil
            if view.window != nil{
            fetchImage()
            }
        }
        
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    private func fetchImage(){
        
        if let url =  imageURL{
            spinner?.startAnimating()
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)){ () -> Void in
                let imageData = NSData(contentsOfURL: url)
                if url == self.imageURL{
                    dispatch_async(dispatch_get_main_queue()){
                        if imageData != nil{
                            self.image = UIImage(data: imageData!)
                        }else{
                            self.image = nil
                        }
                    }
                }

            }
        }
        
        
    }
    
    private var imageView = UIImageView()
    
    private var image: UIImage? {
        get{ return imageView.image }
        set{
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 2.0

        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        println("------layout-----")
        println("Zoom Scale :\(scrollView.zoomScale)")
        println("content size: \(scrollView.contentSize)")
        println("content offset: \(scrollView.contentOffset)")
        println("image frame: \(imageView.frame)")
//        imageView.frame.origin = CGPoint(x: 0, y: 0)
        var width  = imageView.bounds.width
        var height = imageView.bounds.height
        
        
        println("width: \(width)")
        println("height: \(height)")
        
        var screenWidth = view.bounds.width
        var screenHeight = view.bounds.height
        
        println("sceenWidth: \(screenWidth)")
        println("screenHeight: \(screenHeight)")
        
        
        var zoomWidth = screenWidth / width
        var zoomHeight = screenHeight / height

        println("zoomWidth: \(zoomWidth)")
        println("zoomHeight: \(zoomHeight)")
        
        
        var zoomScale:CGFloat = scrollView.maximumZoomScale
        if zoomWidth > zoomHeight{
            if (zoomWidth <= scrollView.maximumZoomScale && zoomWidth >= scrollView.minimumZoomScale) {
                zoomScale = zoomWidth
            }else{
                if zoomWidth < scrollView.minimumZoomScale{
                    zoomScale = scrollView.minimumZoomScale
                }else if zoomWidth > scrollView.maximumZoomScale{
                    if zoomWidth.isFinite{
                        scrollView.maximumZoomScale = zoomWidth
                    }
                    zoomScale = scrollView.maximumZoomScale
                }
            }
        }else{
            if (zoomHeight <= scrollView.maximumZoomScale && zoomHeight >= scrollView.minimumZoomScale) {
                zoomScale = zoomHeight
            }else{
                if zoomHeight < scrollView.minimumZoomScale{
                    zoomScale = scrollView.minimumZoomScale
                }else if zoomHeight > scrollView.maximumZoomScale{
                    if zoomHeight.isFinite{
                        scrollView.maximumZoomScale = zoomHeight
                    }
                        zoomScale = scrollView.maximumZoomScale
                }
            }
        }

    
        scrollView.contentSize = CGSize(width: imageView.frame.size.width * zoomScale, height: imageView.frame.size.height * zoomScale)
        
        
//        imageView.frame.origin = CGPoint(x: 0, y: 0)
//        scrollView.contentOffset = CGPoint(x: 0, y: 0)
//        scrollView.zoomToRect(CGRect(origin: CGPointZero, size: CGSize(width: view.bounds.size.width , height:  view.bounds.size.height)), animated: true)
//        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
//        }, completion: nil)
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.scrollView.zoomScale = zoomScale
            self.scrollView.contentOffset = CGPointZero
            self.imageView.frame.origin = CGPointZero
        }, completion: nil)
        
//        scrollView.contentSize = imageView.frame.size
        println("finaly image view size: \(imageView.frame)")
        println("final zoom scale: \(scrollView.zoomScale)")
        println("final content size: \(scrollView.contentSize)")
        println("final content offset: \(scrollView.contentOffset)")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
       return imageView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil{
            fetchImage()
        }
    }
}
