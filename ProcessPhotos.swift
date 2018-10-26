//  ProcessPhotos.swift
//  Sources used: https://stackoverflow.com/questions/28259961/swift-how-to-get-last-taken-3-photos-from-photo-library (Fetch Photo)

//  Description: This View is displayed after photos are captured
//  Performs the Following Actions: Process Photo in OpenCV / Display processed photos / Delete selected pictures

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung

//  Changes:
//  10/25/2018 - Added UI Layout, deletePhoto functionality

import Photos

class ProcessPhotos: UIViewController {
    
    var images:[UIImage] = []
    var selectedImg:[Int] = []
    
    @IBOutlet var Image_1: UIImageView!
    @IBOutlet var Image_2: UIImageView!
    @IBOutlet var Image_3: UIImageView!
    @IBOutlet var Image_4: UIImageView!
    @IBOutlet var Image_5: UIImageView!
    @IBOutlet var Image_6: UIImageView!
    @IBOutlet var Button_1: UISwitch!
    @IBOutlet var Button_2: UISwitch!
    @IBOutlet var Button_3: UISwitch!
    @IBOutlet var Button_4: UISwitch!
    @IBOutlet var Button_5: UISwitch!
    @IBOutlet var Button_6: UISwitch!
    @IBOutlet var Save: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
        
        // Display captured images
        Image_1.image = images[0]
        Image_2.image = images[1]
        Image_3.image = images[2]
        Image_4.image = images[3]
        Image_5.image = images[4]
        Image_6.image = images[5]
        
        // Enlarge Button by 1.25x for ease of use
        Button_1.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_2.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_3.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_4.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_5.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        Button_6.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        
        // Set Buttons to Off for Initial State
        Button_1.setOn(false, animated: true)
        Button_2.setOn(false, animated: true)
        Button_3.setOn(false, animated: true)
        Button_4.setOn(false, animated: true)
        Button_5.setOn(false, animated: true)
        Button_6.setOn(false, animated: true)
        
        Save.addTarget(self, action: #selector(savePhotos), for: .touchUpInside)
    }
    
    // CMPT275 - Function to Delete selected photos
    @objc func savePhotos() {
        
        // Determine which photo switch is on and add to array
        var Switch_arr:[Bool] = [false,false,false,false,false,false]
        if (Button_1.isOn)
        {
            Switch_arr[0] = true
        }
        if (Button_2.isOn)
        {
            Switch_arr[1] = true
        }
        if (Button_3.isOn)
        {
            Switch_arr[2] = true
        }
        if (Button_4.isOn)
        {
            Switch_arr[3] = true
        }
        if (Button_5.isOn)
        {
            Switch_arr[4] = true
        }
        if (Button_6.isOn)
        {
            Switch_arr[5] = true
        }
        for index in 0...5 {
            if (Switch_arr[index] == true)
            {
                deleteImage(index: index)
            }
        }
        // Return back to Viewfinder
        dismiss(animated: true)
        
    }
    
    func deleteImage(index : Int) {
        // Fetch Photo Gallery
        let requestOptions=PHImageRequestOptions()
        requestOptions.isSynchronous=true
        requestOptions.deliveryMode = .highQualityFormat
        
        let fetchOptions=PHFetchOptions()
        fetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
        
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        // Find corresponding photo to delete via index
        if (fetchResult.object(at: index) != nil) {
            var lastAsset: PHAsset = fetchResult.object(at: index) as! PHAsset
            let arrayToDelete = NSArray(object: lastAsset)
            
            // Perform delete operation
            PHPhotoLibrary.shared().performChanges( {
                PHAssetChangeRequest.deleteAssets(arrayToDelete)},
                                                    completionHandler: {
                                                        success, error in
            })
        }
    }
    
    
    
    func fetchPhotos () {
        // Sort the images by descending creation date and fetch the first 3
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 6
        
        // Fetch the image assets
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            let totalImageCountNeeded = 6 // <-- The number of images to fetch
            fetchPhotoAtIndex(0, totalImageCountNeeded, fetchResult)
        }
    }

    // Repeatedly call the following method while incrementing
    // the index until all the photos are fetched
    func fetchPhotoAtIndex(_ index:Int, _ totalImageCountNeeded: Int, _ fetchResult: PHFetchResult<PHAsset>) {
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        // Perform the image request
        PHImageManager.default().requestImage(for: fetchResult.object(at: index) as PHAsset, targetSize: view.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
            if let image = image {
                // Add the returned image to your array
                self.images += [image]
            }
            // If you haven't already reached the first
            // index of the fetch result and if you haven't
            // already stored all of the images you need,
            // perform the fetch request again with an
            // incremented index
            if index + 1 < fetchResult.count && self.images.count < totalImageCountNeeded {
                self.fetchPhotoAtIndex(index + 1, totalImageCountNeeded, fetchResult)
            } else {
                // Else you have completed creating your array
                print("Completed array: \(self.images)")
            }
        })
    }
}
