//
//  EventsDiscoveryTableViewController.swift
//  EventsManager
//
//  Created by Ethan Hu on 2/27/18.
//  Copyright © 2018 Jagger Brulato. All rights reserved.
//

import UIKit

class EventsDiscoveryController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate {
    
    //Constants
    let reccommendedTagViewHeight:CGFloat = 50
    let tagSideMargins:CGFloat = 10
    let tagSpacing:CGFloat = 12
    let headerFontSize:CGFloat = 20
    let headerHeight:CGFloat = 40
    
    //View Elements
    let tableView = UITableView(frame: CGRect(), style: .grouped)
    let recommendedTagView = UIView()
    let recommendedTagScrollView = UIScrollView()
    
    //Models
    var events = [Event]()
    var recommendedTags = [String]()
    
    var searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }
    
    /*
     * Handler for the pressing action of tag buttons. Should segue to the correct tagview controller.
     * - sender: the sender of the action.
     */
    @objc func tagButtonPressed(_ sender: UIButton) {
        let tagViewController = TagViewController()
        if let tagButton = sender as? EventTagButton {
            let tag = tagButton.getTagName()
            if let rootViewEventsDiscoveryController = navigationController?.viewControllers.first as? EventsDiscoveryController {
                tagViewController.setup(with: rootViewEventsDiscoveryController.events, for: tag)
                navigationController?.pushViewController(tagViewController, animated: true)
            }
        }
    }
    
    /**
    * View initial setups
    */
    func setup(){
        //for testing
        let date1 = "2018-04-19 16:39:57"
        let date2 = "2018-04-19 18:39:57"
        for _ in 1...20 {
            events.append(Event(startTime: DateFormatHelper.date(from: date1)!, endTime: DateFormatHelper.date(from: date2)!, eventName: "Cornell DTI Meeting", eventLocation: "Upson B02", eventParticipant: "David, Jagger, and 10 others", avatars: [URL(string:"http://cornelldti.org/img/team/davidc.jpg")!, URL(string:"http://cornelldti.org/img/team/jaggerb.JPG")!], eventImage: URL(string:"http://ethanhu.me/images/background.jpg")!, eventOrganizer: "Cornell DTI", eventDiscription: "The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog. The quick brown fox jumps over the lazy dog.", eventTags:["#lololo","#heheh","#oooof"], eventParticipantCount: 166))
        }
        recommendedTags = ["#Kornell", "#oweek", "#Events", "#lololo", "#Party"]
        
        view.backgroundColor = UIColor.white
        
        //NAVIGATION STUFFS
        searchController.delegate = self
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        
        //Tableview stuffs
        tableView.backgroundColor = UIColor(named: "tableViewBackground")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventsDiscoveryTableViewCell.self, forCellReuseIdentifier: EventsDiscoveryTableViewCell.identifer)
        tableView.register(EventCardCell.self, forCellReuseIdentifier: EventCardCell.identifer)
        tableView.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView)
        
        //Recommended TagView
        recommendedTagView.backgroundColor = UIColor(named: "tableViewBackground")
        let tagStackView = UIStackView()
        tagStackView.alignment = .center
        tagStackView.axis = .horizontal
        tagStackView.distribution = .fill
        tagStackView.spacing = tagSpacing
        tagStackView.addArrangedSubview(DatePickerTagView())
        for tag in recommendedTags {
            let eventTagButton = EventTagButton() 
            eventTagButton.setTitle(tag, for: .normal)
            eventTagButton.addTarget(self, action: #selector(tagButtonPressed(_:)), for: .touchUpInside)
            tagStackView.addArrangedSubview(eventTagButton)
        }
        recommendedTagScrollView.addSubview(tagStackView)
        recommendedTagView.addSubview(recommendedTagScrollView)
        view.addSubview(recommendedTagView)
        tagStackView.snp.makeConstraints { make in
            make.left.equalTo(recommendedTagScrollView).offset(tagSideMargins)
            make.right.equalTo(recommendedTagScrollView).offset(-tagSideMargins)
            make.top.equalTo(recommendedTagScrollView).offset(tagSideMargins)
            make.bottom.equalTo(recommendedTagScrollView).offset(-tagSideMargins)
        }
        recommendedTagScrollView.snp.makeConstraints{ make in
            make.edges.equalTo(recommendedTagView)
        }
        recommendedTagView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(reccommendedTagViewHeight)
        }
        
        //tableview layout
        tableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(recommendedTagView.snp.bottom)
            make.right.equalTo(view)
            make.left.equalTo(view)
            make.bottom.equalTo(view)
        }
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            case 0: return 1
            case 1: return 1
            case 2: return events.count
            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch indexPath.section {
            case 0:
                if let popularCardCell = tableView.dequeueReusableCell(withIdentifier: EventCardCell.identifer, for: indexPath) as? EventCardCell {
                    popularCardCell.configure(with: events)
                    cell = popularCardCell
                    cell.selectionStyle = .none
                }
            case 1:
                if let todayCardCell = tableView.dequeueReusableCell(withIdentifier: EventCardCell.identifer, for: indexPath) as? EventCardCell {
                    todayCardCell.configure(with: events)
                    cell = todayCardCell
                    cell.selectionStyle = .none
                }
            case 2:
                if let eventDiscoveryCell = tableView.dequeueReusableCell(withIdentifier: EventsDiscoveryTableViewCell.identifer, for: indexPath) as? EventsDiscoveryTableViewCell {
                    eventDiscoveryCell.configure(event: events[indexPath.row])
                    cell = eventDiscoveryCell
                }
            default: break
        }
        return cell
    }
    
    /*
     segue to the selected eventsDetailController
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailsViewController = EventDetailViewController()
        detailsViewController.configure(with: events[indexPath.row])
        navigationController?.pushViewController(detailsViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Popular Events"
            case 1:
                return "Today's Events"
            case 2:
                return "Upcoming events"
            default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.font = UIFont.boldSystemFont(ofSize: headerFontSize)
            headerView.textLabel?.textColor = UIColor.black
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
