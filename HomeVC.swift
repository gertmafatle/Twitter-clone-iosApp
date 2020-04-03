
import UIKit

class HomeVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // UI obj
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var fullnameLbl: UILabel!
    @IBOutlet var emailLbl: UILabel!
    @IBOutlet var editBtn: UIButton!
    
    
    // UI obj related to Posts
    @IBOutlet var tableView: UITableView!
    var tweets = [AnyObject]()
    var images = [UIImage]()
    
    
    // first load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // get user details from user global var
        // shortcuts to store inf
        let username = user!["username"]?.uppercaseString
        let fullname = user!["fullname"] as? String
        let email = user!["email"] as? String
        let ava = user!["ava"] as? String
        
        // assign values to labels
        usernameLbl.text = username
        fullnameLbl.text = fullname
        emailLbl.text = email

        
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
        avaImg.layer.cornerRadius = avaImg.bounds.width / 20
        avaImg.clipsToBounds = true
        
        editBtn.setTitleColor(colorBrandBlue, forState: .Normal)
        
        self.navigationItem.title = username
        
    }
    
    
    // edit button clicked
    @IBAction func edit_click(sender: AnyObject) {
        
        // delcare sheet
        let sheet = UIAlertController(title: "Edit profile", message: nil, preferredStyle: .ActionSheet)
        
        // cancel button clicked
        let cancelBtn = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        // change picture clicked
        let pictureBtn = UIAlertAction(title: "Change picture", style: .Default) { (action:UIAlertAction) in
            self.selectAva()
        }
        
        // update profile clicked
        let editBtn = UIAlertAction(title: "Update profile", style: .Default) { (action:UIAlertAction) in
            
            // declare var to store editvc scene from main.stbrd
            let editvc = self.storyboard!.instantiateViewControllerWithIdentifier("EditVC") as! EditVC
            self.navigationController?.pushViewController(editvc, animated: true)
            
            // remove title from back button
            let backItem = UIBarButtonItem()
            backItem.title = ""
            self.navigationItem.backBarButtonItem = backItem
            
        }
        
        // add actions to sheet
        sheet.addAction(cancelBtn)
        sheet.addAction(pictureBtn)
        sheet.addAction(editBtn)
        
        // present action sheet
        self.presentViewController(sheet, animated: true, completion: nil)
        
    }
    
    // select profile picture
    func selectAva() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    // selected image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        avaImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // call func of uploading file to server
        uploadAva()
    }
    
    
    // custom body of HTTP request to upload image file
    func createBodyWithParams(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "ava.jpg"
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
        
    }
    
    
    // upload image to serve
    func uploadAva() {
        
        // shotcut id
        let id = user!["id"] as! String
        
        // url path to php file
        let url = NSURL(string: "http://localhost/Twitter/uploadAva.php")!
        
        // declare request to this file
        let request = NSMutableURLRequest(URL: url)
        
        // declare method of passign inf to this file
        request.HTTPMethod = "POST"
        
        // param to be sent in body of request
        let param = ["id" : id]
        
        // body
        let boundary = "Boundary-\(NSUUID().UUIDString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // compress image and assign to imageData var
        let imageData = UIImageJPEGRepresentation(avaImg.image!, 0.5)
        
        // if not compressed, return ... do not continue to code
        if imageData == nil {
            return
        }
        
        // ... body
        request.HTTPBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        
        
        // launc session
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
            // get main queue to communicate back to user
            dispatch_async(dispatch_get_main_queue(), { 
                
                if error == nil {
                    
                    do {
                        // json containes $returnArray from php
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get id from $returnArray["id"] - parseJSON["id"]
                        let id = parseJSON["id"]
                        
                        // successfully uploaded
                        if id != nil {
                            
                            // save user information we received from our host
                            NSUserDefaults.standardUserDefaults().setObject(parseJSON, forKey: "parseJSON")
                            user = NSUserDefaults.standardUserDefaults().valueForKey("parseJSON") as? NSDictionary
                        
                        // did not give back "id" value from server
                        } else {
                            
                            // get main queue to communicate back to user
                            dispatch_async(dispatch_get_main_queue(), {
                                let message = parseJSON["message"] as! String
                                appDelegate.infoView(message: message, color: colorSmoothRed)
                            })
                            
                        }
                    
                    // error while jsoning
                    } catch {
                        
                        // get main queue to communicate back to user
                        dispatch_async(dispatch_get_main_queue(), {
                            let message = error as! String
                            appDelegate.infoView(message: message, color: colorSmoothRed)
                        })

                    }
                    
                // error with php
                } else {

                    // get main queue to communicate back to user
                    dispatch_async(dispatch_get_main_queue(), {
                        let message = error!.localizedDescription
                        appDelegate.infoView(message: message, color: colorSmoothRed)
                    })

                }
                
                
            })
            
        }.resume()
        
        
    }
    
    
    // clicked logout button
    @IBAction func logout_click(sender: AnyObject) {
        
        // remove saved information
        NSUserDefaults.standardUserDefaults().removeObjectForKey("parseJSON")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // go to login page
        let loginvc = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
        self.presentViewController(loginvc, animated: true, completion: nil)
        
    }
    
    
    
    
    // TABLEVIEW
    // cell numb
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    
    // cell config
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostCell
        
        // shortcuts
        let tweet = tweets[indexPath.row]
        let image = images[indexPath.row]
        let username = tweet["username"] as? String
        let text = tweet["text"] as? String
        let date = tweet["date"] as! String
        
        // converting date string to date
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let newDate = dateFormater.dateFromString(date)!
        
        // declare settings
        let from = newDate
        let now = NSDate()
        let components : NSCalendarUnit = [.Second, .Minute, .Hour, .Day, .WeekOfMonth]
        let difference = NSCalendar.currentCalendar().components(components, fromDate: from, toDate: now, options: [])
        
        // calculate date
        if difference.second <= 0 {
            cell.dateLbl.text = "now"
        }
        if difference.second > 0 && difference.minute == 0 {
            cell.dateLbl.text = "\(difference.second)s." // 12s.
        }
        if difference.minute > 0 && difference.hour == 0 {
            cell.dateLbl.text = "\(difference.minute)m."
        }
        if difference.hour > 0 && difference.day == 0 {
            cell.dateLbl.text = "\(difference.hour)h."
        }
        if difference.day > 0 && difference.weekOfMonth == 0 {
            cell.dateLbl.text = "\(difference.day)d."
        }
        if difference.weekOfMonth > 0 {
            cell.dateLbl.text = "\(difference.weekOfMonth)w."
        }
        
        
        // assigning shortcuts to ui obj
        cell.usernameLbl.text = username
        cell.textLbl.text = text
        cell.pictureImg.image = image
        
        
        // get main queue to this block of code to communicate back
        dispatch_async(dispatch_get_main_queue()) {
            
            // if no image on the cell
            if image.size.width == 0 && image.size.height == 0 {
                // move left textLabel if no picture
                cell.textLbl.frame.origin.x = self.view.frame.size.width / 16 // 20
                cell.textLbl.frame.size.width = self.view.frame.size.width - self.view.frame.size.width / 8 // 40
                cell.textLbl.sizeToFit()
            }
        }
        
        return cell
        
    }
    
    
    // pre load func
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // call func of laoding posts
        loadPosts()
    }
    
    
    // func of loading posts from server
    func loadPosts() {
        
        // shortcut to id
        let id = user!["id"] as! String
        
        // accessing php file via url path
        let url = NSURL(string: "http://localhost/Twitter/posts.php")!
        
        // declare request to proceed php file
        let request = NSMutableURLRequest(URL: url)
        
        // declare method of passing information to php file
        request.HTTPMethod = "POST"
        
        // pass information to php file
        let body = "id=\(id)&text=&uuid="
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        // launch session
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
            // get main queue to operations inside of this block
            dispatch_async(dispatch_get_main_queue(), { 
                
                // no error of accessing php file
                if error == nil {
                    
                    do {
                        
                        // getting content of $returnArray variable of php file
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        
                        // clean up
                        self.tweets.removeAll(keepCapacity: false)
                        self.images.removeAll(keepCapacity: false)
                        self.tableView.reloadData()
                        
                        // declare new parseJSON to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new posts to store parseJSON
                        guard let posts = parseJSON["posts"] as? [AnyObject] else {
                            print("Error while parseJSONing")
                            return
                        }
                        
                        
                        // append all posts var's inf to tweets
                        self.tweets = posts
                        
                        
                        // getting images from url paths
                        for i in 0 ..< self.tweets.count {
                            
                            // path we are getting from $returnArray that assigned to parseJSON > to posts > tweets
                            let path = self.tweets[i]["path"] as? String
                            
                            // if we found path
                            if !path!.isEmpty {
                                let url = NSURL(string: path!)! // convert path str to url
                                let imageData = NSData(contentsOfURL: url) // get data via url and assigned imageData
                                let image = UIImage(data: imageData!)! // get image via data imageData
                                self.images.append(image) // append found image to [images] var
                            } else {
                                let image = UIImage() // if no path found, create a gab of type uiimage
                                self.images.append(image) // append gap to uiimage to avoid crash
                            }
                            
                        }
                        
                        
                        // reload tableView to show back information
                        self.tableView.reloadData()
                        
                        
                    } catch {
                    }
                    
                } else {
                }
                
            })
            
        }.resume()
        
    }
    
    
    // DELETE SECTION
    // allow edit cell
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // cell is swiped ...
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // we pressed delete button from swiped cell
        if editingStyle == .Delete {
            
            // send delete PHP request
            deletePost(indexPath)
        }
        
    }
    
    // delete post php request
    func deletePost(indexPath : NSIndexPath) {
        
        // shortcuts
        let tweet = tweets[indexPath.row]
        let uuid = tweet["uuid"] as! String
        let path = tweet["path"] as! String
        
        let url = NSURL(string: "http://localhost/Twitter/posts.php")! // access php file
        let request = NSMutableURLRequest(URL: url) // declare request to proceed url
        request.HTTPMethod = "POST" // declare method of passing inf to php
        let body = "uuid=\(uuid)&path=\(path)" // body - here we are passing info
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding) // supports all lang
        
        // launc php request
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
            // get main queue to this block of code to communicate back, in other case it will do all this in background
            dispatch_async(dispatch_get_main_queue(), { 
                
                if error == nil {
                    
                    do {
                        
                        // get back from server $returnArray of php file
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        
                        // secure way to declare new var to store (e.g. json) data
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // we are getting content of $returnArray under value "result" -> $returnArray["result"]
                        let result = parseJSON["result"]
                        // if result exists - deleted successfulyy
                        if result != nil {
                            self.tweets.removeAtIndex(indexPath.row) // remove related content from array
                            self.images.removeAtIndex(indexPath.row) // remove related picture
                            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic) // remove table cell
                            self.tableView.reloadData() // reload table to show updates
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
                
            })
            
        }.resume()
        
        
    }
    
    
    
    
}


// Creating protocol of appending string to var of type data
extension NSMutableData {

    func appendString(string : String) {
        
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
        
    }
    
}

