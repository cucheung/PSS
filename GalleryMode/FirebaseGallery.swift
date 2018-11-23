//  FirebaseGallery.swift
//  Source used: https://github.com/Akhilendra/photosAppiOS

//  Description: Firebase Gallery Mode - This file handles fetching the images uploaded to Firebases

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  11/17/2018 - Created (based on Gallery Mode template)
//  11/23/2018 - Added Input/Output comments for appropiate functions
//  11/23/2018 - Refreshed imgArray in GalleryMode after the user presses the "Back" button to show newly downloaded images (Issue #4)

import UIKit
import Photos
import FirebaseStorage
import Firebase

// Firebase Gallery View Controller Class
class FirebaseGallery: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    // Initialize UICollectionView and image array to store fetched images from Firebase
    var FirebaseCollectionView: UICollectionView!
    var FirebaseimageArray=[UIImage]()
    
    // Function to run when View is loaded
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
        
        FirebaseCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        FirebaseCollectionView.delegate=self
        FirebaseCollectionView.dataSource=self
        FirebaseCollectionView.register(FirebasePhotoItemCell.self, forCellWithReuseIdentifier: "Cell")
        FirebaseCollectionView.backgroundColor=UIColor.white
        self.view.addSubview(FirebaseCollectionView)
        self.view.addSubview(backButton)
        
        FirebaseCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
        
        
        // Source: https://stackoverflow.com/a/27342233/10498067
        // Load Images from Firebase Database and store to FirebaseimageArray
        let ref = Database.database().reference().child("backup")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot
            {
                let url = rest.value as! String
                let storageRef = Storage.storage().reference(forURL: url)
                // 20MB limit on each photo
                storageRef.getData(maxSize: 20 * 1024 * 1024) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                    let pic = UIImage(data: data!)
                    self.FirebaseimageArray.append(pic!)
                    self.FirebaseCollectionView.reloadData()
                };
            }
        });
    }
    
    // Function determines the number of images in imgArray
    // Input: UICollectionView
    // Output: number of images in imgArray
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FirebaseimageArray.count
    }
    
    // Function determines the selected image in UICollectionView
    // Input: Integer index (of selected image)
    // Output: Cell of corresponding image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FirebasePhotoItemCell
        cell.img.image=FirebaseimageArray[indexPath.item]
        return cell
    }
    
    // Function to pass user selected image in Gallery to FirebaseImagePreview.swift
    // Input: indexPath (index) of selected image
    // Output: present() FirebaseImagePreview.swift (Image Preview)
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let vc=FirebaseImagePreviewVC()
        vc.imgArray = self.FirebaseimageArray
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
        FirebaseCollectionView.collectionViewLayout.invalidateLayout()
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
        // Notify GalleryMode to refresh its imgArray array to show newly downloaded image
        NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
        dismiss(animated: true)
    }
    
    // Checks whether or not a memory warning occured in any operation
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// Function to display each photo in a Cell
class FirebasePhotoItemCell: UICollectionViewCell {
    
    var img = UIImageView()
    
    // Configure Image Preview Frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        img.contentMode = .scaleAspectFill
        img.clipsToBounds=true
        self.addSubview(img)
    }
    
    // Set window bounds on image preview
    override func layoutSubviews() {
        super.layoutSubviews()
        img.frame = self.bounds
    }
    
    // Determine if archiving is enabled
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Checks orientation of app and adjusts preview based on orientation
struct FirebaseDeviceInfo {
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
