
import UIKit


// global variable refered to appDelegate to be able to call it from any class / file.swift
let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

// colors
let colorSmoothRed = UIColor(red: 255/255, green: 50/255, blue: 75/255, alpha: 1)
let colorLightGreen = UIColor(red: 30/255, green: 244/255, blue: 125/255, alpha: 1)
let colorSmoothGray = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
let colorBrandBlue = UIColor(red: 45 / 255, green: 213 / 255, blue: 255 / 255, alpha: 1)

// sizes
let fontSize12 = UIScreen.mainScreen().bounds.width / 31

// stores all information about current user
var user : NSDictionary?


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // image to be animated
    let backgroundImg = UIImageView()
    
    // boolean to check is erroView is currently showing or not
    var infoViewIsShowing = false
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // creating imageView to store background image "mainbg.jpg"
        backgroundImg.frame = CGRectMake(0, 0, self.window!.bounds.height * 1.688, self.window!.bounds.height)
        backgroundImg.image = UIImage(named: "mainbg.jpg")
        self.window!.addSubview(backgroundImg)
        moveBgLeft()
        
        
        // load content in user var
        user = NSUserDefaults.standardUserDefaults().valueForKey("parseJSON") as? NSDictionary

        // if user is once logged in / register, keep him logged in
        if user != nil {
            
            let id = user!["id"] as? String
            if id != nil {
                login()
            }
            
        }
        
        
        return true
    }
    
    
    // function to animate bg to move left
    func moveBgLeft() {
        
        // begin animation
        UIView.animateWithDuration(45, animations: {
            
            // change hor origin
            self.backgroundImg.frame.origin.x = -self.backgroundImg.bounds.width + self.window!.bounds.width
        
        }) { (finished:Bool) in
            
            // if animation finished, execute func moveBgRight
            if finished {
            
                self.moveBgRight()
                
            }
            
        }
        
    }
    
    // function to animate bg to move right
    func moveBgRight() {
        
        // begin animation
        UIView.animateWithDuration(45, animations: { 
            
            // moving back hor origin of bg to its native value
            self.backgroundImg.frame.origin.x = 0
            
        }) { (finished:Bool) in
            
            // if animation finished, execute func moveBgRight
            if finished {
                
                self.moveBgLeft()
                
            }
            
        }
        
    }
    
    
    // infoView view on top
    func infoView(message message:String, color:UIColor) {
        
        // if infoView is not showing ...
        if infoViewIsShowing == false {
            
            // cast as infoView is currently showing
            infoViewIsShowing = true
            
            
            // infoView - red background
            let infoView_Height = self.window!.bounds.height / 14.2
            let infoView_Y = 0 - infoView_Height
            
            let infoView = UIView(frame: CGRectMake(0, infoView_Y, self.window!.bounds.width, infoView_Height))
            infoView.backgroundColor = color
            self.window!.addSubview(infoView)
            
            
            // infoView - label to show info text
            let infoLabel_Width = infoView.bounds.width
            let infoLabel_Height = infoView.bounds.height + UIApplication.sharedApplication().statusBarFrame.height / 2
            
            let infoLabel = UILabel()
            infoLabel.frame.size.width = infoLabel_Width
            infoLabel.frame.size.height = infoLabel_Height
            infoLabel.numberOfLines = 0
            
            infoLabel.text = message
            infoLabel.font = UIFont(name: "HelveticaNeue", size: fontSize12)
            infoLabel.textColor = .whiteColor()
            infoLabel.textAlignment = .Center
            
            infoView.addSubview(infoLabel)
            
            
            // animate info view
            UIView.animateWithDuration(0.2, animations: { 
                
                // move down infoView
                infoView.frame.origin.y = 0
                
                // if animation did finish
                }, completion: { (finished:Bool) in
                    
                    // if it is true
                    if finished {
                        
                        UIView.animateWithDuration(0.1, delay: 3, options: .CurveLinear, animations: {
                        
                            // move up infoView
                            infoView.frame.origin.y = infoView_Y
                        
                        // if finished all animations
                        }, completion: { (finished:Bool) in
                          
                            if finished {
                                infoView.removeFromSuperview()
                                infoLabel.removeFromSuperview()
                                self.infoViewIsShowing = false
                            }
                            
                        })
                        
                    }
                    
            })
            
            
        }
        
    }
    
    
    // func to pass to home page ro to tabBar
    func login() {
        
        // refer to our Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // store our tabBar Object from Main.storyboard in tabBar var
        let taBar = storyboard.instantiateViewControllerWithIdentifier("tabBar")
        
        // present tabBar that is storing in tabBar var
        window?.rootViewController = taBar
        
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

