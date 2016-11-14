//
//  WebViewController.swift
//  Smashtag
//
//  Created by Sriharsha Sammeta on 03/04/15.
//  Copyright (c) 2015 Sriharshaa Sammeta. All rights reserved.
//

import UIKit

class WebViewController: UIViewController,UIWebViewDelegate {

    var url: String? = "http://www.apple.com"{
        didSet{
            if url == nil {
                url = "http://www.apple.com"
            }
        }
    }
    
    private lazy var backButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Rewind, target: self.webView, action: "goBack")
    private lazy var forwardButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self.webView, action: "goForward")
    private lazy var refreshButtonItem:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self.webView, action: "reload")
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    // MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.delegate = self
        navigationItem.rightBarButtonItems?.append(self.refreshButtonItem)
        navigationItem.rightBarButtonItems?.append(self.forwardButtonItem)
        navigationItem.rightBarButtonItems?.append(self.backButtonItem)
        if let url = NSURL(string: url!){
            webView.loadRequest(NSURLRequest(URL: url))
        }

        // Do any additional setup after loading the view.
    }
    

    @IBAction func openURLIn(sender: UIBarButtonItem) {
        
        if let URL = NSURL(string: url!){
            
            var alert = UIAlertController(title: url, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "Open in Safari", style: UIAlertActionStyle.Default, handler: {
                (action:UIAlertAction!) in
                UIApplication.sharedApplication().openURL(URL)
                return
            }))
            alert.addAction(UIAlertAction(title: "Copy", style: UIAlertActionStyle.Default, handler: {
                (action:UIAlertAction!) in
                UIPasteboard.generalPasteboard().string = self.url!
                return
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action:UIAlertAction!) in
                return
            }))
            presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func enableOrDisableButton(){
        backButtonItem.enabled = webView.canGoBack
        forwardButtonItem.enabled = webView.canGoForward
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        if error.code != -999 {
            println("error code: \(error.code)")
        var alert = UIAlertController(title: "OOPs error :( ", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:nil))
        presentViewController(alert, animated: true, completion: nil)
        spinner.stopAnimating()
        enableOrDisableButton()
        }
    }
    func webViewDidStartLoad(webView: UIWebView) {
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        spinner.stopAnimating()
        enableOrDisableButton()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
