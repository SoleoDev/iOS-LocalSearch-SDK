/**
 
 -file: Businesses.swift
 -author: Created by Victor Jimenez.
 -copyright: Copyright © 2016 SOLEO Communications. All rights reserved.
 -description: Businesses Definition, other Struct and Enums
 -version : 1.0.1
 */
import Foundation
import Contacts
import CoreLocation


/**
 *  Definition of a bussines listing Structure
 - Parameters
  - name : String Name
  - address: String Address
  - city : String City
  - state : String State
  - zip : String Zip Code or Postal Code
  - type : Business_Type enum
  - monetization : Business_Monetization struct
  - cost : Business_Cost_to_developer struct
  - callbacks : Business_Callback_Definition struct ARRAY
  - presented : Bool
  - displayNumber : CNPhoneNumber
  - callCompletionNumber : CNPhoneNumber
  - extraDetails : String ARRAY
  - Location : CLLocation

 */
public struct Business {
    
    public var name = ""
    public var address = ""
    public var city = ""
    public var state = ""
    public var zip = ""
    public var type : Business_Type = Business_Type.Sponsored
    public var monetization : Business_Monetization = Business_Monetization(completion_action: Business_Action_Type.Presented, criteria: 0, value: 0.0000, validUntil: NSDate())
    public var cost : Business_Cost_to_developer = Business_Cost_to_developer(action: Business_Action_Type.Presented, value: 0.00, validUntil: NSDate())
    public var callbacks : [Business_Callback_Definition] = [Business_Callback_Definition]()
    public var presented : Bool = false
    public var displayNumber : CNPhoneNumber?
    public var callCompletionNumber : CNPhoneNumber?
    public var extraDetails : [String] = [String]()
    public var Location : CLLocation?
    
    /**
     Empty Initializer
     
     - returns: A new Empty Business
     */
    public init() {
        
    }
}

/**
 Business Listing Type, represent what is Organic or Ad Free content 
 vs 
 Sponsored or content that is Advertisable and can be monetize
 
 - Organic:   Organic Business Listing
 - Sponsored: Sponsored Business Listing
 */
public enum Business_Type : String {
    case Organic = "Organic"
    case Sponsored = "Sponsored"
}

/**
 Action Type.
 Action to be perform before this Business Listing can be monetize
 
 - Selected:         Business Must be selected to show to the user
 - Presented:        Business most be presented to the user
 - Called:           A call must be made
 - CompletionNumber: A call number must be request, no call is necesary
 */
public enum Business_Action_Type : String
{
    case Selected = "Selected"
    case Presented = "Presented"
    case Called = "CALLED"
    case CompletionNumber = "CompletionNumberRequest"
}

/**
 Type of Action Business that can be requested form the system to be return
 
 - Organic:                    Organics listing only
 - Selected:                   Selected actions only
 - Presented:                  Presented actions only
 - Called:                     Called actions only
 - Organic_Selected:           Organic and Selected actions only
 - Organic_Present:            Organic and Presented actions only
 - Organi_Called:              Organic and Called actions only
 - Selected_Presented:         Selected and Presented actions only
 - Selected_Called:            Selected ad Called actions only
 - Presented_Called:           Presented and Called actions only
 - Organic_Selected_Presented: Organic, Selected and Presented actions only
 - Selected_Presented_Called:  Selected, Presented and Called actions only
 - ALL:                        All
 */
public enum Business_Request_Type : String
{
    case Organic = "Organic"
    case Selected = "Selected"
    case Presented = "Presented"
    case Called = "Called"
    case Organic_Selected = "Organic,Selected"
    case Organic_Present = "Organic,Presented"
    case Organi_Called = "Organic,Called"
    case Selected_Presented = "Selected,Presented"
    case Selected_Called = "Selected,Called"
    case Presented_Called = "Presented,Called"
    case Organic_Selected_Presented = "Organic,Presented,Selected"
    case Selected_Presented_Called = "Presented,Selected,Called"
    case ALL = "Organic,Presented,Selected,Called"
    
    
}

/**
 Business Listing Sort request
 
 - value:    Sort by Most Ad revenue value
 - distance: Sort by Distance
 - both:     Sort by Both in where Most Ad revenue are on the top sorted again by distance
 */
public enum Business_Sort_Type : String {
    case value = "value"
    case distance = "distance"
    case both = "value_distance"
}


/**
 *  Parameters for developer money making scheama
 */
public struct Business_Monetization
{
    
    public var completion_action : Business_Action_Type //Action type to complete monetization
    public var criteria : Int
    public var value : Double
    public var validUntil : NSDate
    
}

/**
 *  Cost criteria is for Organic listings ONLY
 */
public struct Business_Cost_to_developer
{
    public var action : Business_Action_Type //Action type
    
    public var value : Double
    
    public var validUntil : NSDate
}

/**
 *  Business Callback Structure
    - rel : Reference type : String
    - referenceURL : String
    - callbackMethod : String base on Business Callback type
 */
public struct Business_Callback_Definition
{
    public var rel : String
    
    public var referenceURL : String
    
    public var callbackMethod : String
}

/**
 Business Callback reference Enum
 This are all done in POST request.
 
 - present: First step presented Callback. Always will need to happen ONCE
 - select:  Second Step callback. Select the business
 - details: Request Details for Business
 - selected_with_details: Option and might not be shown by all Business Listing.
    -warning: It will ONLY return a object with data, no other steps or information.
 - getNumbers:  Callback to request a Business Phone Number
 - calledDisplayNumber:  Callback to send once you have Called Display Number
 - calledCompletionNumber: Callback to send once you have called the Completion Number for monetization
 */
public enum Business_Callback_type : String
{
    case present = "urn:soleo:businesses:presented" //ALWAYS WILL NEED TO HAPPEN ONCE
    case select = "urn:soleo:businesses:selected" //ALL WILL HAVE THIS.
    case details = "urn:soleo:businesses:getdetails" //OPTIONAL // WHEN DOING THIS, it will ONLY RETURN DATA. NOT OTHER STEPS. CAREFULL!!!
    case selected_with_details = "urn:soleo:businesses:selectedwithdetails" //MIGHT BE THERE OR NOT... DON'T KNOW YET... THIS MIGHT ALSO RETURN A NUMBER... WIERD
    case getNumbers = "urn:soleo:businesses:getcompletionnumber"
    case calledDisplayNumber = "urn:soleo:businesses:calleddisplaynumber"
    case calledCompletionNumber = "urn:soleo:businesses:calledcompletionnumber"
}

