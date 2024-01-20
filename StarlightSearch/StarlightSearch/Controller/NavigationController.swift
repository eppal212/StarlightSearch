//
//  NavigationController.swift
//  StarlightSearch
//
//  Created by CUDO on 27/05/2019.
//  Copyright © 2019 OBeris. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override var shouldAutorotate: Bool {
        get {
            let topShouldAutorotate =  topViewController?.shouldAutorotate ?? true
            return topShouldAutorotate
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        get {
            let topSupportedInterfaceOrientations =  topViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.portrait
            return topSupportedInterfaceOrientations
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            return UIInterfaceOrientation.portrait
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            let topPrefersStatusBarHidden =  topViewController?.prefersStatusBarHidden ?? true
            return topPrefersStatusBarHidden
        }
    }
}
