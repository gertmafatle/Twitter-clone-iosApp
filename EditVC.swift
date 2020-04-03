
import UIKit

class EditVC: UIViewController, UITextFieldDelegate {

    // UI obj
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var surnameTxt: UITextField!
    @IBOutlet var fullnameLbl: UILabel!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var saveBtn: UIButton!
    
    
    // first default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // shortcuts
        let username = user!["username"] as? String
        let fullname = user!["fullname"] as? String
        
        let fullnameArray = fullname!.characters.split {$0 == " "}.map(String.init) // include 'Fistname Lastname' as array of seperated elements
        let firstname = fullnameArray[0]
        let lastname = fullnameArray[1]
        
        let email = user!["email"] as? String
        let ava = user!["ava"] as? String
        
        
        // assign shortcuts to obj
        navigationItem.title = "PROFILE"
        usernameTxt.text = username
        nameTxt.text = firstname
        surnameTxt.text = lastname
        emailTxt.text = email
        fullnameLbl.text = "\(nameTxt.text!) \(surnameTxt.text!)"
        
        // get user profile picture
        if ava != "" {
            
            // url path to image
            let imageURL = NSURL(string: ava!)!
            
            // communicate back user as main queue
            dispatch_async(dispatch_get_main_queue(), {
                
                // get data from image url
                let imageData = NSData(contentsOfURL: imageURL)
                
                // if data is not nill assign it to ava.Img
                if imageData != nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.avaImg.image = UIImage(data: imageData!)
                    })
                }
            })
            
        }

        // round corners
        avaImg.layer.cornerRadius = avaImg.bounds.width / 2
        avaImg.clipsToBounds = true
        saveBtn.layer.cornerRadius = saveBtn.bounds.width / 4.5
        
        // color
        saveBtn.backgroundColor = colorBrandBlue
        
        // disable button initially
        saveBtn.enabled = false
        saveBtn.alpha = 0.4
        
        
        // delegating textFields
        usernameTxt.delegate = self
        nameTxt.delegate = self
        surnameTxt.delegate = self
        emailTxt.delegate = self
        
        // add target to textfield as execution of function
        nameTxt.addTarget(self, action: #selector(EditVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        surnameTxt.addTarget(self, action: #selector(EditVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        usernameTxt.addTarget(self, action: #selector(EditVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        emailTxt.addTarget(self, action: #selector(EditVC.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    
    // calling once entered any chars in name / surname textfields
    func textFieldDidChange(textField : UITextView) {
        fullnameLbl.text = "\(nameTxt.text!) \(surnameTxt.text!)"
        
        // if textfields are empty - disable save button
        if usernameTxt.text!.isEmpty || nameTxt.text!.isEmpty || surnameTxt.text!.isEmpty || emailTxt.text!.isEmpty {
            
            saveBtn.enabled = false
            saveBtn.alpha = 0.4
            
            // enable button if changed and there is some text
        } else {
            
            saveBtn.enabled = true
            saveBtn.alpha = 1
            
        }
    }
    
    
    // clicked save button
    @IBAction func save_clicked(sender: AnyObject) {
        
        // if no text
        if usernameTxt.text!.isEmpty || emailTxt.text!.isEmpty || nameTxt.text!.isEmpty || surnameTxt.text!.isEmpty {
            
            //red placeholders
            usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName: colorSmoothRed])
            emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            nameTxt.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSForegroundColorAttributeName: colorSmoothRed])
            surnameTxt.attributedPlaceholder = NSAttributedString(string: "surname", attributes: [NSForegroundColorAttributeName: colorSmoothRed])
            
        // if text is entered
        } else {
            
            // remove keyboard
            self.view.endEditing(true)
            
            // shortcuts
            let username = usernameTxt.text!.lowercaseString
            let fullname = fullnameLbl.text!
            let email = emailTxt.text!.lowercaseString
            let id = user!["id"]!
            
            // preparing request to best
            let url = NSURL(string: "http://localhost/Twitter/updateUser.php")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            let body = "username=\(username)&fullname=\(fullname)&email=\(email)&id=\(id)"
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
            
            // sending request
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data:NSData?, reponse:NSURLResponse?, error:NSError?) in
                
                // no error
                if error == nil {
                    
                    // get main queue to communicate back to user
                    dispatch_async(dispatch_get_main_queue(), { 
                        
                        do {
                            // declare json var to store $returnArray from php file
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                            
                            // assign json to new secure var, prevent from crashes
                            guard let parseJSON = json else {
                                print("Error while parsing")
                                return
                            }
                            
                            // get if from parseJSON dictionary
                            let id = parseJSON["id"]
                            
                            
                            // successfully updated
                            if id != nil {
                                
                                // save user information we received from our host
                                NSUserDefaults.standardUserDefaults().setObject(parseJSON, forKey: "parseJSON")
                                user = NSUserDefaults.standardUserDefaults().valueForKey("parseJSON") as? NSDictionary
                                
                                // go to tabbar / home page
                                dispatch_async(dispatch_get_main_queue(), {
                                    appDelegate.login()
                                })
                                
                            }
                            
                            
                        // error while jsoning
                        } catch {
                            print("Caught an error: \(error)")
                        }
                        
                    })
                    
                    
                // error with php request
                } else {
                    print("Error: \(error)")
                }
                
            }).resume()
            
            
        }
    }
    
    
}










