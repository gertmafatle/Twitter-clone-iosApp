
import UIKit

class UsersVC: UITableViewController, UISearchBarDelegate {

    // UI obj
    @IBOutlet var searchBar: UISearchBar!
    
    // array of objects to store all users' information
    var users = [AnyObject]()
    var avas = [UIImage]()
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // search bar customization
        searchBar.barTintColor = .whiteColor() // search bar color
        searchBar.tintColor = colorBrandBlue // elements of searchbar
        searchBar.showsCancelButton = false
        
        // call func to find users
        doSearch("")
    }
    
    
    // once entered a text in searchbar
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // search php request
        doSearch(searchBar.text!)
    }
    
    
    // did begin editing of text in search bar
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    
    // clicked cancel butotn of searchbar
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        // reset UI
        searchBar.endEditing(false) // reomove keyboard
        searchBar.showsCancelButton = false // remove cancel button
        searchBar.text = ""
        
        // clean up
        users.removeAll(keepCapacity: false)
        avas.removeAll(keepCapacity: false)
        tableView.reloadData()
        
        doSearch("")
    }
    
    
    
    // cell numb
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    
    // cell config
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UsersCell
        
        // get one by one user related inf from users var
        let user = users[indexPath.row]
        let ava = avas[indexPath.row]
        
        // shortcuts
        let username = user["username"] as? String
        let fullname = user["fullname"] as? String
        
        // refer str to cell obj
        cell.usernameLbl.text = username
        cell.fullnameLbl.text = fullname
        cell.avaImg.image = ava

        return cell
    }
    
    
    // search / retrieve users
    func doSearch(word : String) {
        
        // shortucs
        let word = searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let username = user!["username"] as! String
        
        let url = NSURL(string: "http://localhost/Twitter/users.php")!  // url path to users.php file
        let request = NSMutableURLRequest(URL: url) // create request to work with users.php file
        request.HTTPMethod = "POST" // method of passing inf to users.php
        let body = "word=\(word)&username=\(username)" // body that passes inf to users.php
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding) // convert str to utf8 str - supports all languages
        
        // launch session
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
            // getting main queue of proceeding inf to communicate back, in another way it will do it in background
            // and user will no see changes :)
            dispatch_async(dispatch_get_main_queue(), { 
                
                if error == nil {
                    
                    do {
                        // declare json var to store $returnArray inf we got users.php
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        
                        // clean up
                        self.users.removeAll(keepCapacity: false)
                        self.avas.removeAll(keepCapacity: false)
                        self.tableView.reloadData()
                        
                        // delcare new secure var to store json
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // declare new secure vat to store $returnArray["users"]
                        guard let parseUSERS = parseJSON["users"] else {
                            print(parseJSON["message"])
                            return
                        }
                        
                        // append $returnArray["users"] to self.users var
                        self.users = parseUSERS as! [AnyObject]
                        
                        
                        // for i=0; i < users.count; i++
                        for i in 0 ..< self.users.count {
                            
                            // getting path to ava file of user
                            let ava = self.users[i]["ava"] as? String
                            
                            // if path exists -> laod ava via path
                            if !ava!.isEmpty {
                                let url = NSURL(string: ava!)! // convert parth of str to url
                                let imageData = NSData(contentsOfURL: url) // get data via url and assing to imageData
                                let image = UIImage(data: imageData!)! // convert data of image via data imageData to UIImage
                                self.avas.append(image)
                                
                            // else use placeholder for ava
                            } else {
                                let image = UIImage(named: "ava.jpg")
                                self.avas.append(image!)
                            }
                            
                        }
                        
                        
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
    
    
    // proceeding segues that have been made in main.storyboard to another view controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        // we check did cell exists or did we pressed a cell
        if let cell = sender as? UITableViewCell {
            
            // define index to later on pass exact guest user related inf
            let index = tableView.indexPathForCell(cell)!.row
            
            // if segue is guest ...
            if segue.identifier == "guest" {
                
                // call guestvc to access guest var
                let guestvc = segue.destinationViewController as! GuestVC
                
                // assign guest user inf to guest var
                guestvc.guest = users[index] as! NSDictionary
                
                // new back button
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                
            }
            
        }
        
    }
    


}

