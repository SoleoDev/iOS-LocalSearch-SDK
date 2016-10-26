/**
 
 -file: Search_type.swift
 -author: Created by Victor Jimenez.
 -copyright: Copyright © 2016 SOLEO Communications. All rights reserved.
 -description: Search_Type Class
 -version : 1.0.3
 
 */

import Foundation
import CoreLocation

/**
 *  Properties Key for decoding
 */
public struct PropertiesKey{
    
    public static let nameKey = "name"
    
    public static let search_queryKey = "query"
    
    public static let timeKey = "time"
    
    public static let location = "location"
    
    public static let favorityKey = "fav"
    
    public static let keywordKey = "keyword"

}


/**
 -class : Search_type
 -helps : SoleoAPI
 */
public class Search_type : NSObject, NSCoding {

    
    //MARK: Fields
    
    public var search_name : String
    public var search_query : String
    public var search_time : Date
    public var search_location : CLLocation
    public var favority: Bool
    public var keyword: String
    
    //MARK: Data Path
    static let DocumentsDictonary = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    public static let ArchiveURL = DocumentsDictonary.appendingPathComponent("search_type")
    
    
    //MARK: Initializers
    
    /**
     Empty Initializer
     
     - returns: Search_type
     */
    public override init(){
        search_name = ""
        search_query = ""
        search_time = Date(timeIntervalSince1970: 0)
        search_location = CLLocation(latitude: 0.0, longitude: 0.0)
        favority = false
        keyword = ""
    }
    
    /**
     Optional Initializer
     
     - parameter name:     Name of the Search
     - parameter query:    Query
     - parameter timeS:    Time for Validation
     - parameter location: Location
     - parameter fav:      Is it a Favorite?
     
     - returns: <#return value description#>
     */
    public init?(name: String,query: String, timeS: Date, location: CLLocation, fav: Bool, keyword: String){
        
        search_name = name
        search_query = query
        search_time = timeS
        search_location = location
        favority = fav
        self.keyword = keyword
        
        super.init()
        
        if name.isEmpty || query.isEmpty
        {
            return nil
        }
        
    }
    
    

    //MARK: NSCoding Funtions
    
    /**
     Encoded
     
     - parameter aCoder: a NSCoder to encode
     */
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(search_name, forKey: PropertiesKey.nameKey)
        
        aCoder.encode(search_query, forKey: PropertiesKey.search_queryKey)
        
        aCoder.encode(search_time, forKey: PropertiesKey.timeKey)
        
        aCoder.encode(search_location, forKey: PropertiesKey.location)
        
        aCoder.encode(favority, forKey: PropertiesKey.favorityKey)
        
        aCoder.encode(keyword, forKey: PropertiesKey.keywordKey)
        
    }
    
    /**
     Convenience initialize
     
     - parameter aDecoder: a Decoder to decode
     
     - returns: New Search_Type
     */
    required convenience public init?(coder aDecoder: NSCoder)
    {
        
        let decoded_name = aDecoder.decodeObject(forKey: PropertiesKey.nameKey) as! String
            
        let decode_query = aDecoder.decodeObject(forKey:PropertiesKey.search_queryKey) as! String
            
        let decode_time = aDecoder.decodeObject(forKey:PropertiesKey.timeKey) as! Date
            
        let decode_location = aDecoder.decodeObject(forKey:PropertiesKey.location) as! CLLocation
            
        let decode_fav = aDecoder.decodeBool(forKey: PropertiesKey.favorityKey)
        
        let decoded_keyword = aDecoder.decodeObject(forKey:PropertiesKey.keywordKey) as! String
            
        self.init(name: decoded_name, query: decode_query, timeS: decode_time, location: decode_location, fav: decode_fav, keyword:  decoded_keyword)
        
    }
    

    
}
