# Firebase

Firebase is a technology that allows you to create web applications without server-side programming, making development faster and easier. It supports Web, iOS, OS X and Android clients. Apps that use Firebase can use and control data without thinking about how data is stored and synchronized across different instances of the application in real-time.

#### Working with Firebase from a developer's perspective is a wonderful benefit, as they are the core technology of development.

* Advantages:
Authentication. Firebase authentication includes a built-in email/password authentication system. It supports OAuth2 for Facebook, Google, Twitter and GitHub. Additionally, the Firebase standard integrates directly into the Firebase database so that you can use it to control access to your data. Hosting. Firebase comes with an easy-to-use hosting service for all your static files. It works from a global CDN with HTTP / 2. Real-time synchronization of data across all clients, be it Android, iOS or the Web, is very useful. With minimal code, you can notify users of chat boxes, live news feeds, new posts or friend requests, and more. The code for AJS is straightforward in any way. From querying data to integrating Twitter, Facebook and Google+ logins, you can implement it very quickly with some nice features. With automatic update notifications, it can sync both systems without manual messaging, WebSockets, etc. Allows you to consider data streams to create more scalable applications.

* Some benefits of using Firebase
Firebase Real-Time Database Firebase standard Firebase storage Firebase Cloud Message Firebase notification Firebase Remote Config Firebase Crash Report Firebase Application Index Firebase Analytics Firebase Test Lab for Android

## Add Firebase to your iOS project

### Prerequisites

* Install the following:
Xcode 10.3 or later CocoaPods 1.4.0 or later

* Make sure that your project meets these requirements:
Your project must target iOS 8 or later.

* Set up a physical iOS device or use the iOS simulator to run your app.

### Do you want to use Cloud Messaging?

* Sign into Firebase using your Google account.

## Step 1: 
Create a Firebase project Before you can add Firebase to your iOS app, you need to create a Firebase project to connect to your iOS app. Visit Understand Firebase Projects to learn more about Firebase projects.

Create a Firebase project

## Step 2: 
Register your app with Firebase After you have a Firebase project, you can add your iOS app to it.
Visit Understand Firebase Projects to learn more about best practices and considerations for adding apps to a Firebase project, including how to handle multiple build variants.

#### 1- Go to the Firebase console. 

#### 2- In the center of the project overview page, click the iOS icon (plat_ios) to launch the setup workflow.

If you've already added an app to your Firebase project, click Add app to display the platform options.

#### 3- Enter your app's bundle ID in the iOS bundle ID field.

What's a bundle ID, and where do you find it?

Make sure to enter the bundle ID that your app is actually using. The bundle ID value is case-sensitive, and it cannot be changed for this Firebase iOS app after it's registered with your Firebase project. 

#### 4- (Optional) Enter other app information: App nickname and App Store ID.

How are the App nickname and the App Store ID used within Firebase?

#### 5- Click Register app.

## Step 3: 
Add a Firebase configuration file 

#### 1- Click Download GoogleService-Info.plist to obtain your Firebase iOS config file (GoogleService-Info.plist).
What do you need to know about this config file?

#### 2- Move your config file into the root of your Xcode project. If prompted, select to add the config file to all targets.

If you have multiple bundle IDs in your project, you must associate each bundle ID with a registered app in the Firebase console so that each app can have its own GoogleService-Info.plist file.

## Step 4: 
Add Firebase SDKs to your app We recommend using CocoaPods to install the Firebase libraries. However, if you'd rather not use CocoaPods, you can integrate the SDK frameworks directly.

Are you using one of the quickstart samples? The Xcode project and Podfile (with pods) are already present, but you'll still need to add your Firebase configuration file and install the pods.

#### 1- Create a Podfile if you don't already have one: $ cd your-project-directory

$ pod init

#### 2- To your Podfile, add the Firebase pods that you want to use in your app.

You can add any of the supported Firebase products to your iOS app.

Add the Firebase pod for Google Analytics pod 'Firebase/Analytics'

Add the pods for any other Firebase products you want to use in your app

For example, to use Firebase Authentication and Cloud Firestore pod 'Firebase/Auth' pod 'Firebase/Firestore'

#### 3- Install the pods, then open your .xcworkspace file to see the project in Xcode:

$ pod install

$ open your-project.xcworkspace

## Step 5: 
Initialize Firebase in your app

The final step is to add initialization code to your application. You may have already done this as part of adding Firebase to your app. If you're using a quickstart sample project, this has been done for you.

#### 1- Import the Firebase module in your UIApplicationDelegate: Swift

$ import Firebase

#### 2- Configure a FirebaseApp shared instance, typically in your app's application:didFinishLaunchingWithOptions: method: Swift

// Use Firebase library to configure APIs $ FirebaseApp.configure()

#### 3- If you've included Firebase Analytics, you can run your app to send verification to the Firebase console that you've successfully installed Firebase. That's it! You can skip ahead to the next steps.
