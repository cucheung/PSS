# Parkinsons Shutter System (PSS) [![Build Status](https://travis-ci.org/cucheung/PSS.svg?branch=master)](https://travis-ci.org/cucheung/PSS)

Parkinson’s Shutter System (PSS) is an iOS camera application designed to help Parkinson’s Disease (PD) patients take photographs. The application targets iOS 11 and is intended for iPhone 6, 6s, 7, and 8. 
As an affliction of the nervous system, PD causes tremors and loss of dexterity in its patients. The main goal of PSS is to improve camera ease of use for PD patients by offering an all-in-one replacement for taking, editing, viewing and sharing photos.

## Features:
#### Photo Mode:
* Captures 6 Photos and performs post-processing using OpenCV Lapacian Filter to select the best photo
* Camera Settings: Flash / Camera Selection / HVAA (Horizontal/Vertical Alignment Assistance - To capture photo when device is aligned relatively portrait / landscape)
* Sorts captured images based on clarity and allows user to select desired photos to save/delete

#### Gallery Mode:
* Ability to view last 50 photos saved on the device
* Ability to Share / Delete / Backup (to Google Firebase) photo
* Ability to view uploaded photos to Firebase and donwload them onto Device

#### Editor Mode:
* Uses PhotoEditorSDK
* Crop/Rotate/Filter/Levels adjustment

## Releases:

To download one of our releases, visit our release tab and download the 2018-3-CMPT275-Group-03_src.zip: https://github.com/cucheung/PSS/releases

## Developer Section:

### Cloning Repository from GitHub

1. Make sure Git LFS is installed: https://git-lfs.github.com 
2. Enter the following command in Terminal to clone the repository:
```
git lfs clone https://github.com/cucheung/PSS.git 
```

### Running PSS in Simulator

To run the Code in Simulator, select iPhone 8 and press the Play button (screenshot below):

![PSS Schema](https://i.imgur.com/FM6FdXg.png)

### Running Test Cases in Simulator

To run test cases in Simulator, select iPhone 8 and press the circular white play button located beside the test suite:

iPhone_UITest: Only suitable for physical iPhone device
Simulator_UITest: Only suitable for running in Simulator

![PSS Schema](https://i.imgur.com/tqvRLsE.png)

### Dependencies 

Pods Framework: Google Firebase (Google Utiliites/GTMSessionFetcher/nanopb/leveldb-library), PhotoEditor SDK


#### Sources used:
Gallery Mode Tile Preview (Modified with ability to preview any photo on grid): https://github.com/Akhilendra/photosAppiOS

Photo Capture functionality: https://github.com/appcoda/FullScreenCamera

OpenCV Blur Detection Algorithm (Laplace): https://stackoverflow.com/a/40589477/10498067

Fetching Photos for ProcessPhotos: https://stackoverflow.com/questions/28259961/swift-how-to-get-last-taken-3-photos-from-photo-library 

Delete Photo Functionality: https://stackoverflow.com/questions/29466866/how-to-delete-the-last-photo-in-swift-ios8 

Share Functionality: https://stackoverflow.com/a/49192691/10498067

Iterrating over Firebase DB (to show Firebase Gallery): https://stackoverflow.com/a/27342233/10498067
