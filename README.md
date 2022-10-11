# Visit-Braila

<img alt="Danube at Braila" src="https://user-images.githubusercontent.com/55505135/190634742-a9624d79-a607-4ee4-b927-9b22949596f4.png" width="280" height="280">

*Your personal guide for discovering the small community of Brăila, România* 📍

## CMS
Admin panel used by app owners to manage database entries. This custom tool is a GUI which helps you update content safely with validation, encryption and no technical skills. The CMS allows managers to keep their apps up-to-date in realtime with no need for consultation.

### Screenshots
![all white bg](https://user-images.githubusercontent.com/55505135/185123116-4d9f7fe0-b61b-4f40-9cc0-e70a9fc88557.png)

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
- MD5 login details encryption
- Tags get removed from sights automatically when deleted
- Trending - admin’s recommendations
- UI is inspired from [Admin LTE template](https://adminlte.io/) and Bootstrap 5

## Tech Stack used:
- Backend:
  - MongoDB
  - Python3 + Flask
  - HTTP server: uWSGI & NGINX
  
- CMS Frontend:
  - HTML & CSS
  - JavaScript + jQuery 3.6.0 (AJAX calls, manipulate DOM)
  
- Mobile App Frontend:
  - Flutter
  - Google Maps API
  - Sqflite
  - Provider
