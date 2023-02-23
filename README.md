# 🍏 JFWeatherApp

*Weather App to Show User Options to input Location in various ways and show weather at the user's selected location.*

 
## 📘 Summary 

the API call is supported by the open weather API. 
 - https://openweathermap.org/current

1. A native-app-based application to serve as a basic weather app.
2. Allow customers to enter a US city
3. Call the openweathermap.org API and display the information I thought a user would be interested in seeing
4. Support display a weather icon, caching is supported. 
5. Auto-load the last city searched upon app launch.
6. Ask the User for location access, If the User permits to access the location, then retrieve weather data by default.

**Extra Main Feature**

- Have the self-implemented latest recently used cache data structure to handle the search history with at most 5 items capacity. 
- Leverage the newly introduce UIMenu (iOS 14.0) to handle the city history list on the same page. 

**Highlights**

- Runs on iPhone / iPad
- Supports Portrait and Landscape Orientation
- Support Dark and Light Appearance
- Accessibility Support
- Dynamic Type Support
- Well-Documented Code
- Unit and UI Test cases
- No Third-party Libraries Used

 
## 🪵 Design

- Leverage the Model-View-ViewModel (MVVM) architecture as the backbone of the application. 
- Pull out the basic mechanism logic from fat UIViewController and generate the network layer class and data layer class. This part is based on the dependency injection to facilitate the UI and unit tests. 
- Even though we used the MVVM to make the code more testable and decoupled, the navigation will still be the pain point when introducing more features to the application. 
Moving the navigation function out to make sure the application is more SOLID, to be specific, more Single Responsibility.  
So, the coordinator design pattern should be a future navigation problem killer for small to medium size projects, like our JFWeatherAPP. 


*API call*

The application is supported by API version 2.5. We will bump up the version to 3.0 (lasted one) soon. 

https://api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}

https://api.openweathermap.org/data/2.5/weather?q={city name},{country code}&appid={API key}

https://api.openweathermap.org/data/2.5/weather?q={city name},{state code},{country code}&appid={API key}


Reference: 
[https://docs.github.com/en/repositories/creating-and-managing-repositories/deleting-a-repository](https://github.com/anandgupadhyay/AUWeatherApp?ref=iosexample.com)

## 🐝 TODO:

- Accessibility should be centralized and handled by a single file. 
- Need localization files. 
- User singleton could be used for the future app-level configuration but make sure to leverage the dependency injection to facilitate the testing. 
- more UI/Unit test coverage. 
- More Error handling cases. 


## 🎥 User Interface (UI)

| Normal Mode | Dark Mode |
| --- | --- |
| ![Screenshot 2023-02-22 at 4 55 08 PM](https://user-images.githubusercontent.com/8815608/220801139-33dd4f15-8418-4672-9b72-ae78dfe07e89.png)] | ![Screenshot 2023-02-22 at 4 55 41 PM](https://user-images.githubusercontent.com/8815608/220801158-ab1af7ef-86a7-43ce-b202-a7eb9c86bfbb.png) |
| ![Screenshot 2023-02-22 at 4 55 18 PM](https://user-images.githubusercontent.com/8815608/220801184-09817070-34a7-42b5-8761-b53adcc6bdfd.png) | ![Screenshot 2023-02-22 at 4 55 49 PM](https://user-images.githubusercontent.com/8815608/220801204-364a18c7-eb9c-44c7-b475-5d61e74cafaa.png) |




**History List lasted recently used (LRU) cache. sorted from latest to older one**

| If the limit is reached, remove the item from the bottom | If item is searched again, move it to the top | selection will update weather UI and make it to the top |
| --- | --- | --- |
| ![ezgif com-video-to-gif](https://user-images.githubusercontent.com/8815608/220802916-91edf224-1386-4e3c-a0be-3b2bcc341cd7.gif) | ![ezgif com-video-to-gif copy](https://user-images.githubusercontent.com/8815608/220802942-a9327666-4836-4c01-863f-fea8824808af.gif) | ![ezgif com-video-to-gif copy 2](https://user-images.githubusercontent.com/8815608/220802967-fa48fc84-57fc-4b8d-8c3b-995d7e58c075.gif) |


**Persistent**
| firsttime location permission, current address | with location permission, latest searched city |
| --- | --- |
| ![flow1](https://user-images.githubusercontent.com/8815608/220805415-7ee6c3cf-11ea-4e74-8f7f-4e68028ba10a.gif) | ![flow2](https://user-images.githubusercontent.com/8815608/220805454-56a77b62-36b0-468d-96cb-1bdf839aa448.gif) |



## 🦁 How to Run 


- Xcode 13.2.1 or Above
- Supported iOS 15.0 and above:
    Note: UIMenu is only supported at iOS 14.0 and above, the .singleSelection for UIMenu starts to support when 15.0
- Download Code or Clone the repository: 
- Open Project in Xcode
- Run on Simulator
  - Set Simulator as run device
  - Build and Run the App
  - To Simulate My Location on the Simulator:
         On Simulator Menus select -> Features -> Location -> Custom Location -> add Lat :52.531677 and Lon :13.381777 
- Run on Real Device 
  - Under Project -> Targets -> Select JFWeatherApp -> Signing & Capabilities -> Select Team and Check Automatically Manage Signing
  - Build and Run the app on the device



