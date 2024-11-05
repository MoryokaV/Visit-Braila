# Visit Brăila

<img alt="Danube at Braila" src="https://user-images.githubusercontent.com/55505135/190634742-a9624d79-a607-4ee4-b927-9b22949596f4.png" width="280" height="280">

*Your personal guide for discovering the small community of Brăila, România* 📍

<a href="https://apps.apple.com/ro/app/visit-br%C4%83ila/id6448944001" target="_blank"><img height="70px" src="https://github.com/MoryokaV/Visit-Braila/assets/55505135/9637e193-29cd-4fc7-8be3-61f12574a56f"/></a> 
<a href="https://play.google.com/store/apps/details?id=com.vmasoftware.visit_braila" target="_blank"><img height="70px" src="https://github.com/MoryokaV/Visit-Braila/assets/55505135/f1d2ea6e-34dd-45ca-b924-fed597a644e2"/></a>

## Mobile App
***Visit Brăila*** connects citizens and tourists with each other. Sights, tours, restaurants, hotels and events have a common place to be promoted in. Beside tourists, this app is a great informational channel for history enthusiasts as our city is not valuing the fabulous architecture and historiography. Citizens stay in touch with the latest events running in their city by viewing them in app and getting a daily newsletter. With the contribution of the local authorities we can improve this city with the use of modern technology. 

### Screenshots
![app](https://github.com/MoryokaV/Visit-Braila/assets/55505135/9d4aa6f4-7a87-4ab2-bfd0-707775bb3932)

### [Demo video](https://youtu.be/LvU2oPzW-3w)

### Features
📲 Cross-platform compatibility: Android & iOS  
✏️ Responsive & Adaptive UI  
🔎 Search system  
💦 Native iOS & Android splash screen  
🌆 Network images caching  
💬 Firebase Cloud Messaging implementation  
🧲 Dynamic Links  
⚠️ Proper error & connectivity handling  
🧭 Real-time gps service  
✨ Blurhash image placeholder  

### Dependencies
- [firebase_core](https://pub.dev/packages/firebase_core), [firebase_dynamic_links](https://pub.dev/packages/firebase_dynamic_links), [firebase_messaging](https://pub.dev/packages/firebase_messaging): link between Firebase services and Flutter app
- [share_plus](https://pub.dev/packages/share_plus): native share popup
- [geolocator](https://pub.dev/packages/geolocator): geolocation api
- [flutter_html](https://pub.dev/packages/flutter_html): html content render
- [provider](https://pub.dev/packages/provider): state management
- [map_launcher](https://pub.dev/packages/map_launcher): maps app launcher at given coordinates
- [photo_view](https://pub.dev/packages/photo_view): gallery helper widget

### Cool stuff
- Adaptive Android app icon
- Rich text descriptions in HTML format
- MVC design pattern 
- Preferred maps app navigation
- Daily events newsletter
- Persistent wishlist items
- Smoothly animated widgets

### Requirements
```
- Android 5.1 or above (API level 22)
- iOS 12.0 or above
- 65Mb free storage space
- Internet connection
- Google Play Services installed (Android users only)
```

## CMS
Admin panel used by app owners to manage database entries. This custom tool is a GUI which helps you update content safely with validation, encryption and no technical skills. The CMS allows managers to keep their apps up-to-date in realtime with no need for consultation.

### Screenshots
![cms](https://github.com/MoryokaV/Visit-Braila/assets/55505135/c92fe9af-ab74-40f4-b329-77ab19c78635)

### Features
📝 Form validation using regexp  
💾 Real-time optimized server storage information  
🌆 Image file compression on upload  
✨ Pure CSS styles from scratch  
🔒 Encrypted login system with built-in “remember me” option  
⚡️  Blazing fast loading times  
♻️  Cross-browser support  
🖥 Fully responsive desktop-first UI  
🐧 Deployed on Ubuntu 22.04 server

### Dependencies
- [Quill.js](https://github.com/quilljs/quill) - editor for rich text in HTML format
- [Sortable.js](https://github.com/SortableJS/Sortable) - animated draggable list items

### Cool stuff
- Images get deleted automatically when not attached to a db document
- SHA-256 login encryption
- Multi-user support
- Tags get removed from sights automatically when deleted
- Trending - admin’s recommendations
- UI is inspired from [Admin LTE template](https://adminlte.io/)  
- Linux Cron Job for daily notifications
- MongoDB TTL events index for automatically deletion
- SSL certificate

## Tech Stack
- Backend:
  - MongoDB
  - Express.js
  - TypeScript
  - HTTP server: NGINX
  
- CMS Frontend:
  - Vite + React
  - Bootstrap 5
  - TypeScript
  
- Mobile App
  - Dart
  - Flutter Framework v3.24.4 stable
  - Local Storage API
  - Provider state management
  - Firebase
  - Geolocation API
