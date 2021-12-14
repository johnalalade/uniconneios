//
//  ViewController.swift
//  Uniconne
//
//  Created by uniconne on 09/08/2021.
//

import UIKit
import WebKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    //var token: String?
    var locationManager: CLLocationManager?
    
    let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero,
                                configuration: configuration)
        
        return webView
    }()
    
    var refController: UIRefreshControl = UIRefreshControl()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestAlwaysAuthorization()
        
        view.addSubview(webView)
        
        guard let url = URL(string: "https://www.uniconne.com/home") else {
            return
        }
        webView.load(URLRequest(url: url))
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        DispatchQueue.main.asyncAfter(deadline: .now()+30){
       let token = appDelegate.fcmTokenn
        
            let jsStyle = """
                        javascript:(function() {
                        localStorage.setItem('regToken', '\(token))')
                        })()
                    """
            let jsScript = WKUserScript(source: jsStyle, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
            self.webView.configuration.userContentController.addUserScript(jsScript)
            print("Tokenn ooo: \(token)")
            
        }
        
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated  {
                if let url = navigationAction.request.url,
                    let host = url.host, !host.hasPrefix("www.uniconne.com"),
                    UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    print(url)
                    print("Redirected to browser. No need to open it locally")
                    decisionHandler(.cancel)
                } else {
                    print("Open it locally")
                    decisionHandler(.allow)
                }
            } else {
                print("not a user click")
                decisionHandler(.allow)
            }
        }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }

}

