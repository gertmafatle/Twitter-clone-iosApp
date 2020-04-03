
import UIKit

class ResetVC: UIViewController {
    
    // UI obj
    @IBOutlet var emailTxt: UITextField!
    
    
    // first func
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // reset button clicked
    @IBAction func reset_click(sender: AnyObject) {
        
        // if not text entered
        if emailTxt.text!.isEmpty {
            
            // red placeholder
            emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName:UIColor.redColor()])
        
        // if text is enetered
        } else {
            
            // remove keyboard
            self.view.endEditing(true)
            
            // shortcut ref to text in email TextField
            let email = emailTxt.text!.lowercaseString
            
            // send mysql / php / hosting request
            
            // url path to php file
            let url = NSURL(string: "http://localhost/Twitter/resetPassword.php")!
            
            // request to send to this file
            let request = NSMutableURLRequest(URL: url)
            
            // method of passing inf to this file
            request.HTTPMethod = "POST"
            
            // body to be appended to url. It passes inf to this file
            let body = "email=\(email)"
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            // proces reqeust
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) in

                if error == nil {
                    
                    // give main queue to UI to communicate back
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                            
                            guard let parseJSON = json else {
                                print("Error while parsing")
                                return
                            }
                            
                            let email = parseJSON["email"]
                            
                            // successfully reset
                            if email != nil {
                                
                                // get main queue to communicate back to user
                                dispatch_async(dispatch_get_main_queue(), {
                                    let message = parseJSON["message"] as! String
                                    appDelegate.infoView(message: message, color: colorLightGreen)
                                    
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



