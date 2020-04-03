
import UIKit

class RegisterVC: UIViewController {
    
    // UI objects
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var firstnameTxt: UITextField!
    @IBOutlet var lastnameTxt: UITextField!
    
    
    // first func
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // register button clicked
    @IBAction func register_click(sender: AnyObject) {
        
        // if no text
        if usernameTxt.text!.isEmpty || passwordTxt.text!.isEmpty || emailTxt.text!.isEmpty || firstnameTxt.text!.isEmpty || lastnameTxt.text!.isEmpty {
            
            //red placeholders
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            firstnameTxt.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            lastnameTxt.attributedPlaceholder = NSAttributedString(string: "surname", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            
        // if text is entered
        } else {
            
            // remove keyboard
            self.view.endEditing(true)
            
            // url to php file
            let url = NSURL(string: "http://localhost/Twitter/register.php")!
            
            // request to this file
            let request = NSMutableURLRequest(URL: url)
            
            // method to pass data to this file (e.g. via POST)
            request.HTTPMethod = "POST"
            
            // body to be appended to url
            let body = "username=\(usernameTxt.text!.lowercaseString)&password=\(passwordTxt.text!)&email=\(emailTxt.text!)&fullname=\(firstnameTxt.text!)%20\(lastnameTxt.text!)"
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            // proceed request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) in
                
                if error == nil {
                    
                    // get main queue in code process to communicate back to UI
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        do {
                            // get json result
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                            
                            // assign json to new var parseJSON in guard/secured way
                            guard let parseJSON = json else {
                                print("Error while parsing")
                                return
                            }
                            
                            // get id from parseJSON dictionary
                            let id = parseJSON["id"]
                            
                            // successfully registered
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
                        
                    })
                    
                // if unable to proceed request
                } else {

                    // get main queue to communicate back to user
                    dispatch_async(dispatch_get_main_queue(), {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })
                    return

                }
                
            // launch prepared session
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



