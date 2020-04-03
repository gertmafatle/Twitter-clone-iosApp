
import UIKit

class GuestVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variable that stores guest information passed via segue
    var guest = NSDictionary()
    
    
    // UI obj
    @IBOutlet var avaImg: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var fullnameLbl: UILabel!
    @IBOutlet var emailLbl: UILabel!
    
    
    // UI obj related to Posts
    @IBOutlet var tableView: UITableView!
    var tweets = [AnyObject]()
    var images = [UIImage]()
    
    
    // first load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get user details from user global var
        // shortcuts to store inf
        let username = guest["username"] as? String
        let fullname = guest["fullname"] as? String
        let email = guest["email"] as? String
        let ava = guest["ava"] as? String
        
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
        
        self.navigationItem.title = username?.uppercaseString
        
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
        let id = guest["id"]!
        
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

