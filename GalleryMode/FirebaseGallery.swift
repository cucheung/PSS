//  FirebaseGallery.swift
//  Source used: https://github.com/Akhilendra/photosAppiOS

//  Description: Firebase Gallery Mode - This file handles fetching the images uploaded to Firebases

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  11/17/2018 - Created

import UIKit
import Photos
import FirebaseStorage
import Firebase


class FirebaseGallery: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate {
    
    var FirebaseCollectionView: UICollectionView!
    var FirebaseimageArray=[UIImage]()
    
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
        let ref = Database.database().reference().child("backup")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot.childrenCount)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot
            {
                let url = rest.value as! String
                let storageRef = Storage.storage().reference(forURL: url)
                storageRef.getData(maxSize: 20 * 1024 * 1024) { (data, error) -> Void in
                    // Create a UIImage, add it to the array
                    let pic = UIImage(data: data!)
                    self.FirebaseimageArray.append(pic!)
                    self.FirebaseCollectionView.reloadData()
                };
            }
        });
    }
    
    //MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FirebaseimageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FirebasePhotoItemCell
        cell.img.image=FirebaseimageArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        let vc=FirebaseImagePreviewVC()
        vc.imgArray = self.FirebaseimageArray
        // CMPT 275 - Obtain index of Photo
        vc.imgOffset = indexPath.row
        present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if DeviceInfo.Orientation.isPortrait {
            // CMPT275 - Modified grid size (default:4 override: 2)
            return CGSize(width: width/2 - 1, height: width/2 - 1)
        } else {
            return CGSize(width: width/6 - 1, height: width/6 - 1)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        FirebaseCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // CMPT275 - Back Button
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
    
    //MARK: grab photos
    func grabFirebasePhotos(){

            print("FireimageArray count: \(self.FirebaseimageArray.count)")
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                self.FirebaseCollectionView.reloadData()
            }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// Function to display each photo in a Cell
class FirebasePhotoItemCell: UICollectionViewCell {
    
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
