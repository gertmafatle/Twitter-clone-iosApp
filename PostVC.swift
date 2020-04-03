

import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // UI obj
    @IBOutlet var textTxt: UITextView!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var selectBtn: UIButton!
    @IBOutlet var pictureImg: UIImageView!
    @IBOutlet var postBtn: UIButton!
    
    // unique id of post
    var uuid = String()
    var imageSelected = false
    
    
    // first func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // round corners
        textTxt.layer.cornerRadius = textTxt.bounds.width / 50
        postBtn.layer.cornerRadius = postBtn.bounds.width / 20
        
        // colors
        selectBtn.setTitleColor(colorBrandBlue, forState: .Normal)
        postBtn.backgroundColor = colorBrandBlue
        countLbl.textColor = colorSmoothGray
        
        // disable auto scroll layout
        self.automaticallyAdjustsScrollViewInsets = false
        
        // disable button from the begining
        postBtn.enabled = false
        postBtn.alpha = 0.4
        
    }
    
    
    // entered some text in TextView
    func textViewDidChange(textView: UITextView) {
        
        // numb of characters in textView
        let chars = textView.text.characters.count
        
        // white spacing in text
        let spacing = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        
        // calculate string's length and convert to String
        countLbl.text = String(140 - chars)
        
        // if number of chars more than 140
        if chars > 140 {
            countLbl.textColor = colorSmoothRed
            postBtn.enabled = false
            postBtn.alpha = 0.4
            
        // if entered only spaces and new lines
        } else if textView.text.stringByTrimmingCharactersInSet(spacing).isEmpty {
            postBtn.enabled = false
            postBtn.alpha = 0.4
            
        // everything is correct
        } else {
            countLbl.textColor = colorSmoothGray
            postBtn.enabled = true
            postBtn.alpha = 1
        }
        
    }
    
    
    // touched screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // hide keyboard
        self.view.endEditing(false)
    }
    
    
    // clicked select picture button
    @IBAction func select_click(sender: AnyObject) {
        
        // calling picker for selecting iamge
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    
    // selected image in picker view
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        pictureImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // cast as a true to save image file in server
        if pictureImg.image == info[UIImagePickerControllerEditedImage] as? UIImage {
            imageSelected = true
        }
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
        
        
        // if file is not selected, it will not upload a file to server, because we did not declare a name file
        var filename = ""
        
        if imageSelected == true {
            filename = "post-\(uuid).jpg"
        }
        
        
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
        
    }
    
    
    // function sending requset to PHP to uplaod a file
    func uploadPost() {
        
        // shortcuts to data to be passed to php file
        let id = user!["id"] as! String
        uuid = NSUUID().UUIDString
        let text = textTxt.text.trunc(140) as String
        
        
        // url path to php file
        let url = NSURL(string: "http://localhost/Twitter/posts.php")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        // param to be passed to php file
        let param = [
            "id" : id,
            "uuid" : uuid,
            "text" : text
        ]
        
        // body
        let boundary = "Boundary-\(NSUUID().UUIDString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if picture is selected, compress it by half
        var imageData = NSData()
        
        if pictureImg.image != nil {
            imageData = UIImageJPEGRepresentation(pictureImg.image!, 0.5)!
        }
        
        // ... body
        request.HTTPBody = createBodyWithParams(param, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        // launch session
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) in
            
            // get main queu to communicate back to user
            dispatch_async(dispatch_get_main_queue(), { 
                
                
                if error == nil {
                    
                    do {
                        
                        // json containes $returnArray from php
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary
                        
                        // declare new var to store json inf
                        guard let parseJSON = json else {
                            print("Error while parsing")
                            return
                        }
                        
                        // get message from $returnArray["message"]
                        let message = parseJSON["message"]
                        
                        // if there is some message - post is made
                        if message != nil {
                            
                            // reset UI
                            self.textTxt.text = ""
                            self.countLbl.text = "140"
                            self.pictureImg.image = nil
                            self.postBtn.enabled = false
                            self.postBtn.alpha = 0.4
                            self.imageSelected = false
                            
                            // switch to another scene
                            self.tabBarController?.selectedIndex = 0
                            
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
    
    
    // clicked post button
    @IBAction func post_click(sender: AnyObject) {
        
        // if entered some text and text is less than 140 chars
        if !textTxt.text.isEmpty && textTxt.text.characters.count <= 140 {
            
            // call func to uplaod post
            uploadPost()
            
        }
        
    }
    
    
}




// Extension to stirng type of variables
extension String {
    
    // cut / trimm our string
    func trunc(length: Int, trailing: String? = "...") -> String {
        
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
        
    }
    
}



