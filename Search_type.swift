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

}


/**
 -class : Search_type
 -helps : SoleoAPI
 */
public class Search_type : NSObject, NSCoding {
    
    //MARK: Fields
    
    public var search_name : String
    public var search_query : String
    public var search_time : NSDate
    public var search_location : CLLocation
    public var favority: Bool
    
    //MARK: Data Path
    static let DocumentsDictonary = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    public static let ArchiveURL = DocumentsDictonary.URLByAppendingPathComponent("search_type")
    
    
    //MARK: Initializers
    
    /**
     Empty Initializer
     
     - returns: Search_type
     */
    public override init(){
        search_name = ""
        search_query = ""
        search_time = NSDate(timeIntervalSince1970: 0)
        search_location = CLLocation(latitude: 0.0, longitude: 0.0)
        favority = false
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
    public init?(name: String,query: String, timeS: NSDate, location: CLLocation, fav: Bool){
        
        search_name = name
        search_query = query
        search_time = timeS
        search_location = location
        favority = fav
        
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
    public func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(search_name, forKey: PropertiesKey.nameKey)
        
        aCoder.encodeObject(search_query, forKey: PropertiesKey.search_queryKey)
        
        aCoder.encodeObject(search_time, forKey: PropertiesKey.timeKey)
        
        aCoder.encodeObject(search_location, forKey: PropertiesKey.location)
        
        aCoder.encodeBool(favority, forKey: PropertiesKey.favorityKey)
        
    }
    
    /**
     Convenience initialize
     
     - parameter aDecoder: a Decoder to decode
     
     - returns: New Search_Type
     */
    required convenience public init?(coder aDecoder: NSCoder)
    {
        
        let decoded_name = aDecoder.decodeObjectForKey(PropertiesKey.nameKey) as! String
            
        let decode_query = aDecoder.decodeObjectForKey(PropertiesKey.search_queryKey) as! String
            
        let decode_time = aDecoder.decodeObjectForKey(PropertiesKey.timeKey) as! NSDate
            
        let decode_location = aDecoder.decodeObjectForKey(PropertiesKey.location) as! CLLocation
            
        let decode_fav = aDecoder.decodeBoolForKey(PropertiesKey.favorityKey)
            
        self.init(name: decoded_name, query: decode_query, timeS: decode_time, location: decode_location, fav: decode_fav )
        
        
    }
    

    
}