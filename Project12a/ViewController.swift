//
//  ViewController.swift
//  Project10_NamesToFaces
//
//  Created by Sabrina Fletcher on 2/19/18.
//  Copyright © 2018 Sabrina Fletcher. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data{
            people = NSKeyedUnarchiver.unarchiveObject(with: savedPeople) as! [Person]
        }
//        defaults.set(25, forKey: "Age")
//        defaults.set(true, forKey: "UseTouchID")
//        defaults.set(CGFloat.pi, forKey: "Pi")
//        defaults.set("Paul Hudson", forKey: "Name")
//        defaults.set(Date(), forKey: "LastRun")
//
//        let array = ["Hello", "World"]
//        defaults.set(array, forKey: "savedArray")
//
//        let dict = defaults.object(forKey: "SavedDict") as? [String:String] ?? [String:String]()
//        let dict = ["Name": "Paul", "Country": "UK"]
//        defaults.set(dict, forKey: "SavedDict")
    
        
    }
    
    func save() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: people)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "people")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let choice = UIAlertController(title: "Rename person or Delete?", message: "Would you like to delete the photo or rename the photo?", preferredStyle: .alert)
        choice.addAction(UIAlertAction(title: "Rename", style: .default) {
            [unowned self] _ in
            
            let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            
            ac.addTextField()
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            ac.addAction(UIAlertAction(title: "OK", style: .default) {
                [unowned self, ac] _ in
                let newName = ac.textFields![0]
                person.name = newName.text!
                
                self.collectionView?.reloadData()
                self.save()
            })
            
            self.present(ac,animated: true)
            
        })
        
        choice.addAction(UIAlertAction(title: "Delete", style: .destructive) {
            [unowned self] _ in
            
            let ac = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "Yes", style: .destructive){
                [unowned self] _ in
                self.people.remove(at: indexPath.item)
                self.collectionView?.reloadData()
                self.save()
            })
            
            ac.addAction(UIAlertAction(title: "No", style: .cancel))
            
            self.present(ac,animated: true)
        })
        
        present(choice,animated: true)
        

    }
    
    @objc func addNewPerson(){
        let picker = UIImagePickerController()
        let alert = UIAlertController(title: "Import From...", message: nil, preferredStyle: .actionSheet)
        
        let libButton = UIAlertAction(title: "Select photo from Library", style: .default) { (alert) -> Void in
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
    if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
        let cameraButton = UIAlertAction(title: "Take a picture", style: .default) {
                (alert) -> Void in
            print("Take photo")
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = false
            picker.modalPresentationStyle = .fullScreen
            self.present(picker, animated: true, completion: nil)
            
        }
        alert.addAction(cameraButton)
        
    } else{
        print("Camera Not Available")
    }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) {
            (alert) -> Void in
            print("Cancel Pressed")
        }
        
        alert.addAction(libButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
        
        
        picker.allowsEditing = true
        picker.delegate = self
        alert.popoverPresentationController?.sourceView = self.view
        present(picker,animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = UIImageJPEGRepresentation(image, 80){
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView?.reloadData()
        save()
        
        dismiss(animated: true)

    }
    
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
        
    }


}

