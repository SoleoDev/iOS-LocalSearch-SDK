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
/**
 API Response
 
 API Response typealias that provides back all the information:
 
 - parameter [Business]: Array of business back from the system
 - parameter NSError?:     Error Return

 - returns: Void
 */
public typealias APIResponse = ([Business]?, NSError?) -> Void

/// API Callback Response with a new Business and a NSError.
/**
 API Callback Response
 
 API Callback Response typealias that provides back all the information after 
 HTTP a callback is perform
 
 - parameter Business: Business information that was updated
 - parameter NSError?:     Error Return
 
 - returns: Void
 */
public typealias APICallBackResponse = (Business?, NSError?) -> Void

/// API Multiple Category Response with a new Dictonary of Business and a Category Array.
/**
 API Multiple Category Response
 
 API Multiple Category Response typealias that provides back all the information
 in a Dictonary of Categories and Business with a Category List array for the keys also.
 
 - parameter [String:[Business]]: Dictonary of Key = Categories, Values = Array of businesses 
    with that category
 - parameter [String]:     Catgories / keys for the Dictionary provided.
 
 - returns: Void
 */
public typealias APIMultiCatResponse = ([String:[Business]]?,[String]?) -> Void


//MARK: EXTENSION to String class
///Used to remove the leading & trailing whitespace and to also change the whitspace inside the string to be URL compliant spaces
extension String {
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: [NSString.CompareOptions.caseInsensitive, NSString.CompareOptions.caseInsensitive] , range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func changeToURL() -> String {
        return self.replace(" ", replacement: "%20").replace(",", replacement: "%2C")
    }
    
    func changeToURL2() -> String{
        return self.replace("%", replacement: "%25").replace("!", replacement: "%21").replace("\\\"", replacement: "%22").replace("#", replacement: "%23").replace("$", replacement: "%24").replace("&", replacement: "%26").replace("\'", replacement: "%27").replace("(", replacement: "%28").replace(")", replacement: "%29").replace("*", replacement: "%2A").replace("+", replacement: "%2B").replace("-", replacement: "%2D").replace(".", replacement: "%2E").replace("/", replacement: "%2F").replace(":", replacement: "%3A").replace(";", replacement: "%3B").replace("<", replacement: "%3C").replace("=", replacement: "%3D").replace(">", replacement: "%3E").replace("?", replacement: "%3F")
    }

}



/// Soleo Local Search API main object
/// For more information go to: developer.soleo.com
/**
 -class : SoleoAPI
 -helper : APIConnector, Business types, Category Types
 */
open class SoleoAPI
{
/// Soleo Local Search Rest API key
// TODO: Place your APIKEY HERE
    let apiKey = <#Your APIKEY#>
    
    
//        let URL_EXAMPLE = "https://trialapi.soleo.com/businesses/?APIKey=YOURAPIKEY&ANI=5856414300&ReferenceID=T7360&Keyword=food&Latitude=43.038304720296516&Longitude=-77.4576846095582&Sort=value_distance"
    
    //MARK: Fields
    
    //Class only
    fileprivate var apiURL : String?
    

    ///Requiered ONLY 1 of the following: Keyword, Name or Category
    open var toSearch_keyword : String
    open var toSearch_Name : String
    open var toSearch_Category : String
    open var toSearch_freeFormQuery : String
    
    // If Location is provded, City,Sate,PostalCode is not requiered.
    open var location : CLLocation
    open var toSearch_City : String
    open var toSearch_State : String
    open var toSearch_PostalCode : Int
    
    open var toSearch_radious : String
    
    //Extras
    
    open var OpenOnly : Bool = false
    open var sortType : Business_Sort_Type = Business_Sort_Type.distance
    open var requestType : Business_Request_Type = Business_Request_Type.ALL

    
    //Return Values
    open var businessList = [Business]()
    open var foundOrganics : Int = 0
    open var foundSponsors : Int = 0
    open var totalFound : Int = 0
    open var resultsValidUntil : Date = Date()
    
    open var dataError : NSError?
    open var SearchRequest : Search_type?
    
    /// Integration Endpoint Flag
    var DEMOEndpoint : Bool?
    
    //NEW Max Counts Fields
    open var results_MaxOrganics_count : Int?
    open var results_MaxSponsored_count : Int?
    
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
        self.toSearch_freeFormQuery = ""
        
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
        self.toSearch_freeFormQuery = ""

    }
    
    
    //MARK: API  Search Functions
    
    // Calls into APIConnector to make a connection to mashery and will return a JSON list.
    //Use for Initial Search.
    
    /**
     Main Method to get the Business Listing Objects
     Calls into APIConnector to make a connection to API and will return a JSON list.
     
     - parameter processCompleter: API Response with the Business Objects Array and a NSError
     */
    open func getData(_ processCompleter: @escaping APIResponse){
            self.createURL();
            
            APIConnector.sharedInstance.connect(self.apiURL!, method: "GET"){ (json, error, response) -> Void in
                
                
                if(error != nil)
                {
                    print("Got deep error",error!)
                    processCompleter(nil,NSError(domain: "api.soleo.com", code: 510, userInfo: ["info":NSLocalizedString("ErrorTimeout", comment: "error")]))
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
                                error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: ["system":response!.Description])
                            }
                            
                            self.dataError = error2
                            processCompleter(nil,error2)
                            return

                        }
                        
                        processCompleter(self.businessList, nil)
                        
                    }
                    else if((response?.response)! >= 400)
                    {
                        let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: ["system":response!.Description])
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
    open func getDataFromPrevoiusSearch(_ previousSearch: Search_type ,processCompleter: @escaping APIResponse){
        self.createURL();
        
        APIConnector.sharedInstance.connect(previousSearch.search_query, method: "GET"){ (json, error, response) -> Void in
            
            if(error != nil)
            {
                print("Got deep error",error!)
                processCompleter(nil,NSError(domain: "api.soleo.com", code: 510, userInfo: ["info":NSLocalizedString("ErrorTimeout", comment: "error")]))
            }

            
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
                else if((response?.response)! >= 400)
                {
                    let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: nil)
                    self.dataError = error2
                    processCompleter(nil,error2)
                }
                
            }
            
            APIConnector.sharedInstance.closeSession()
            
            
        }
        
    }
    
    /**
     Perform a Catgoriy Endpoint request
     
     Make categories endpoint requestion to get for all current, active Tier 1 and Tier 2 categories.
     
     - parameter processCompleter - typealias APIResponse for a threated task.
     
     - returns: Void
     */
    func getCategories(_ processCompleter: @escaping APIResponse){
        
        APIConnector.sharedInstance.connect("https://trialapi.soleo.com/category/2?APIKey=\(apiKey)", method: "GET"){ (json, error, response) -> Void in
            
            if(error != nil)
            {
                print("Got deep error",error!)
                processCompleter(nil,NSError(domain: "api.soleo.com", code: 510, userInfo: ["info":NSLocalizedString("ErrorTimeout", comment: "error")]))
            }
            
            if(response != nil)
            {
                print("we got a response: CODE \(response?.response)  and description\(response?.Description)")
                //                    self.dataError = error
                
                if(response?.response == 200)
                {
                    self.makeCategoryList(json!)
                    print("done making list")
                }
                else if((response?.response)! >= 400)
                {
                    let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: ["system":response!.Description])
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
    open func getCallBacksData(_ businessToGet: Business , action : Business_Callback_type , processCompleter: @escaping APICallBackResponse){
        
        let index = businessToGet.callbacks.index{$0.rel == action.rawValue}
        
        if(businessToGet.presented)
        {
            
        }
        
        APIConnector.sharedInstance.connect(businessToGet.callbacks[index!].referenceURL, method: businessToGet.callbacks[index!].callbackMethod){ (json, error, response) -> Void in
            
            
            if(error != nil)
            {
                print("Got deep error",error!)
                processCompleter(nil,NSError(domain: "api.soleo.com", code: 510, userInfo: ["info":NSLocalizedString("ErrorTimeout", comment: "error")]))
            }

            
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
                else if((response?.response)! >= 400)
                {
                    let error2 = NSError(domain: "api.soleo.com", code: (response?.response)!, userInfo: ["system":response!.Description])
                    self.dataError = error2
                    processCompleter(nil,error2)
                }
                
            }
            
            APIConnector.sharedInstance.closeSession()
            
            
        }
        
    }
    
    //MARK: Support Functions
    
    //will make a list that can be passed to the other view controllers
    /**
     Make a Business List
     
     Make the business objects return from our system:
     
     - parameter jsonn: JSON data to split by;
     
     
     - returns: Void
     */
    fileprivate func makeList(_ jsonn:JSON){ //-> [Business]

        print("Making List")
        
        if(jsonn["summary"] != JSON.null)
        {
            var i = 0
            
            //Getting Summary Information.
            foundSponsors = jsonn["summary"]["resultsCount"]["sponsored"].int! as Int
            foundOrganics = jsonn["summary"]["resultsCount"]["organic"].int! as Int
            totalFound = foundSponsors + foundOrganics
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            while (jsonn["businesses"][i]["name"] != JSON.null){
                var bus = Business()
                
                //Basic Information.
                bus.name = jsonn["businesses"][i]["name"].string! as String
                bus.address = jsonn["businesses"][i]["address"].string! as String
                bus.city = jsonn["businesses"][i]["city"].string! as String
                bus.state = jsonn["businesses"][i]["state"].string! as String
                bus.zip = jsonn["businesses"][i]["zip"].string! as String
                bus.type =  Business_Type(rawValue: (jsonn["businesses"][i]["type"].string! as String).lowercased())!
                
                
                if let distanceValue = jsonn["businesses"][i]["distance"]["miles"].string
                {
                    if (!distanceValue.isEmpty)
                    {
                     bus.distance = Double(distanceValue)!
                    }
                    else
                    {
                     bus.distance = 0.0
                    }
                    
                }
                else{
                    bus.distance = 0.0
                }
//                bus.distance = Double(jsonn["businesses"][i]["distance"]["miles"].string! as String) ?? 0.0
                
                //Monetization or Cost build up.
                if(bus.type == Business_Type.Sponsored){
                    bus.monetization = Business_Monetization(
                        completion_action: Business_Action_Type(rawValue: (jsonn["businesses"][i]["monetizationCritera"]["action"].string! as String).lowercased())!,
                        criteria: (jsonn["businesses"][i]["monetizationCritera"]["criteria"].string!),
                        value: (jsonn["businesses"][i]["monetizationCritera"]["value"].string!).isEmpty ? 0.0 : Double(jsonn["businesses"][i]["monetizationCritera"]["value"].string!)!,
                        validUntil: dateFormater.date(from: (jsonn["businesses"][i]["monetizationCritera"]["validUntil"].string! as String))!)
                }
                else
                {
                    bus.cost = Business_Cost_to_developer(
                        action: Business_Action_Type(rawValue: (jsonn["businesses"][i]["costCritera"]["action"].string! as String).lowercased())!,
                        value: (jsonn["businesses"][i]["costCritera"]["value"].string!).isEmpty ? 0.0 : Double(jsonn["businesses"][i]["costCritera"]["value"].string!)!,
                        validUntil: dateFormater.date(from: (jsonn["businesses"][i]["costCritera"]["validUntil"].string! as String))!)
                }
                
                //Getting Callbacks.
                bus.callbacks.append(Business_Callback_Definition(
                    rel: jsonn["businesses"][i]["_links"][0]["rel"].string! as String,
                    referenceURL: jsonn["businesses"][i]["_links"][0]["href"].string! as String,
                    callbackMethod: jsonn["businesses"][i]["_links"][0]["method"].string! as String))
                
                //Seting Up location
                bus.Location = CLLocation(latitude: Double(jsonn["businesses"][i]["latitude"].string! ) ?? 0.0 ,
                    longitude: Double(jsonn["businesses"][i]["longitude"].string!) ?? 0.0)
                
                if let category = jsonn["businesses"][i]["categoryName"].string
                {
                    bus.Category = category
                }
                else{
                    bus.Category = "General"
                }
                
                
                
                //Inserting Items to list.
                businessList.insert(bus, at: i)
                i += 1

            
                
            }
            
            SearchRequest = Search_type(name: "Search for \(toSearch_keyword.isEmpty ? toSearch_freeFormQuery.isEmpty ? toSearch_Category : toSearch_freeFormQuery : toSearch_keyword) in \(toSearch_City), \(toSearch_State) \(toSearch_PostalCode)",
                                        query: apiURL!, timeS: dateFormater.date(from: (jsonn["summary"]["validUntil"].string! as String))!, location: location, fav: false, keyword: toSearch_keyword.isEmpty ? toSearch_freeFormQuery.isEmpty ? toSearch_Category : toSearch_freeFormQuery : toSearch_keyword)
            
        }
        //print(__FUNCTION__, __LINE__, "\(businessList)")
        //return businessList
    }
    
    
    /**
      Make a Categories List
     
     Make the categories objects return from our system:
     
     - parameter jsonn: JSON data to split by;
     
     
     - returns: Void
     */
    fileprivate func makeCategoryList(_ jsonn: JSON){
        
        
        var catList : [Category] = []
        
        if(jsonn["children"] != JSON.null){
            var x = 0
            var y = 0
            var list : [Category] = []
            var newList : [Category] = []
            
            while jsonn["children"][x]["id"] != JSON.null{
                while jsonn["children"][x]["children"][y]["id"] != JSON.null{
                    var category: Category? = nil
                    category?.id = jsonn["children"][x]["children"][y]["id"].string! as String
                    category?.name = jsonn["children"][x]["children"][y]["text"].string! as String
                    category?.children = []
                    list.append(category!)
                    y += 1
                }
                var category: Category? = nil
                category?.id = jsonn["children"][x]["id"].string! as String
                category?.name = jsonn["children"][x]["text"].string! as String
                category?.children = list
                newList.append(category!)
                x += 1
            }
            var cat: Category? = nil
            cat?.id = jsonn["id"].string! as String
            cat?.name = jsonn["text"].string! as String
            cat?.children = newList
            catList.append(cat!)
        }
        print("\(catList)")
    }

    
    //Creates a URL that will get passed to getData()
    fileprivate func createURL(){
        //This APIKEY will need to be replace by your API key.
        
        
        var apiName = ""
        var apiKeyword = ""
        var apiCategory = ""
        var apiFreeFromQuery = ""
        
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
        
        var api_maxrequest = ""
        var api_maxorganics = "MaxOrganicCount=07&"
        var api_maxsponsored = "MaxSponsoredCount=03&"
        
        //TODO: EXPOSE THIS TOO TO THE OUTSIDE WORLD... LATER
        //This can be changed to anythign you want to be. Its 1 number per API which in our case is session
        //VJ 02-08 SOMETHING HAPPEND WITH THIS 2 PARAMETERS IN THE SYSTEM...
        //SET THEM TO BLANK for now.
        let deviceID = UIDevice().identifierForVendor?.uuidString as String!
        let apiReferecenID = "ReferenceID=\(deviceID!)&"
        
        //ID to track the activity of that device
        var sourceID = UIDevice().name
        sourceID = sourceID.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
        let apiSourceID = "SourceID=\(sourceID)&"
        
        if (!toSearch_Name.isEmpty){
            var trim = toSearch_Name.trimmingCharacters(in: CharacterSet.whitespaces)
            trim = trim.changeToURL()
            if trim != ""{
                apiName = "Name="+trim+"&"
            }
        }
        
        if (!toSearch_keyword.isEmpty){
            let trim = toSearch_keyword.trimmingCharacters(in: CharacterSet.whitespaces)
            if trim != ""{
                apiKeyword = "Keyword="+trim+"&"
                apiKeyword = apiKeyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            }
        }
        
        if (!toSearch_Category.isEmpty){
            var trim = toSearch_Category.trimmingCharacters(in: CharacterSet.whitespaces)
            trim = trim.changeToURL()
            if trim != ""{
                apiCategory = "Category="+trim+"&"
            }
        }
        
        if (!toSearch_freeFormQuery.isEmpty){
            var trim = toSearch_freeFormQuery.trimmingCharacters(in: CharacterSet.whitespaces)
            trim = trim.changeToURL()
            if trim != ""{
                apiFreeFromQuery = "FreeFormQuery="+trim+"&"
            }
        }

        if (!toSearch_City.isEmpty){
            var trim = toSearch_City.trimmingCharacters(in: CharacterSet.whitespaces)
            trim = trim.changeToURL()
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
            
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 5
            formatter.maximumIntegerDigits = 5
            
            var trim = formatter.string(from: NSNumber(value: toSearch_PostalCode))
            
            trim = trim!.trimmingCharacters(in: CharacterSet.whitespaces)
            trim = trim!.changeToURL()
        
            
            if trim! != ""{
                apiPostalCode = "PostalCode="+trim!+"&"
//                apiLat.removeAll()
//                apiLong.removeAll()
            }
        }
        
        if (!toSearch_radious.isEmpty){
            apiRadius="Radius=\(toSearch_radious)&"
        }
        
        if results_MaxOrganics_count != nil{
            
            api_maxorganics = "MaxOrganicCount=\(results_MaxOrganics_count!)&"
        }
        
        if results_MaxSponsored_count != nil{
            
            api_maxsponsored = "MaxSponsoredCount=\(results_MaxSponsored_count!)&"
        }
        
        api_maxrequest = api_maxsponsored + api_maxorganics
        
        apiURL = "https://trialapi.soleo.com/businesses/?\(api_maxrequest)APIKey=\(apiKey)&\(apiANI)\(apiReferecenID)\(apiSourceID)\(apiKeyword)\(apiCategory)\(apiFreeFromQuery)\(apiName)\(apiLat)\(apiLong)\(apiRadius)\(apiCity)\(apiState)\(apiPostalCode)\(api_request_type)\(api_sort)\(api_openOnly)".changeToURL()
        
        print(#function, #line, #file, "\(apiURL)")
    }
    
    
    /**
     Update Business
     
     Update a unitc business from a JSON object
     
     - parameter json: Json data format to use to update the busines element
     - parameter toUpdate:     Business element to update
     - parameter actionMade: Business_Callbback_typethat was performt to get the new information.
     
     - returns: Business - the business object after the updates where applied.
     */
    fileprivate func updateBusiness(_ jsonn:JSON, toUpdate : Business, actionMade : Business_Callback_type) -> Business{
        
        
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
                    
                    for(index2, reference) in jsonn["data"][0]["_links"].enumerated()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference.1["rel"].string! as String,
                            referenceURL: reference.1["href"].string! as String,
                            callbackMethod: reference.1["method"].string! as String),
                            at: index2)
                    }
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.select:
                    updatedBusiness.callbacks.removeAll()
                    for(index2, reference) in jsonn["data"][0]["_links"].enumerated()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference.1["rel"].string! as String,
                            referenceURL: reference.1["href"].string! as String,
                            callbackMethod: reference.1["method"].string! as String),
                            at: index2)
                    }
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.selected_with_details:
                    
                    let isOpen = jsonn["data"][0]["details"]["isOpen"].string!
                    let Hours = jsonn["data"][0]["details"]["hours"].string!
                    
                    let timeZone = jsonn["data"][0]["details"]["timeZone"].string!
                    
                    let displayHours = (jsonn["data"][0]["details"]["displayHours"].string!).components(separatedBy: CharacterSet.init(charactersIn: ","))
                    
                    var descriptors = [String]()
                    for(_, reference) in jsonn["data"][0]["details"]["descriptors"].enumerated()
                    {
                        descriptors.append("\(reference.1.rawValue)")
                    }
                    
                    updatedBusiness.details = BusinessDetails(isOpen: isOpen, TimeZone: timeZone, ParseableHours: Hours, DisplayHours: displayHours, descriptors: descriptors)
                    
                    

                    
                    updatedBusiness.callbacks.removeAll()
                    for(index3, reference2) in jsonn["data"][0]["_links"].enumerated()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference2.1["rel"].string! as String,
                            referenceURL: reference2.1["href"].string! as String,
                            callbackMethod: reference2.1["method"].string! as String),
                            at: index3)
                    }

                    
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.details:
                    
                    
                    print(jsonn)
                    
                    
                    let isOpen = jsonn["data"][0]["details"]["isOpen"].string!
                    let Hours = jsonn["data"][0]["details"]["hours"].string!
                    
                    let timeZone = jsonn["data"][0]["details"]["timeZone"].string!
                    
                    let displayHours = (jsonn["data"][0]["details"]["timeZone"].string!).components(separatedBy: CharacterSet.init(charactersIn: "/"))
                    
                    var descriptors = [String]()
                    for(_, reference) in jsonn["data"][0]["details"]["descriptors"].enumerated()
                    {
                        descriptors.append("\(reference.0)")
                    }
                    
                    updatedBusiness.details = BusinessDetails(isOpen: isOpen, TimeZone: timeZone, ParseableHours: Hours, DisplayHours: displayHours, descriptors: descriptors)
                    
                    updatedBusiness.details = BusinessDetails(isOpen: isOpen, TimeZone: timeZone, ParseableHours: Hours, DisplayHours: displayHours, descriptors: descriptors)
                    
//                    updatedBusiness.extraDetails.removeAll()
//                    
//                    for(index2, reference) in jsonn["data"][0]["details"].enumerate()
//                    {
//                        updatedBusiness.extraDetails.insert(reference.1.rawValue as! String,
//                            atIndex: index2)
//                    }
                    
                    updatedBusiness.callbacks.removeAll()
                    for(index3, reference2) in jsonn["data"][0]["_links"].enumerated()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference2.1["rel"].string! as String,
                            referenceURL: reference2.1["href"].string! as String,
                            callbackMethod: reference2.1["method"].string! as String),
                            at: index3)
                    }
                    
                    break
                
                //The data coming if for present callback result
                case Business_Callback_type.getNumbers:
                    
                    updatedBusiness.displayNumber = CNPhoneNumber(stringValue: jsonn["data"][0]["displayPhoneNumber"].string! as String)
                    updatedBusiness.callCompletionNumber = CNPhoneNumber(stringValue: jsonn["data"][0]["completionPhoneNumber"].string! as String)
                    
                    updatedBusiness.callbacks.removeAll()
                    for(index2, reference) in jsonn["data"][0]["_links"].enumerated()
                    {
                        updatedBusiness.callbacks.insert(Business_Callback_Definition( rel: reference.1["rel"].string! as String,
                            referenceURL: reference.1["href"].string! as String,
                            callbackMethod: reference.1["method"].string! as String),
                            at: index2)
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
    
    /**
     Split Multiple Categories ALL
     
     Split the provided list into a Dictionary of multiple keys with each value been
     a array of businesses with that category also with a Array with the keys to those categories:
     
     - parameter unsplit_list: Business Array of the listings to split
     
     
     - returns: typealias APIMultiCatResponse - Dictonary of Key = Categories, Values = Array of businesses
     */
    open static func SplitMultiCategory_All(_ unsplit_list: [Business], updateProcess: APIMultiCatResponse)
    {
        var NewDictonary = [String:[Business]]()
        
        var categories = [String]()
        
        for bus : Business in unsplit_list{
            
            if !categories.contains(bus.Category!)
            {
                categories.append(bus.Category!)
                NewDictonary[bus.Category!] = [bus]
                
            }
            else{
                
                var UpdateBusinesses = NewDictonary[NewDictonary.index(forKey: bus.Category!)!]
                UpdateBusinesses.1.append(bus)
                NewDictonary.updateValue(UpdateBusinesses.1, forKey: bus.Category!)
            }
            
        }
        

        updateProcess(NewDictonary,categories)
    }
    
    /**
     Split Multiple Categories Categories Keys ONLY
     
     Split the provided list into an array of with that category:
     
     - parameter unsplit_list: Business Array of the listings to split
     
     
     - returns: [Business] -  Array of businesses categories only
     */
    open static func SplitMultiCategory_CategoriesOnly(_ unsplit_list: [Business]) -> [String]
    {
        
        var categories = [String]()
        
        for bus : Business in unsplit_list{
            
            if !categories.contains(bus.Category!)
            {
                categories.append(bus.Category!)
                
                
            }
            
        }
        
        return categories
    }
    
    /**
     Split Multiple Categories Dictionary ONLY
     
     Split the provided list into a Dictionary of multiple keys with each value been
     a array of businesses with that category:
     
     - parameter unsplit_list: Business Array of the listings to split
     
     
     - returns: [String:[Business]] - Dictonary of Key = Categories, Values = Array of businesses
     */
    open static func SplitMultiCategory_DictionaryOnly(_ unsplit_list: [Business]) -> [String:[Business]]
    {
        
        var NewDictonary = [String:[Business]]()
        
        var categories = [String]()
        
        for bus : Business in unsplit_list{
            
            if !categories.contains(bus.Category!)
            {
                categories.append(bus.Category!)
                NewDictonary[bus.Category!] = [bus]
                
            }
            else{
                
                var UpdateBusinesses = NewDictonary[NewDictonary.index(forKey: bus.Category!)!]
                UpdateBusinesses.1.append(bus)
                NewDictonary.updateValue(UpdateBusinesses.1, forKey: bus.Category!)
            }
            
        }
        
        return NewDictonary
    }

    

}
