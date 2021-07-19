//
//  DeliveryDetailsViewViewController.swift
//  GettMobileDelivery
//
//  Created by Roi Kedarya on 15/07/2021.
//

import Foundation
import UIKit

class DeliveryDetailsViewViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var tabelView: UITableView!
    var destinationsVM: DestinationViewModel?
    var items:[Parcel]?
    var type:String?
    
    var selectedIndexPaths = Set<IndexPath>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    private func configureVC() {
        setTable()
        setTitles()
        setParcels()
    }
    
    private func setParcels() {
        if let destinationsVM = destinationsVM, !destinationsVM.isEmpty(),
           let nextDeliveryDetail = destinationsVM.getDestination(at: 0) {
            if self.type == nil {
                self.type = destinationsVM.getDestinationType(nextDeliveryDetail)
            }
            if let type = self.type {
                items = destinationsVM.getParcelsForType(type)
            }
        }
    }
    
    private func setTable() {
        self.tabelView.delegate = self
        self.tabelView.dataSource = self
        self.tabelView.backgroundColor = .white
    }
    
    private func setTitles() {
        if let type = type {
            titleLabel.text = type
            subTitleLabel.text = type == ResourceHelper.pickupType ? "Parcels to collect" : "parcels to deliver"
        }
    }
    
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        guard let mapViewController = ResourceHelper.storyboard.instantiateViewController(identifier: "mapViewController") as? MapViewController else {
            fatalError("View controller not found")
        }
        if let destinationsVM = self.destinationsVM, destinationsVM.isNavigationCompleted() {
            //show message for delivery completed - no transition to map vc
            showBasicAlert()
        } else {
            mapViewController.destinationsVM = self.destinationsVM
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    private func showBasicAlert() {
        let alertViewController  = BasicAlertViewController.init(nibName: BasicAlertViewController.identifier, bundle: .main)
        alertViewController.modalPresentationStyle = .overCurrentContext
            self.present(alertViewController, animated: true, completion: nil)
    }
}

//MARK: extension - UITableViewDelegate

extension DeliveryDetailsViewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedIndexPaths.insert(indexPath) //select
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) { //deselect
            selectedIndexPaths.remove(indexPath)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.accessoryType = selectedIndexPaths.contains(indexPath) ? .checkmark : .none
    }
}

//MARK: extension - UITableViewDataSource

extension DeliveryDetailsViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items == nil ? 0 : items!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryDetailsCell", for: indexPath)
        if let parcel = self.items?[indexPath.row] {
            cell.textLabel?.text = parcel.display_identifier
            cell.detailTextLabel?.text = parcel.barcode
        }
        
        return cell
    }
    
    
    
    
}
