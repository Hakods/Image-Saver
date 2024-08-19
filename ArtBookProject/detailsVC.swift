import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var yearText: UITextField!
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    
    override func viewDidLoad() {
        
        if chosenPainting != ""
        {
            saveButton.isHidden = true
            
            
            //Core Data'dan çekilen verileri yazdıracağız.
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            
           do
           {
               let results = try context.fetch(fetchRequest)
               
               if results.count > 0
               {
                   for result in results as! [NSManagedObject]
                   {
                       if let name = result.value(forKey: "name") as? String
                       {
                           nameText.text = name
                       }
                       if let artist = result.value(forKey:"artist") as? String
                       {
                           artistText.text = artist
                       }
                       if let year = result.value(forKey: "year") as? Int
                       {
                           yearText.text = String(year)
                       }
                       if let imageData = result.value(forKey: "image") as? Data
                       {
                           let image = UIImage(data: imageData)
                           imageView.image = image
                       }
                   }
               }
               
           }catch{
               print("Error")
           }
            
        }
        else
        {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        
        
        
        
        
        super.viewDidLoad()
        
        // Keyboard'ı gizlemek için
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        // ImageView'ın kullanıcı etkileşimine izin vermek için
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImageSource))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImageSource() {
        let alert = UIAlertController(title: "Fotoğraf Kaynağı", message: "Bir fotoğraf kaynağı seçin", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Kamera", style: .default, handler: { _ in
            self.selectImage(from: .camera)
        }))
        
        alert.addAction(UIAlertAction(title: "Fotoğraf Galerisi", style: .default, handler: { _ in
            self.selectImage(from: .photoLibrary)
        }))
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func selectImage(from sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            print("Seçilen kaynak tipi mevcut değil.")
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            imageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            imageView.image = originalImage
        }
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        // Kaydetme işlemleri burada gerçekleştirilecek
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        do {
           try context.save()
            print("Success")
        }catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
