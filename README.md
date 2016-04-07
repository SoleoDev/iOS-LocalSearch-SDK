# iOS-SDK
Soleo Local Search API for iOS (Swift 2.2)

Soleo Local Search API allows developer to access Soleo's extensive Local Business Data system that includes 20,000 small, local business in the US.

The API also allows developer to monetize call intent from user to guide users to Advertise companies that are loca, up to date and verified.

The Soleo Local Search API allows developers to build amazing local search solutions that connect people with businesses and monetize like nowhere else.

For more information:
http://developer.soleo.com

#Dependancies
Soleo:
  Soleo Local Search API key = http://developer.soleo.com
  
Apple:
  Foundation
  CoreLocation = To create easily translatable CLLocations objects for GeoLocation funcstions
  Contacts = To create easily translatable CNPhoneNumber objects.
  
External:
SwiftyJSON : https://github.com/SwiftyJSON/SwiftyJSON.git
Use of SwiftyJSON to allow for easier code tranlation of JSON data.

#How to use

1) Create a API key in developer.soleo.com
2) Add Files to your Project
3) Add dependancies to the project as needed.
  3.1) Can use direct includes of SwiftyJSON or the recomended mode of CocoaPods
4) Change the API key in SoleoAPI.swift file
5) Create the SoleoAPI object, instantiate and request data.
6) Use Business objects to get the Local Business data and to request monetization information

#Technical Data
The Soleo Local Search API uses a REST base API to access data using HTTP Gets and Post.
Latency = ~200ms/reuqest
Encryption/Security = HTTPS
Gets = Request search information
Post = Request extra information for a specific object
Search Valid times for advertisements/sponsored monetization = ~5 minutes
HTTP return codes:

Sucessfull return codes:
  - 200 = Response OK for get. Returning listings
  - 201 = Response OK for a POST.

Error Return codes
  - 400 = Error with Query check return message
  - 403 = Exceded Query Limits. Check API key info.
  - 404 = Error invalid endpoint or timeout
  - 405 = Wrong HTTP method for search type
  - 406 = Invalid HTTP Header
  - 410 = Resource not found. Check Header or API endpoint(URL)
  - 500 = System Down

Contact information:
localsearchapi@soleo.com
