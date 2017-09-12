//
//  WebViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var url:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loading.startAnimating()
        webView.delegate = self
        
        let webURL = URL(string: url)!
        let request = URLRequest(url:webURL)
        webView.loadRequest(request)
    }

    @IBAction func Back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func runJS(_ sender: Any) {
        webView.stringByEvaluatingJavaScript(from: "alert('Rodando JavaScript na WebView')")
    }
}

extension WebViewController: UIWebViewDelegate{
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loading.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let absoluteString = request.url!.absoluteString
        if absoluteString.range(of: "itau") != nil{
            
            let alert = UIAlertController(title: "Erro", message: "É proibido Itaú", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                print("o usuário apertou o OK")
            })
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert,animated: true,completion: nil)
            
            return false
        }
        return true
    }
}
