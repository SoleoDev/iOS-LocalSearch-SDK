/**
 
 -file: APIConnector.swift
 -author: Created by Dan Sweetman and Victor Jimenez.
 -copyright: Copyright © 2016 SOLEO Communications. All rights reserved.
 -description: APIConnector Class
 -version : 1.0.3
 
 */
import Foundation
import Async
import SwiftyJSON


/// Type Alias that will return a JSON, a NSError and a APIConnector Response object
public typealias ServiceResponse = (JSON?, NSError?, APIConnector_Response?) -> Void

/** 
 -class : APIConnector
 -helps : SoleoAPI
*/
public class APIConnector {
    
    //MARK: Fields
        /// static SHARE instance of a APIConnector. This way we save memory.
    public static let sharedInstance = APIConnector()
    
        /// NSURLSession that is a shared Session to save memory.
    let session = NSURLSession.sharedSession()
    
    //MARK: HTTP - GET functions
    
    //Takes the  GET request and makes a connection to a URL and returns
    
    /**
        Main Object to do a HTTP request.
        This object will connect and get the response form that Request
     
     - parameter URL:          URL parameter to get description
     - parameter method:       HTTP method - GET / POST
     - parameter onCompletion: Service Response object that has the return information
     */
    func connect(URL: String, method: String, onCompletion: ServiceResponse){
        //print("APIConector: \(URL)")
        makeHTTPSRequest(URL,methodToUse: method, onCompletion: { (json, err, response) -> Void in
            onCompletion(json, err, response)
        })
    }

    
    //Tries and makes a request and tries to get json data
    /**
     Description
     
     - parameter path:         String base URL to use for the call
     - parameter methodToUse:  HTTP method to use: Get or POST
     - parameter onCompletion: ServiceResponse type. Format as JSON, NSErrr, APIConnector_Response.
     */
    private func makeHTTPSRequest(path: String, methodToUse: String, onCompletion: ServiceResponse){
        let request = NSMutableURLRequest(URL: NSURL(string: path)!)
        request.HTTPMethod = methodToUse
        
        
        let task = session.dataTaskWithRequest(request,completionHandler:{ (data, response, error) in
            
            guard let data = data else {
                onCompletion(nil, error,nil)
                return
            }
                //TODO: Check Later for thread execution problems
                //WHY IS THIS IN THE FOREGROUND... This should go to the background
                Async.main{
                    
                    let responseResult = response as! NSHTTPURLResponse
                    var digestedResponse = APIConnector_Response(response: responseResult.statusCode, Description: "")
                    
                    
                    switch(digestedResponse.response)
                    {
                        //Response OK for get. Returning listings
                    case 200:
                        digestedResponse.Description = "OK"
                        break
                        
                        //Response OK for a POST. Might or might NOT return something. DON"T WAIT
                    case 201:
                        digestedResponse.Description = "POST OK"
                        break
                        
                        //Error with Query
                    case 400:
                        digestedResponse.Description = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                        
                        //Error invalid endpoint or timeout
                    case 404:
                        digestedResponse.Description = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                        
                        //Search not done with GET
                    case 405:
                        digestedResponse.Description = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                        
                        //Invalid Header
                    case 406:
                        digestedResponse.Description = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                        
                        //Resource not there. Something is wrong with the Headers or API version requested
                    case 410:
                        digestedResponse.Description = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                        
                        //SYSTEM DOWN... PANIC NOW!!!
                    case 500:
                        digestedResponse.Description = String(data: data, encoding: NSUTF8StringEncoding) ?? ""
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                        
                        
                    default:
                        digestedResponse.Description = "Unexpected response found, please check the response manually."
                        onCompletion(nil,error,digestedResponse)
                        return
                        
                    }
                    
                    print(#function, #line , #file, "going to send onCompletion")
                    onCompletion(JSON(data:data),nil,digestedResponse)
                    
                    
                }
        } )
        
        task.resume()
    }
    
    //MARK: CleanUp functions
    
    /**
     Clean up and Close session.
     
     - discussion:
        Ensure the system closes the Session. This is since the NSURLSession keeps a STRONG variable.
        WILL CAUSE memory leaks if not closed
     
     */
    public func closeSession(){
        self.session.finishTasksAndInvalidate()
    }

}

/**
 *  API Connector Resposne Struct. This is a digested response object for easier interpretation
    - response : Int HTTP response code
    - Description : String consumable description
 */
public struct APIConnector_Response{
    
   public var response : Int
    
   public var Description : String
}
