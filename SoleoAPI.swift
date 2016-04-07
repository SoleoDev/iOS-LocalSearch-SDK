/**
 
 -file: SoleoAPI.swift
 -author: Created by Victor Jimenez.
 -copyright: Copyright © 2016 SOLEO Communications. All rights reserved.
 -description: Soleo Local Search API main object
 -version : 1.0.1
 
 */
import Foundation
import CoreLocation
import Contacts
import SwiftyJSON

/// API Response with a Business and a NSError object
public typealias APIResponse = ([Business]?, NSError?) -> Void

/// API Callback Response with a new Business and a NSError.
public typealias APICallBackResponse = (Business?, NSError?) -> Void


//MARK: EXTENSION to String class
///Used to remove the leading & trailing whitespace and to also change the whitspace inside the string to be URL compliant spaces
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.stringByReplacingOccurrencesOfString(string, withString: replacement, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func changeToURL() -> String {
        return self.replace(" ", replacement: "%20").replace(",", replacement: "%2C")
    }
}



/// Soleo Local Search API main object
/// For more information go to: developer.soleo.com
/**
 -class : SoleoAPI
 -helper : APIConnector, Business types
 */
public class SoleoAPI
{
        /// Soleo Local Search Rest API key
    public let apiKey = ""
// TODO: Place your APIKEY HERE
//    let apiKey = <#Your APIKEY#>
    
    
//        let URL_EXAMPLE = "https://api.soleo.com/businesses/?APIKey=YOURAPIKEY&ANI=5856414300&ReferenceID=T7360&Keyword=food&Latitude=43.038304720296516&Longitude=-77.4576846095582&Sort=value_distance"
    
    //MARK: Fields
    
    //Class only
    private var apiURL : String
    

    ///Requiered ONLY 1 of the following: Keyword, Name or Category
    public var toSearch_keyword : String
    public var toSearch_Name : String
    public var toSearch_Category : String
    
    // If Location is provded, City,Sate,PostalCode is not requiered.
    public var location : CLLocation
    public var toSearch_City : String
    public var toSearch_State : String
    public var toSearch_PostalCode : Int
    
    public var toSearch_radious : String
    
    //Extras
    
    public var OpenOnly : Bool = false
    public var sortType : Business_Sort_Type = Business_Sort_Type.both
    public var requestType : Business_Request_Type = Business_Request_Type.ALL

    
    //Return Values
    public var businessList = [Business]()
    public var foundOrganics : Int = 0
    public var foundSponsors : Int = 0
    public var totalFound : Int = 0
    public var resultsValidUntil : NSDate = NSDate()
    
    public var dataError : NSError?
    public var SearchRequest : Search_type?
    
    /**
     Initialization with Parameter
     
     Initialize the Soleo Local API object with the following Parameters:
     
     - parameter location: CLLocation object with the location to perform a search.
     - parameter name:     Name of Business to search for. Can be blank.
     - parameter category: Category to search for. Can be blank.
     - parameter keyword:  Keyword that can be used for Search. Can be blank.
     - parameter city:     City to search in.
     - parameter state:    State to search in.
     - parameter postal:   Postal Code to search in.
     
     - discussion:
     Note that NOT ALL name,category and keyworkd be empty at the same time.
     If Name or Category is use, keyword is useless.
     Keyworkd can be used alone as it will be used a Name and Category.
     If Business name is used a category will greatly increase sucesfull finding of the correct business.
     
     - returns: SoleoAPI - A new SoleoAPI object ready to use.
     */
    public init(location : CLLocation, name : String, category : String, keyword: String, city: String, state: String, postal: Int)
    {
        self.location = location
        self.toSearch_Name = name
        self.toSearch_Category = category
        self.toSearch_keyword = keyword
        self.toSearch_City = city
        self.toSearch_PostalCode = postal
        self.toSearch_State = state
        self.toSearch_radious = ""

        apiURL = ""
        
    }
    
    /**
     Empty Initializer.
     Mainly used to get a empty object to run Previously saved searches
     
     - returns: SoleoAPI - A new SoleoAPI object ready to use.
     */
    public init()
    {
        self.location = CLLocation(latitude: 0.0, longitude: 0.0)
        self.toSearch_Name = ""
        self.toSearch_Category = ""
        self.toSearch_keyword = ""
        self.toSearch_City = ""
        self.toSearch_PostalCode = 00000
        self.toSearch_State = ""
        self.toSearch_radious = ""

        apiURL = ""

    }
    
    
    //MARK: API  Search Functions
    
    // Calls into APIConnector to make a connection to mashery and will return a JSON list.
    //Use for Initial Search.
    
    /**
     Main Method to get the Business Listing Objects
     Calls into APIConnector to make a connection to API and will return a JSON list.
     
     - parameter processCompleter: API Response with the Business Objects Array and a NSError
     */
    public func getData(processCompleter: APIResponse){
            self.createURL();
            
            APIConnector.sharedInstance.connect(self.apiURL, method: "GET"){ (json, error, response) -> Void in
                
                
                if(error != nil)
                {
                    print("Got deep error",error!)
                }
                
                if(response != nil)
                {
                    print("we got a response: CODE \(response?.response)  and description\(response?.Description)")
//                    self.dataError = error
                    
                    if(response?.response == 200)
                    {
                        self.makeList(json!)
                        print("done making list")
                        
//                        print("Returing List of \(self.businessList.count)")
//                        print("Found \(self.foundOrganics) organic and \(self.foundSponsors)")
                        //TODO: CHECK THIS ERROR. WE GOT A 200 BUT 0 responses.
                        if ( self.businessList.count == 0)
                        {
                            let error2 : NSError
                            if (self.foundOrganics == 0 && self.foundSponsors == 0)
                            {
                             error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: ["info":NSLocalizedString("ErrorGettingaMatch", comment: "error")])
                                
                            }
                            else{
                                error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: nil)
                            }
                            
                            self.dataError = error2
                            processCompleter(nil,error2)
                            return

                        }
                        
                        processCompleter(self.businessList, nil)
                        
                    }
                    else if(response?.response >= 400)
                    {
                        let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: nil)
                        self.dataError = error2
                        processCompleter(nil,error2)
                    }

                }
                
                APIConnector.sharedInstance.closeSession()
               
                
        }
        
    }
    
    // Calls into APIConnector to make a connection to mashery and will return a JSON list.
    //Use to lunch a previous search
    
    /**
     Calls into APIConnector to make a connection to mashery and will return a JSON list.
     
     - parameter previousSearch:   Search_Type Previous Search
     - parameter processCompleter: API Response with the Business Objects Array and a NSError
     */
    public func getDataFromPrevoiusSearch(previousSearch: Search_type ,processCompleter: APIResponse){
        self.createURL();
        
        APIConnector.sharedInstance.connect(previousSearch.search_query, method: "GET"){ (json, error, response) -> Void in
            
            if(response != nil)
            {
                //                    print("we got a response: CODE \(response?.response)  and description\(response?.Description)")
                //                    self.dataError = error
                
                if(response?.response == 200)
                {
                    self.makeList(json!)
                    print("done making list")
                    
                    //                        print("Returing List of \(self.businessList.count)")
                    //                        print("Found \(self.foundOrganics) organic and \(self.foundSponsors)")
                    processCompleter(self.businessList, nil)
                    
                }
                else if(response?.response >= 400)
                {
                    let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: nil)
                    self.dataError = error2
                    processCompleter(nil,error2)
                }
                
            }
            
            APIConnector.sharedInstance.closeSession()
            
            
        }
        
    }

    
    //MARK: API POST functions
    // Calls into APIConnector to make a connection to mashery and will return 1 data for the requested object
    //Use for Initial Search.
    public func getCallBacksData(businessToGet: Business , action : Business_Callback_type , processCompleter: APICallBackResponse){
        
        let index = businessToGet.callbacks.indexOf{$0.rel == action.rawValue}
        
        if(businessToGet.presented)
        {
            
        }
        
        APIConnector.sharedInstance.connect(businessToGet.callbacks[index!].referenceURL, method: businessToGet.callbacks[index!].callbackMethod){ (json, error, response) -> Void in
            
            if(response != nil)
            {
                
                print("we got a response: CODE \(response?.response)  and description\(response?.Description)")
                //                    self.dataError = error
                
                if(response?.response == 200 || response?.response == 201)
                {
                    
//                    print(json!)
                    if action == Business_Callback_type.select ||
                        action == Business_Callback_type.selected_with_details ||
                        action == Business_Callback_type.getNumbers ||
                        action == Business_Callback_type.present
                    {
                        
                        let newBusiness = self.updateBusiness(json!, toUpdate: businessToGet, actionMade: action)
//                        print ("After update: ", newBusiness)
                        
                        processCompleter(newBusiness, nil)
                    }
                    
                }
                else if(response?.response >= 400)
                {
                    let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: nil)
                    self.dataError = error2
                    processCompleter(nil,error2)
                }
                
            }
            
            APIConnector.sharedInstance.closeSession()
            
            
        }
        
    }
    
    //MARK: Support Functions
    
    //will make a list that can be passed to the other view controllers
    private func makeList(jsonn:JSON){ //-> [Business]

        print("Making List")
        
        if(jsonn["summary"] != nil)
        {
            var i = 0
            
            //Getting Summary Information.
            foundSponsors = jsonn["summary"]["resultsCount"]["sponsored"].int! as Int
            foundOrganics = jsonn["summary"]["resultsCount"]["organic"].int! as Int
            totalFound = foundSponsors + foundOrganics
            let dateFormater = NSDateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            while (jsonn["businesses"][i]["name"] != nil){
                var bus = Business()
                
                //Basic Information.
                bus.name = jsonn["businesses"][i]["name"].string! as String
                bus.address = jsonn["businesses"][i]["address"].string! as String
                bus.city = jsonn["businesses"][i]["city"].string! as String
                bus.state = jsonn["businesses"][i]["state"].string! as String
                bus.zip = jsonn["businesses"][i]["zip"].string! as String
                bus.type =  Business_Type(rawValue:jsonn["businesses"][i]["type"].string! as String)!
                
                //Monetization or Cost build up.
                if(bus.type == Business_Type.Sponsored){
                    
                    bus.monetization = Business_Monetization(
                        completion_action: Business_Action_Type(rawValue: jsonn["businesses"][i]["monetizationCritera"]["action"].string! as String)!,
                        criteria: Int(jsonn["businesses"][i]["monetizationCritera"]["criteria"].string!)!,
                        value: Double(jsonn["businesses"][i]["monetizationCritera"]["value"].string!)!,
                        validUntil: dateFormater.dateFromString((jsonn["businesses"][i]["monetizationCritera"]["validUntil"].string! as String))!)
                    
                }
                else
                {
                    
                    bus.cost = Business_Cost_to_developer(
                        action: Business_Action_Type(rawValue: jsonn["businesses"][i]["costCritera"]["action"].string! as String)!,
                        value: Double(jsonn["businesses"][i]["costCritera"]["value"].string!)!,
                        validUntil: dateFormater.dateFromString((jsonn["businesses"][i]["costCritera"]["validUntil"].string! as String))!)
                    
                }
                
                //Getting Callbacks.
                bus.callbacks.append(Business_Callback_Definition(
                    rel: jsonn["businesses"][i]["_links"][0]["rel"].string! as String,
                    referenceURL: jsonn["businesses"][i]["_links"][0]["href"].string! as String,
                    callbackMethod: jsonn["businesses"][i]["_links"][0]["method"].string! as String))
                
                //Seting Up location
                bus.Location = CLLocation(latitude: Double(jsonn["businesses"][i]["latitude"].string! ) ?? 0.0 ,
                    longitude: Double(jsonn["businesses"][i]["longitude"].string!) ?? 0.0)
                
                
                //Inserting Items to list.
                businessList.insert(bus, atIndex: i)
                i += 1

            
                
            }
        
        SearchRequest = Search_type(name: "Search for \(toSearch_keyword) in \(toSearch_City), \(toSearch_State) \(toSearch_PostalCode)",
                query: apiURL, timeS: dateFormater.dateFromString((jsonn["summary"]["validUntil"].string! as String))!, location: location, fav: false)
            
        }
        //print(__FUNCTION__, __LINE__, "\(businessList)")
        //return businessList
    }
    
    //Creates a URL that will get passed to getData()
    private func createURL(){
        //This APIKEY will need to be replace by your API key.
        
        
        var apiName = ""
        var apiKeyword = ""
        var apiCategory = ""
        
        let apiLat = "Latitude=\(location.coordinate.latitude)&"
        let apiLong = "Longitude=\(location.coordinate.longitude)&"
        //Default Changed for mapping
        var apiRadius = "Radius=10&"
        
        var apiCity = ""
        var apiState = ""
        var apiPostalCode = ""
        
        //Needed to return CALLED back number
        let apiANI = "ANI=5856414300&"
        
        //EXTRA PARAMETERS
        let api_openOnly = "OpenOnly=\(OpenOnly ? "Yes" : "No")"
        let api_sort = "Sort=\(sortType.rawValue)&"
        let api_request_type = "Type=\(requestType.rawValue)&"
        
        //TODO: EXPOSE THIS TOO TO THE OUTSIDE WORLD... LATER
        //This can be changed to anythign you want to be. Its 1 number per API which in our case is session
        //VJ 02-08 SOMETHING HAPPEND WITH THIS 2 PARAMETERS IN THE SYSTEM...
        //SET THEM TO BLANK for now.
        let deviceID = UIDevice().identifierForVendor?.UUIDString as String!
        let apiReferecenID = "ReferenceID=\(deviceID)&"
        
        //ID to track the activity of that device
        let sourceID = UIDevice().name
        let apiSourceID = "SourceID=\(sourceID)&"
        

        
        
        if (!toSearch_Name.isEmpty){
            let trim = toSearch_Name.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            trim.changeToURL()
            if trim != ""{
                apiName = "Name="+trim+"&"
            }
        }
        
        if (!toSearch_keyword.isEmpty){
            let trim = toSearch_keyword.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            trim.changeToURL()
            if trim != ""{
                apiKeyword = "Keyword="+trim+"&"
            }
        }
        
        if (!toSearch_Category.isEmpty){
            let trim = toSearch_Category.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            trim.changeToURL()
            if trim != ""{
                apiCategory = "Category="+trim+"&"
            }
        }
        
        if (!toSearch_City.isEmpty){
            let trim = toSearch_City.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            trim.changeToURL()
            if trim != ""{
                apiCity = "City="+trim+"&"
//                apiLat.removeAll()
//                apiLong.removeAll()
            }
        }
        
        if (!toSearch_State.isEmpty){
            apiState = "State="+toSearch_State+"&"
//            apiLat.removeAll()
//            apiLong.removeAll()
        }
        
        if (toSearch_PostalCode != 0){
            
            let formatter = NSNumberFormatter()
            formatter.minimumIntegerDigits = 5
            formatter.maximumIntegerDigits = 5
            
            var trim = formatter.stringFromNumber(toSearch_PostalCode)
            
            trim = trim!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            trim!.changeToURL()
        
            
            if trim! != ""{
                apiPostalCode = "PostalCode="+trim!+"&"
//                apiLat.removeAll()
//                apiLong.removeAll()
            }
        }
        
        if (!toSearch_radious.isEmpty){
            apiRadius="Radius=\(toSearch_radious)&"
        }
        
        
        
        
        apiURL = "https://api.soleo.com/businesses/?APIKey=\(apiKey)&\(apiANI)\(apiReferecenID)\(apiSourceID)\(apiKeyword)\(apiCategory)\(apiName)\(apiLat)\(apiLong)\(apiRadius)\(apiCity)\(apiState)\(apiPostalCode)\(api_request_type)\(api_sort)\(api_openOnly)".changeToURL()
        
        print(#function, #line, #file, "\(apiURL)")
    }
    
    
    private func updateBusiness(jsonn:JSON, toUpdate : Business, actionMade : Business_Callback_type) -> Business{
        
        
        var updatedBusiness = toUpdate
        //Just Presented to user. Now to get the other details and store it.
//        for (index, callback) in updatedBusiness.callbacks.enumerate()
//        {
        
            switch actionMade
            {
                //The data coming if for present callback result
                case Business_Callback_type.present:
                    updatedBusiness.callbacks.removeAll()
                    updatedBusiness.presented = true
                    
                    for(index2, reference) in jsonn["data"][0]["_links"].enumerate()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference.1["rel"].string! as String,
                            referenceURL: reference.1["href"].string! as String,
                            callbackMethod: reference.1["method"].string! as String),
                            atIndex: index2)
                    }
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.select:
                    updatedBusiness.callbacks.removeAll()
                    for(index2, reference) in jsonn["data"][0]["_links"].enumerate()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference.1["rel"].string! as String,
                            referenceURL: reference.1["href"].string! as String,
                            callbackMethod: reference.1["method"].string! as String),
                            atIndex: index2)
                    }
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.selected_with_details:
                    
                    updatedBusiness.extraDetails.removeAll()
                    
                    for(index2, reference) in jsonn["data"][0]["details"].enumerate()
                    {
                        updatedBusiness.extraDetails.insert(" \(reference.0)  -  \(reference.1.rawValue) ",
                            atIndex: index2)
                    }

                    
                    updatedBusiness.callbacks.removeAll()
                    for(index3, reference2) in jsonn["data"][0]["_links"].enumerate()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference2.1["rel"].string! as String,
                            referenceURL: reference2.1["href"].string! as String,
                            callbackMethod: reference2.1["method"].string! as String),
                            atIndex: index3)
                    }

                    
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.details:
                    
                    updatedBusiness.extraDetails.removeAll()
                    
                    for(index2, reference) in jsonn["data"][0]["details"].enumerate()
                    {
                        updatedBusiness.extraDetails.insert(reference.1.rawValue as! String,
                            atIndex: index2)
                    }
                    
                    updatedBusiness.callbacks.removeAll()
                    for(index3, reference2) in jsonn["data"][0]["_links"].enumerate()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference2.1["rel"].string! as String,
                            referenceURL: reference2.1["href"].string! as String,
                            callbackMethod: reference2.1["method"].string! as String),
                            atIndex: index3)
                    }
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.getNumbers:
                    
                    updatedBusiness.displayNumber = CNPhoneNumber(stringValue: jsonn["data"][0]["displayPhoneNumber"].string! as String)
                    updatedBusiness.callCompletionNumber = CNPhoneNumber(stringValue: jsonn["data"][0]["completionPhoneNumber"].string! as String)
                    
                    updatedBusiness.callbacks.removeAll()
                    for(index2, reference) in jsonn["data"][0]["_links"].enumerate()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference.1["rel"].string! as String,
                            referenceURL: reference.1["href"].string! as String,
                            callbackMethod: reference.1["method"].string! as String),
                            atIndex: index2)
                    }

                    
                    break
                
                //This 2 guys return nothing but a 201.
            case Business_Callback_type.calledDisplayNumber,
                Business_Callback_type.calledCompletionNumber:
                    break
            }

//        }
        
        return updatedBusiness
    }

}