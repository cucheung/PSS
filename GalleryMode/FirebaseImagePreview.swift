//  FirebaseImagePreviewVC.swift
//  Sources used: https://github.com/Akhilendra/photosAppiOS, https://stackoverflow.com/a/49192691/10498067 (Share button), https://stackoverflow.com/questions/29466866/how-to-delete-the-last-photo-in-swift-ios8 (Modified to Delete specific Photos)

//  Description: Image Preview for Firebase in Gallery. The following Swift file handles the following features: Share / Back

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  Known Bug(s): When selecting the "Delete" button in ImagePreview.swift, the gallery mode view still shows the deleted photo (GitHub Issue #2)

//  All changes are marked with "CMPT275" (no quotes)
//  Changes:
//  11/17/2018 - Removed Share and Delete Button in this preview
//  11/22/2018 - Firebase Image Functionality + Comments
//  11/24/2018 - Fixed Warnings in code

import UIKit
import FirebaseStorage // CMPT 275 - Import Firebase library
import Firebase
import Foundation
import Photos

// Firebase Image Gallery Controller Class
class FirebaseImagePreviewVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    // Initialize variables
    var myCollectionView: UICollectionView! // Initialize CollectionView
    var imgArray = [UIImage]() // UIImage array used to store images fetched from Firebase passed from FirebaseGallery.swift
    var imgOffset: Int! // Used to determine selected image index
    var imgIndex: UIImage! // Used to store selected image
    
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
    let DownloadPhoto: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        let xPostion:CGFloat = 210
        let yPostion:CGFloat = 30
        let buttonWidth:CGFloat = 150
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.setTitle("Download", for: .normal)
        button.addTarget(self, action: #selector(DownloadFBPhoto), for: .touchUpInside)
        return button
    }()
    
    // CMPT275 - Button to Share Photo
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.white
        let xPostion:CGFloat = 10
        let yPostion:CGFloat = 600
        let buttonWidth:CGFloat = 350
        let buttonHeight:CGFloat = 45
        button.frame = CGRect(x:xPostion, y:yPostion, width:buttonWidth, height:buttonHeight)
        button.setTitle("Share", for: .normal)
        button.addTarget(self, action: #selector(shareOnlyImage), for: .touchUpInside)
        return button
    }()
    
    // Function to run when View is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // CMPT275 - Changed background colour to white from black
        self.view.backgroundColor=UIColor.white
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing=0
        layout.minimumLineSpacing=0
        layout.scrollDirection = .horizontal
        
        myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        myCollectionView.delegate=self
        myCollectionView.dataSource=self
        myCollectionView.register(FirebaseImagePreviewFullViewCell.self, forCellWithReuseIdentifier: "Cell")
        // CMPT275 - Added isScrollEnabled
        myCollectionView.isScrollEnabled = false
    
        self.view.addSubview(myCollectionView)
        
        // CMPT275 - Display buttons
        self.view.addSubview(shareButton)
        self.view.addSubview(backButton)
        self.view.addSubview(DownloadPhoto)
        
        myCollectionView.autoresizingMask = UIViewAutoresizing(rawValue: UIViewAutoresizing.RawValue(UInt8(UIViewAutoresizing.flexibleWidth.rawValue) | UInt8(UIViewAutoresizing.flexibleHeight.rawValue)))
    }
    
    // Function determines the number of images in imgArray
    // Input: UICollectionView
    // Output: number of images in imgArray
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    // Function determines the selected image in UICollectionView
    // Input: Integer index (of selected image)
    // Output: Cell of corresponding image
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! FirebaseImagePreviewFullViewCell
        // CMPT 275 - Preview image
        let rowNumber : Int = imgOffset
        cell.imgView.image=imgArray[rowNumber]
        imgIndex = imgArray[rowNumber]
        return cell
    }
    
    // Configure UICollectionView frame size
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        flowLayout.itemSize = myCollectionView.frame.size
        
        flowLayout.invalidateLayout()
        
        myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    // Configure UICollectionView view size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let offset = myCollectionView.contentOffset
        let width  = myCollectionView.bounds.size.width
        
        let index = round(offset.x / width)
        let newOffset = CGPoint(x: index * size.width, y: offset.y)
        
        myCollectionView.setContentOffset(newOffset, animated: false)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.myCollectionView.reloadData()
            
            self.myCollectionView.setContentOffset(newOffset, animated: false)
        }, completion: nil)
    }
    
    // CMPT275 - Back Button
    // Input: NULL
    // Output: Dismiss view
    @objc func dismissView() {
        dismiss(animated: true)
    }
    
    // CMPT275 - Share (modified to select the correct image in image array)
    // Input: NULL
    // Output: present() Share Menu
    @objc func shareOnlyImage() {
        let imageShare =  [imgIndex]
        let activityViewController = UIActivityViewController(activityItems: imageShare as [Any] , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // CMPT275 - Download Firebase Photo
    // Input: NULL
    // Output: Completion flag whether or not image was downloaded successfully
    @objc func DownloadFBPhoto() {
        let FBImage =  imgIndex
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: FBImage!)
        }, completionHandler: { success, error in
            if success {
                let alertController = UIAlertController(title: "Success!", message: "Photo Downloaded Successfully!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Failed!", message: "Photo was not downloaded! Please Try Again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
    

    // Function deletes Photo on device of specified index
    // Input: Index of photo to delete
    // Output: NULL
    @objc func deleteImage() {
        // Fetch Photo Gallery
        let requestOptions=PHImageRequestOptions()
        requestOptions.isSynchronous=true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions=PHFetchOptions()
        fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Find corresponding photo to delete via index
        let rowNumber : Int = imgOffset
        let lastAsset: PHAsset = fetchResult.object(at: rowNumber)
        let arrayToDelete = NSArray(object: lastAsset)
            
        // Perform delete operation
        PHPhotoLibrary.shared().performChanges( {
            PHAssetChangeRequest.deleteAssets(arrayToDelete)},
                completionHandler: {
                success, error in
            })
        dismiss(animated: true, completion: nil)
    }
}

// Setup Image Preview Cell
class FirebaseImagePreviewFullViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var scrollImg: UIScrollView!
    var imgView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollImg = UIScrollView()
        scrollImg.delegate = self
        scrollImg.alwaysBounceVertical = false
        scrollImg.alwaysBounceHorizontal = false
        scrollImg.showsVerticalScrollIndicator = true
        scrollImg.flashScrollIndicators()
        
        scrollImg.minimumZoomScale = 1.0
        scrollImg.maximumZoomScale = 4.0
        
        // Configue double tap to zoom on image
        let doubleTapGest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapScrollView(recognizer:)))
        doubleTapGest.numberOfTapsRequired = 2
        scrollImg.addGestureRecognizer(doubleTapGest)
        
        self.addSubview(scrollImg)
        
        imgView = UIImageView()
        imgView.image = UIImage(named: "user3")
        scrollImg.addSubview(imgView!)
        imgView.contentMode = .scaleAspectFit
    }
    
    // Configures double-tap to zoom
    // Input: Double-tap on screen from user
    // Output: Zoomed in image preview
    @objc func handleDoubleTapScrollView(recognizer: UITapGestureRecognizer) {
        if scrollImg.zoomScale == 1 {
            scrollImg.zoom(to: zoomRectForScale(scale: scrollImg.maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollImg.setZoomScale(1, animated: true)
        }
    }
    
    
    // Configure zoom preview area
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollImg)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollImg.frame = self.bounds
        imgView.frame = self.bounds
    }
    
    // Clean up view when zooming into view to provide zoomed in image
    override func prepareForReuse() {
        super.prepareForReuse()
        scrollImg.setZoomScale(1, animated: true)
    }
    
    // Determine if archiving is enabled
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

