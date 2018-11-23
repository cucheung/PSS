//  EditorMode.swift
//  Source used: https://github.com/Akhilendra/photosAppiOS

//  Description: Editor Mode - This file handles fetching the images from device and displaying it onto the screen in a grid

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  11/17/2018 - Created (imported from GalleryMode.swift)
//  11/17/2018 - Moved Photo Access request to viewDidLoad()
//  11/17/2018 - Fixed photo load on 2nd run when Photo Access is already granted
//  11/17/2018 - Initial PhotoEditorSDK Implementation
//  11/23/2018 - Added Input/Output comments for appropiate functions

import UIKit
import Photos
import PhotoEditorSDK

// Editor View Controller class
class Editor: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, PhotoEditViewControllerDelegate {
    
    // CMPT275 - Save Edited Photo into Storage
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { success, error in
            if success {
                NSLog("Saved Photo")
            } else {
                NSLog("Failed Saving Photo")
            }
        })
        dismiss(animated: true, completion: nil)
    }
    
    // CMPT275 - Present error if failed generating an Output Photo
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        let alertController = UIAlertController(title: "Error", message: "Failed Creating Output Image", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // CMPT275 - Dismiss View if user clicks cancel button
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    var EditorCollectionView: UICollectionView!
    var imageArray=[UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CMPT275 - Back button
        let backButton: UIButton = {
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            let xPostion:CGFloat = 10
            let yPostion:CGFloat = 30
            let buttonWidth:CGFloat = 350
            let buttonHeight:CGFloat = 45
            button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
            button.setTitle("Back", for: .normal)
            button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
            return button
        }()
        
        // Setup Collection View Grid for Gallery
        let layout = UICollectionViewFlowLayout()
        
        EditorCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        EditorCollectionView.delegate=self
        EditorCollectionView.dataSource=self
        EditorCollectionView.register(EditorModeItemCell.self, forCellWithReuseIdentifier: "Cell")
        EditorCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(EditorCollectionView)
        self.view.addSubview(backButton)
        
        EditorCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
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
    
    // CMPT275 - Configure Editor Mode Settings
    // Input: NULL
    // Output: Font settings and editing capabilities of editor passed into calling function
    private func buildConfiguration() -> Configuration {
        let configuration = Configuration() { builder in
            builder.configurePhotoEditorViewController { options in
                options.actionButtonConfigurationClosure = { cell, menuItem in
                    cell.captionTintColor = UIColor.white
                    cell.captionLabel.highlightedTextColor = UIColor.yellow
                    cell.captionLabel.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 20)
                }
            }
            // Configure camera
            builder.configureCameraViewController() { options in
                // Just enable Photos
                options.allowedRecordingModes = [.photo]
            }
        }
        
        return configuration
    }
    
    // CMPT275 - Toolbar items for Editor Mode
    // Input: NULL
    // Output: Supported tools to display passed back to calling function
    public var toolItems: [PhotoEditMenuItem] {
        let menuItems: [MenuItem?] = [
            ToolMenuItem.createTransformToolItem(),
            ToolMenuItem.createFilterToolItem(),
            ToolMenuItem.createAdjustToolItem()
        ]
        
        let photoEditMenuItems: [PhotoEditMenuItem] = menuItems.compactMap { menuItem in
            switch menuItem {
            case let menuItem as ToolMenuItem:
                return .tool(menuItem)
            default:
                return nil
            }
        }
        return photoEditMenuItems
    }
    
    // CMPT275 - Setup Editor Mode item view controller
    // Input: UIImage of the photo to edit
    // Output: PhotoEditorSDK View Controller of editor
    private func createPhotoEditViewController(with photo: Photo) -> PhotoEditViewController {
        // Obtain Configuration
        let configuration = buildConfiguration()
        // Obtain tools supported in PhotoEditorSDK
        let menuItems = toolItems
        
        // Create a photo edit view controller
        let photoEditViewController = PhotoEditViewController(photoAsset: photo, configuration: configuration, menuItems: menuItems)
        photoEditViewController.delegate = self as? PhotoEditViewControllerDelegate
        
        return photoEditViewController
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
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EditorModeItemCell
        cell.img.image=imageArray[indexPath.item]
        return cell
    }
    
    // Function to pass user selected image in Gallery to FirebaseImagePreview.swift
    // Input: indexPath (index) of selected image
    // Output: present() PhotoEditorSDK with selected image
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // CMPT275 - Modified to push photo to Photo Editor
        let photo = Photo(image: imageArray[indexPath.row])
        present(createPhotoEditViewController(with: photo), animated: true)
    }
    
    // Function to set grid size for image gallery Preview
    // Input: indexPath (image cell index)
    // Output: Return cell size dimensions (type CGSize)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if EditorModeDeviceInfo.Orientation.isPortrait {
            // CMPT275 - Modified grid size (default:4 override: 2)
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    // Detect when View Controller changes its subviews to generate a new whole View
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        EditorCollectionView.collectionViewLayout.invalidateLayout()
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
                // Error if no photos are found
                // TODO: Add Alert Dialog
                print("You got no photos.")
            }
            print("imageArray count: \(self.imageArray.count)")
            
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.EditorCollectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// Function to display each photo in a Cell
class EditorModeItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    
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
struct EditorModeDeviceInfo {
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
