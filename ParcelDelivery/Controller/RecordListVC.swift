//
//  RecordListVC.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 21/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import UIKit




class RecordListVC: UIViewController {

    var tableview = UITableView()
    var indexpath : IndexPath? = nil
    var allRecords : [Record] = [] {
        didSet{
     
            
//           rowsToDisplay = allRecords
//            self.tableview.reloadData()
           
            
           
        }
    }
    var completed : [Record] = []
    var cancelled : [Record] = []
    var user : String
    
    //assign the allRecord to final array after allRecord is initialize
   lazy var rowsToDisplay = allRecords
   
    private let topBar : UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    let segmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl(items : ["All", "Completed", "Cancelled"])
        sc.backgroundColor = .clear
        sc.selectedSegmentTintColor = .lightBlue
        sc.selectedSegmentIndex = 0
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        sc.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        sc.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
     
        return sc
    }()
    
    @objc func handleSegmentChange(){
        print("debug segment contro \(segmentedControl.selectedSegmentIndex)")
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rowsToDisplay = allRecords
        case 1:
            rowsToDisplay = completed
        default:
            rowsToDisplay = cancelled
        }
        tableview.reloadData()
    }
//    private let deleteButton : UIButton = {
//          let button = UIButton(type: .system)
//          button.setTitle("Delete", for: .normal)
//          button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
//          button.layer.cornerRadius = 10
//          button.backgroundColor = .blue
//          button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
//          return button
//      }()
    
    struct Cells{
        static let recordCell = "RecordCell"
    }
    
    init(recordlist : [Record] , user : String) {
        self.allRecords = recordlist
        
        
        self.user = user
        super.init(nibName: nil, bundle : nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Recent Records"
        
      
        //configure tab bar
        configureTabBar()

        
        //fetchData()
       configureTableView()
      
        //categorize function
        categorizeRecord()
       
    }
//
//    @objc func handleDelete(){
//
//
//         print("debug 123 ")
//    }
//
    func categorizeRecord(){
        self.allRecords.forEach { (record) in
                   if record.status == "Completed" {
                    self.completed.append(record)
                   }else {
                    self.cancelled.append(record)
                   }
               }
    }
    func configureTabBar(){
         let button = UIButton(type: .system)
        button.frame = CGRect(x: -10, y: 0, width: 30, height: 30 )
        button.backgroundColor = nil
        button.setImage(UIImage.init(named: "left-arrow"), for: .normal)
        button.addTarget(self, action: #selector(dismissRecord), for: .touchUpInside)

        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 35)));
        view.addSubview(button);
        view.backgroundColor = nil

        let leftButton = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = leftButton

        navigationController?.navigationBar.barTintColor = .lightBlue
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
  
              //123
                
    }
    @objc func dismissRecord(){
        dismiss(animated: true, completion: nil)
         guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else {return }
       
    }
    
    func configureTableView(){
        view.backgroundColor = .white
        
        let paddedStackView = UIStackView(arrangedSubviews: [segmentedControl])
        paddedStackView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        paddedStackView.isLayoutMarginsRelativeArrangement = true
        
        let stackView = UIStackView(arrangedSubviews: [paddedStackView , tableview])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
//        view.addSubview(segmentedControl)
//        segmentedControl.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
//        view.addSubview(tableview)
//        tableview.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        tableview.separatorStyle = .none
        tableview.tableFooterView = UIView()
        tableview.delaysContentTouches = false
        tableview.allowsSelection = false
        //setdelegate
        setTableViewDelegate()
        
        //set row height
        tableview.rowHeight = 150
        
        //register cell
        tableview.register(RecordCell.self, forCellReuseIdentifier: Cells.recordCell)
        
        //set constraints
        //tableview.pin(to: view)
    }
    
    func setTableViewDelegate(){
        tableview.delegate = self
        tableview.dataSource = self
    }
    
  
}

extension RecordListVC: UITableViewDelegate, UITableViewDataSource {
    
  
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    func tableView(_ tableView: UITableView, commit editingStyle:   UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
////        if (editingStyle == .delete) {
////            records.remove(at: indexPath.row)
////            tableView.beginUpdates()
////            tableView.deleteRows(at: [indexPath], with: .middle)
////            tableView.endUpdates()
////        }
//  }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("debug record list \(allRecords)")
        return rowsToDisplay.count
    }
    
    //this get call everytime the new cell comes up to the screen
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: Cells.recordCell) as! RecordCell //to access the function in recordcell
        
        //set delegate
        cell.delegate = self
     
        let record = rowsToDisplay[indexPath.row]
       
        cell.set(record: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        header.backgroundColor = .lightBlue
        
       let titleLabel = UILabel()
        titleLabel.text = "Recent Record"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.textColor = .white
        
        header.addSubview(titleLabel)
        titleLabel.centerY(inView: header)
        titleLabel.centerX(inView: header)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}

extension RecordListVC{
    
    func confirmationDelete(indexPath : IndexPath, recordid: String, user: String){
        let alert = UIAlertController(title: nil, message: "Are you sure you want to delete?", preferredStyle: .alert)
         
        //add delete option
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            
            //delete record from database
            if user == "customer"{ //customer side
                PassengerService.shared.deleteRecord(recordid: recordid) { (err, ref) in
                    guard let err = err else { return }
                    print("debug err \(err)")
                    
                }
            }else {
                //driver side
                DriverService.shared.deleteDriverRecord(recordid: recordid) { (err, ref) in
                     guard let err = err else { return }
                    print("debug err \(err)")
                }
            }
            
            

            //remove specific record for each category
            let allFilter = self.allRecords.filter { (record) -> Bool in
                return record.recordid != recordid
            }
            self.allRecords = allFilter

            let completeFilter = self.completed.filter { (record) -> Bool in
                return record.recordid != recordid
            }
            self.completed = completeFilter

            let cancelledFilter = self.cancelled.filter { (record) -> Bool in
                return record.recordid != recordid
            }
            self.cancelled = cancelledFilter
             
            //assign the new records to the final array based on the index of semneted
            self.segmentedControllIndexCallToFunction()
            
            //delete row
            self.tableview.deleteRows(at: [indexPath], with: .fade)

        
        }))
    
        //add cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated : true, completion: nil)
      
    }
    
    func segmentedControllIndexCallToFunction(){

        switch self.segmentedControl.selectedSegmentIndex {
               case 0:
                self.rowsToDisplay = self.allRecords
               case 1:
                self.rowsToDisplay = self.completed
               default:
                self.rowsToDisplay = self.cancelled
               }
    }
  
    func fetchData() {
//        let record1 = Record(orderid: "10112", status: "Success", time: "2:50pm")
//         let record2 = Record(orderid: "10113", status: "Cancelled", time: "3:06pm")
//         let record3 = Record(orderid: "10114", status: "Success", time: "2:30pm")
//         let record4 = Record(orderid: "10115", status: "Cancelled", time: "2:10pm")
//         let record5 = Record(orderid: "10116", status: "Success", time: "1:20pm")
//        let record6 = Record(orderid: "10112", status: "Success", time: "2:50pm")
//        let record7 = Record(orderid: "10113", status: "Cancelled", time: "3:06pm")
//        let record8 = Record(orderid: "10114", status: "Success", time: "2:30pm")
//        let record9 = Record(orderid: "10115", status: "Cancelled", time: "2:10pm")
//        let record10 = Record(orderid: "10116", status: "Success", time: "1:20pm")
        
        PassengerService.shared.observeRecord { (recordslist) in
            print("debug record list \(recordslist)")
            self.allRecords = recordslist
           
        }
        
       
    }
}

extension RecordListVC: RecordCellDelegate{
    
    func delete(cell: RecordCell){
          let index = tableview.indexPath(for: cell)
          print("debug \(index)")
        
        guard let indexPath = index else { return }
        self.indexpath = indexPath
        var recordid : String = ""
     
        switch segmentedControl.selectedSegmentIndex {
        case 0:
             recordid = allRecords[indexPath.row].recordid
        case 1:
             recordid = completed[indexPath.row].recordid
        default:
             recordid = cancelled[indexPath.row].recordid
        }
        
//        //get the recordid
//        let recordid = allRecords[indexPath.row].recordid
        print("debug record id \(recordid)")
        //call the delete function
        confirmationDelete(indexPath: indexPath,recordid: recordid, user: self.user)
       
      }
}
