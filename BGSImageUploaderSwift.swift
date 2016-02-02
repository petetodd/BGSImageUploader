//
//  BGSImageUploaderSwift.swift
//  BrightAssetManager
//
//  Created by Peter Todd Air on 01/02/2016.
//  Copyright © 2016 Bright Green Star. All rights reserved.
//

import UIKit


protocol BGSImageUploaderSwiftDelegate
{
    func uploadURL(strURL : String!)
}

class BGSImageUploaderSwift: NSObject {
    var delegate:BGSImageUploaderSwiftDelegate! = nil

    
    // MARK: Upload URL for Company

    func retrieveUploadUrlCompany(){
        let service = apiServiceCompany()
        
        let gaeCompletionHandler: (GTLServiceTicket?, AnyObject?, NSError?) -> Void = { (data, response, error) in
            let callback :GTLCompanyEndpointCallbackResult = response as! GTLCompanyEndpointCallbackResult
            let returnCode = callback.JSONValueForKey("redcode").intValue
            let strData = callback.JSONValueForKey("data") as! String
            
            
            if (returnCode == 1)
            {
               self.delegate.uploadURL(strData)
            }else{
               self.delegate.uploadURL(nil)
            }
        }

        let query = GTLQueryCompanyEndpoint.queryForCreateUploadUrl()
        // Execute the query given the defined completion handler
        service.executeQuery(query, completionHandler: gaeCompletionHandler)
    }
    
    // MARK: Upload URL for User

    func retrieveUploadUrlUser(){
        let service = apiServiceCompany()
        
        let gaeCompletionHandler: (GTLServiceTicket?, AnyObject?, NSError?) -> Void = { (data, response, error) in
            let callback :GTLUserEndpointCallbackResult = response as! GTLUserEndpointCallbackResult
            let returnCode = callback.JSONValueForKey("redcode").intValue
            let strData = callback.JSONValueForKey("data") as! String
            
            if (returnCode == 1)
            {
                self.delegate.uploadURL(strData)
            }else{
                self.delegate.uploadURL(nil)
            }
        }
        
        let query = GTLQueryUserEndpoint.queryForCreateUploadUrl()
        // Execute the query given the defined completion handler
        service.executeQuery(query, completionHandler: gaeCompletionHandler)
    }
    
    // MARK: Upload Image
    func uploadImage(image : UIImage, toURL : NSURL){
        let prefs = NSUserDefaults.standardUserDefaults()
        let strToken = prefs.objectForKey("userToken")
        
        let dataImage = UIImageJPEGRepresentation(image, 1.0)
        
        let request = NSMutableURLRequest()
        request.URL = toURL
        request.HTTPMethod = "POST"
        // Boundary is used to seperate the parts of multipart form.  Can be any text
        let boundary = "---XXXXXXX---"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let fileName = "profileImage"
        
        let body = NSMutableData()
        //--------------for upload token----------------------//
        body.appendData(("--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(("Content-Disposition: form-data; name=\"token\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(("\(strToken!)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        body.appendData(("\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName).jpg\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)

        
        body.appendData(("Content-Type: image/jpg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(dataImage!)
        body.appendData(("\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        request.HTTPBody = body

        let connection = NSURLConnection.init(request: request, delegate: self)
        
        if connection == nil{
            print("UploadImage did not connect")
            return
        }

        
    }
    
    
    
    // MARK: - Setup GAE Service
   
    
    func apiServiceCompany() -> GTLServiceCompanyEndpoint{
        struct Service{
            static var gaeService = GTLServiceCompanyEndpoint()
        }
        return Service.gaeService
    }

    
    func apiServiceUser() -> GTLServiceCompanyEndpoint{
        struct Service{
            static var gaeService = GTLServiceCompanyEndpoint()
        }
        return Service.gaeService
    }
    
    // MARK: - Utility Image Resize
    


}
