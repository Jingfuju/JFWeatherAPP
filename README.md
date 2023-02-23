# 🍏 JFWeatherApp

*Weather App to Show User Options to input Location in various ways and show weather at the user's selected location.*

 
## 📘 Summary 

the API call is supported by the open weather API. 
 - https://openweathermap.org/current

1. A native-app-based application to serve as a basic weather app.
2. Allow customers to enter a US city
3. Call the openweathermap.org API and display the information I though a user would be interested in seeing
4. Support display a weather icon, caching is supported. 
5. Auto-load the last city searched upon app launch.
6. Ask the User for location access, If the User gives permission to access the location, then retrieve weather data by default.

**Extra Main Feature**

- Have the self-implemented latest recently used cache data structure to handle the search history with at most 5 items capacity. 
- Levarage the newly introduce UIMenu (iOS 14.0) to handle the city history list on same page. 

**Highlights**

- Runs on iPhone / ipad
- Supports Portrait and Landscape Orientation
- Support Dark and Light Appearance
- Accessibility Support
- Dynamic Type Support
- Well Documented Code
- Unit and UI Test cases
- No Thir party Libraries Used

 
## 🪵 Design

- Leverage the Model-View-ViewModel (MVVM) architecture as the backbone of the application. 
- Pull out the basic mechanism logic from fat UIViewController and generate the network layer class and data layer class. This part is based on the dependency injection to faciliate the UI and unit tests. 
- Even though we used the MVVM to make the code more testable and decopuled, the navigation will still be the pain point when introducing more features to the application. So, the coordinator design pattern should be future navigation problem killer for small to medium size project, like our JFWeatherAPP. 


*API call*
The application is supported by the API version 2.5. We will bump up the versionn to 3.0 (lasted one) soon. 

https://api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}

https://api.openweathermap.org/data/2.5/weather?q={city name},{country code}&appid={API key}

https://api.openweathermap.org/data/2.5/weather?q={city name},{state code},{country code}&appid={API key}


Reference: 
[https://docs.github.com/en/repositories/creating-and-managing-repositories/deleting-a-repository](https://github.com/anandgupadhyay/AUWeatherApp?ref=iosexample.com)

## 🐝 TODO:

- Accessiblity should be centralized. 
- Need locaization files. 
- User singleton could be used for the futurn app level configuration but making sure leveraging the dependency injection to faciliate the testing. 
- more UI/Unit test coverage. 
- More Error handing cases. 


## 🎥 User Interface (UI)

| Normal Mode | Dark Mode |
| --- | --- |
| ![Screenshot 2023-02-22 at 4 55 08 PM](https://user-images.githubusercontent.com/8815608/220801139-33dd4f15-8418-4672-9b72-ae78dfe07e89.png)] | ![Screenshot 2023-02-22 at 4 55 41 PM](https://user-images.githubusercontent.com/8815608/220801158-ab1af7ef-86a7-43ce-b202-a7eb9c86bfbb.png) |
| ![Screenshot 2023-02-22 at 4 55 18 PM](https://user-images.githubusercontent.com/8815608/220801184-09817070-34a7-42b5-8761-b53adcc6bdfd.png) | ![Screenshot 2023-02-22 at 4 55 49 PM](https://user-images.githubusercontent.com/8815608/220801204-364a18c7-eb9c-44c7-b475-5d61e74cafaa.png) |

History List lasted recently used (LRU) cache. sorted from latest to older one. 

| If limit is reached, remove the item from bottom | If item been search again, move it to top | selection will update weather UI and make it to top |
| --- | --- | --- |
| ![ezgif com-video-to-gif](https://user-images.githubusercontent.com/8815608/220802916-91edf224-1386-4e3c-a0be-3b2bcc341cd7.gif) | ![ezgif com-video-to-gif copy](https://user-images.githubusercontent.com/8815608/220802942-a9327666-4836-4c01-863f-fea8824808af.gif) | ![ezgif com-video-to-gif copy 2](https://user-images.githubusercontent.com/8815608/220802967-fa48fc84-57fc-4b8d-8c3b-995d7e58c075.gif) |


## 🦁 How to Run 

- Xcode 13.2.1 or Above
- Supported iOS 15.0 and above:
    Note: UIMenu is only supported at the iOS 14.0 above, the singleSelection for UIMenu start to support when 15.0
- Download Code or Clone the repository: 
- Open Project in Xcode
- Run on Simulator
  - Set Simulator as run device
  - Build and Run the App
  - To Simulate My Location on Simulator:
         On Simulator Menus select -> Features -> Location -> Custom Location -> add Lat :52.531677 and Lon :13.381777 
- Run on Real Device 
  - Under Project -> Targets -> Select JFWeatherApp -> Signing & Capabilities -> Select Team and Check Automatically Manage Signing
  - Build and Run app on device



