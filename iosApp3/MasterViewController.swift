//
//  MasterViewController.swift
//  iosApp3
//
//  Created by User1 RDMA on 2018-10-28.
//  Copyright © 2018 CP. All rights reserved.
// Sagar

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //navigationItem.leftBarButtonItem = editButtonItem

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        var i:Int = 0
        
//        objects.insert("Using WebView Control", at:i); i+=1
//        objects.insert("  GOI", at: i); i+=1
//        objects.insert("  CROR", at: i); i+=1
//        objects.insert("  GCOR", at: i); i+=1
        //objects.insert("Using PDFView Control", at:i); i+=1
        objects.insert("  GOI", at: i); i+=1
        objects.insert("  CROR", at: i); i+=1
        objects.insert("  GCOR", at: i); i+=1
        
        //let indexPath = IndexPath(row: 0, section: 0)
        //tableView.insertRows(at: [indexPath], with: .automatic)
        let GOIAlreadySaved = pdfFileAlreadySaved(url: "http://www.tcrcmoosejaw.ca/TCRCAttach/Documents/GOI%202009.pdf", fileName: "GOI")
        let CRORAlreadySaved = pdfFileAlreadySaved(url: "https://www.tc.gc.ca/media/documents/railsafety/CROR_English_May_18_2018_Web_Services.pdf", fileName: "CROR")
        let GCORAlreadySaved = pdfFileAlreadySaved(url: "http://fwwr.net/assets/gcor-effective-2015-04-01.pdf", fileName: "GCOR")
        
        GOIAlreadySaved ? () : savePdf(urlString: "http://www.tcrcmoosejaw.ca/TCRCAttach/Documents/GOI%202009.pdf", fileName: "GOI")
        CRORAlreadySaved ? () : savePdf(urlString: "https://www.tc.gc.ca/media/documents/railsafety/CROR_English_May_18_2018_Web_Services.pdf", fileName: "CROR")
        GCORAlreadySaved ? () : savePdf(urlString: "http://fwwr.net/assets/gcor-effective-2015-04-01.pdf", fileName: "GCOR")
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any) {
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! String
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                //controller.isWebView = indexPath.row <= 3 ? true : false
                if(object.contains("GOI")){
                    controller.filenameOrURL = "GOI"
                }
                else if (object.contains("CROR")){
                    controller.filenameOrURL = "CROR"
                }
                else if(object.contains("GCOR")){
                    //controller.filenameOrURL = "http://fwwr.net/assets/gcor-effective-2015-04-01.pdf"
                    controller.filenameOrURL = "GCOR"
                }
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! String
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            do{
                _ = try String(contentsOf: url!, encoding: String.Encoding.utf16)
            } catch{
                print("Error")
            }
            
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "iOSApp3-\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    // check to avoid saving a file multiple times
    func pdfFileAlreadySaved(url:String, fileName:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("iOSApp3-\(fileName).pdf") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }

}

