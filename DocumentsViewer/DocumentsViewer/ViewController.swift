//
//  ViewController.swift
//  DocumentsViewer
//
//  Created by Stanislav Leontyev on 13.04.2021.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    private var counter: Int = 0
    private var urlsArray: [URL] = [FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    @IBAction func createFolderButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Создание папки", message: "Введите название папки", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Название папки"
        })

        let textFieldAlert = UIAlertAction(title: "Создать", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields![0]
            
            guard let text = textField?.text else {return}
            
            let appendedFolder = self.urlsArray.last?.appendingPathComponent(text)
            
            guard let folder = appendedFolder else {return}
            
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
            
            self.tableView.reloadData()
            
        })
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(textFieldAlert)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()

        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func getUrl() -> [URL] {
        
        var urls = [URL]()
        
        do {
            urls = try FileManager.default.contentsOfDirectory(at: urlsArray.last!, includingPropertiesForKeys: nil)
            return urls
        } catch {
            let alert = UIAlertController(title: "Внимание", message: "Выбранный объект не является папкой", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        }
        
        return urls
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        } else {
            return getUrl().count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "goBackCell", for: indexPath)
            cell.textLabel?.text = "..."
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PathCell", for: indexPath)
            let documentsUrls = try? FileManager.default.contentsOfDirectory(atPath: urlsArray.last!.path)
            cell.textLabel?.text = try? String(contentsOf: getUrl()[indexPath.row])
            cell.textLabel?.text = documentsUrls![indexPath.row]
            return cell
        }
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if urlsArray.count != 1 {
                urlsArray.removeLast()
                tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Внимание", message: "Вы находитесь в корневой папке", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Понятно", style: .cancel, handler: { _ in
                    tableView.reloadData()
                })
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        } else {
            let nextUrl = getUrl()[indexPath.row]
            urlsArray.append(nextUrl)
            tableView.reloadData()
        }
        
    }
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        
        guard let image = info[.originalImage] as? UIImage else {return}
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        let imageURL = urlsArray.last!.appendingPathComponent("image " + String(countTaps()) + ".jpg")
        do {
            try imageData?.write(to: imageURL)
        } catch {
            print ("Unable to write")
        }
        
        tableView.reloadData()
        
    }
    
    private func countTaps() -> String {
        counter = counter + 1
        return String(counter)
    }
    
}
