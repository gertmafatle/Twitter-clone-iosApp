

import UIKit

class LoginVC: UIViewController {

    // UI obj
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    
    // first func
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // clicked login button
    @IBAction func login_click(sender: AnyObject) {
        
        // if no text entered
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty {
          
            // red placeholders
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName:UIColor.redColor()])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName:UIColor.redColor()])
            
        // text is entered
        } else {
            
            // remove keyboard
            self.view.endEditing(true)
            
            // shortcuts
            let username = usernameTxt.text!.lowercaseString
            let password = passwordTxt.text!
            
            // send request to mysql db
            // url to access our php file
            let url = NSURL(string: "http://localhost/Twitter/login.php")!
            
            // request url
            let request = NSMutableURLRequest(URL: url)
            
            // method to pass data POST - cause it is secured
            request.HTTPMethod = "POST"
            
            // body gonna be appended to url
            let body = "username=\(username)&password=\(password)"
            
            // append body to our request that gonna be sent
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            // launch session
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) in
                
                // no error
                if error == nil {
                    
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // remove keyboard
                        
                        
                        let id = parseJSON["id"] as? String
                        
                        // successfully logged in
                        if id != nil {
                            
                            // save user information we received from our host
                            NSUserDefaults.standardUserDefaults().setObject(parseJSON, forKey: "parseJSON")
                            user = NSUserDefaults.standardUserDefaults().valueForKey("parseJSON") as? NSDictionary
                            
                            // go to tabbar / home page
                            dispatch_async(dispatch_get_main_queue(), { 
                                appDelegate.login()
                            })
                        
                        // error
                        } else {
                            
                            // get main queue to communicate back to user
                            dispatch_async(dispatch_get_main_queue(), {
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: colorSmoothRed)
                            })
                            return
                            
                        }
                        
                    } catch {
                        
                        // get main queue to communicate back to user
                        dispatch_async(dispatch_get_main_queue(), {
                            let message = String(error)
                            appDelegate.infoView(message: message, color: colorSmoothRed)
                        })
                        return

                    }
                    
                } else {
                    
                    // get main queue to communicate back to user
                    dispatch_async(dispatch_get_main_queue(), {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })
                    return
                    
                }
                
            }).resume()
            
        }
     
    }
    
    
    // white status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    // touched screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    
    
}



