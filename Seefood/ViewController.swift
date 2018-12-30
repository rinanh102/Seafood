//
//  ViewController.swift
//  Seefood
//
//  Created by henry on 28/12/2018.
//  Copyright © 2018 HenryNguyen. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imgView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    // the userPickedImage is converted to CIInamge - pass into detect method as ciimage  - then put into handler to specify that is the one we wanna classify using our MLModel
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[.originalImage] as? UIImage{
            imgView.image = userPickedImage
            
            //MARK: - Convert UIImage to CIImage (CoreImage) -> the special type allow to use the Vision framework
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIImage to CIImage.")
            }
            
            //pass the ciimage to classify
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func detect(image: CIImage){
        // The class Inceptionv3 has the property called "model"
        // try? -> if the statement is succeed, it is gonna be wrap in an Optional
        //      -> if fail, the result will be nil -> So we are gonna wrap everything in the "guard statement". That means if the model is nil, the else statement will be triggered
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Loading CoreML Model FAILED.")
        }
        //VNCoreMLModel comes from Vision framework, that allows us to perform an image analysis requests, that uses our CoreML model to process images
        let request = VNCoreMLRequest(model: model) { (request, error) in
            //when the request has completed, it process the result of that request
            // the data type is [Any]? the array of any object --> downcast to an array of [VNClassificationObservation]
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image.")
            }
            print(results)
        }
        // We're going to create a handler that specifies the image we want to classify.
        let hander = VNImageRequestHandler(ciImage: image)
        do{
            try hander.perform([request])
        }catch{
            print(error)
        }
    }
    
    @IBAction func btnCamera(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

