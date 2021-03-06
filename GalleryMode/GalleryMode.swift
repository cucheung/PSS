//  GalleryMode.swift
//  Source used: https://github.com/Akhilendra/photosAppiOS

//  Description: Gallery Mode - This file handles fetching the images from device and displaying it onto the screen

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  10/14/2018 - Added Google Firebase Cloud Backup implementation, Share option for each Photo
//  10/15/2018 - Added Delete Functionality (currently does not delete the correct photo)
//  10/25/2018 - Code Cleanup (comments)
//  10/25/2018 - Added Back Button
//  10/27/2018 - Updated Description, Pass imgOffset variable to ImagePreview
//  10/29/2018 - Added Photo Fetch limit to 50 to avoid memory leak
//  11/04/2018 - Display Error Prompt if Gallery Access is not granted
//  11/17/2018 - Moved Photo Access request to viewDidLoad()
//  11/17/2018 - Fixed photo load on 2nd run when Photo Access is already granted (Issue #3)
//  11/19/2018 - Fixed Delete Photo Issue where deleted photo still appears in view by adding observer in this class to detect delete operation (Issue #2)
//  11/23/2018 - Added Input/Output comments for appropiate functions

import UIKit
import Photos

// Gallery View Controller class
class Gallery: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {

    // Initialize UICollectionView and image array to store fetched images from Storage
    var myCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    
    // Function to run when View is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CMPT275 - Add Observer to detect whether photo is deleted in ImagePreview.swift
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        // CMPT275 - Back button
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            let xPostion:CGFloat = 10
            let yPostion:CGFloat = 30
            let buttonWidth:CGFloat = 150
            let buttonHeight:CGFloat = 45
            button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
            button.setTitle("Back", for: .normal)
            button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
            return button
        }()
        
        // CMPT275 - Firebase Gallery button
        let FBGallery: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            let xPostion:CGFloat = 210
            let yPostion:CGFloat = 30
            let buttonWidth:CGFloat = 150
            let buttonHeight:CGFloat = 45
            button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
            button.setTitle("Firebase", for: .normal)
            button.addTarget(self, action: #selector(LoadFBGallery), for: .touchUpInside)
            return button
        }()
        
        // Setup Collection View Grid for Gallery
        let layout = UICollectionViewFlowLayout()
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        myCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(myCollectionView)
        self.view.addSubview(backButton)
        self.view.addSubview(FBGallery)
        
        myCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
        // Obtain pictures from device storage
        //Request Photo Access
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .authorized{
            self.grabPhotos()
        }
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.grabPhotos()
                } else {
                    let alertController = UIAlertController(title: "Error", message: "No Gallery Access", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    // Function determines the number of images in imgArray
    // Input: UICollectionView
    // Output: number of images in imgArray
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    // Function determines the selected image in UICollectionView
    // Input: Integer index (of selected image)
    // Output: Cell of corresponding image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoItemCell
        cell.img.image=imageArray[indexPath.item]
        return cell
    }
    
    // Function to pass user selected image in Gallery to FirebaseImagePreview.swift
    // Input: indexPath (index) of selected image
    // Output: present() ImagePreview.swift (Image Preview) of selected image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let vc=ImagePreviewVC()
        vc.imgArray = self.imageArray
        // CMPT 275 - Obtain index of Photo
        vc.imgOffset = indexPath.row
        present(vc, animated: true)
    }
    
    // Function to set grid size for image gallery Preview
    // Input: indexPath (image cell index)
    // Output: Return cell size dimensions (type CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if DeviceInfo.Orientation.isPortrait {
            // CMPT275 - Modified grid size (default:4 override: 2)
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    // Detect when View Controller changes its subviews to generate a new whole View
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // Configure spacing between rows/columns in Image Gallery
    // Input: NULL
    // Output: Return spacing distance back to collectionView (in this case: 1px)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }

    // Configure spacing between items (photo preview) in Image Gallery
    // Input: NULL
    // Output: Return spacing distance back to collectionView (in this case: 1px)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // CMPT275 - Back Button
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
    // CMPT275 - Load Firebase Gallery Button
    // Input: NULL
    // Output: present() FirebaseGallery View Controller
    @objc func LoadFBGallery() {
        let vc = FirebaseGallery()
        self.present(vc, animated: true)
    }
    
    // CMPT275 - Reload Gallery View after when observer is signaled (after deleting photo or after downloading images from Firebase)
    @objc func loadList(notification: NSNotification) {
        grabPhotos()
    }
    
    
    // Obtain photos stored in Storage and store to imageArray
    func grabPhotos(){
        imageArray = []
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            // Configure fetch options (Quality, Fetch order)
            let imgManager=PHImageManager.default()
            
            let requestOptions=PHImageRequestOptions()
            requestOptions.isSynchronous=true
            requestOptions.deliveryMode = .highQualityFormat
            let fetchOptions=PHFetchOptions()
            // CMPT275 - Added Fetch Limit to prevent memory leak
            fetchOptions.fetchLimit = 50
            fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            print(fetchResult)
            print(fetchResult.count)
            // Store fetched photos into an array
            if fetchResult.count > 0 {
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
                        self.imageArray.append(image!)
                    })
                }
            } else {
                print("You got no photos.")
            }
            print("imageArray count: \(self.imageArray.count)")
            
            // Reload myCollectionView after imageArray is fetched
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.myCollectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Function to display each photo in a Cell
class PhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    
    // Configure Image Grid size/preview
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Checks orientation of app and adjusts preview based on orientation
struct DeviceInfo {
    struct Orientation {
        // indicate current device is in the LandScape orientation
        static var isLandscape: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isLandscape
                    : UIApplication.shared.statusBarOrientation.isLandscape
            }
        }
        // indicate current device is in the Portrait orientation
        static var isPortrait: Bool {
            get {
                return UIDevice.current.orientation.isValidInterfaceOrientation
                    ? UIDevice.current.orientation.isPortrait
                    : UIApplication.shared.statusBarOrientation.isPortrait
            }
        }
    }
}
