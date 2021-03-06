//
//  FriendsTableViewController.swift
//  MyHomeworkApp
//
//  Created by Tim on 18.12.2021.
//

import UIKit

final class MyFriendsTVC: UITableViewController, UIGestureRecognizerDelegate {
    @IBOutlet var searchBar: UISearchBar!
    
    var friendsDictionary = [String: [FriendModel]]()
    var friendsSectionTitles = [String]()
    var friendsFilteredDictionary = [String: [FriendModel]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.register(UINib(
            nibName: "MyFriendCell",
            bundle: nil),
            forCellReuseIdentifier: "friendCell")
        configureSectionTitles()
        friendsFilteredDictionary = friendsDictionary

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        friendsSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        friendsFilteredDictionary[friendsSectionTitles[section]]!.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return friendsSectionTitles
    }
    
    // header & cell configure

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return friendsSectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as? UITableViewHeaderFooterView
        header?.tintColor = UIColor.gray.withAlphaComponent(0.15)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as? MyFriendCell else { return UITableViewCell() }
        let letterKey = friendsSectionTitles[indexPath.section]
           if let friendsOnLetterKey = friendsFilteredDictionary[letterKey] {
               let myFriend = friendsOnLetterKey[indexPath.row]
               cell.configure(avatar: myFriend.avatar, name: myFriend.name)
           }
        return cell
    }
    
    // select & segue
    
    override func prepare( for segue: UIStoryboardSegue, sender: Any? ) {
        guard segue.identifier == "goToFriend", let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let destination = segue.destination as? FriendCVC else { return }
        let letterKey = friendsSectionTitles[indexPath.section]
           if let friendsOnLetterKey = friendsDictionary[letterKey] {
               destination.friend = friendsOnLetterKey[indexPath.row]}
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true)}
        performSegue(withIdentifier: "goToFriend", sender: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    func configureSectionTitles() {
        friendDatabase.sort()
        for index in friendDatabase.indices {
            let letterKey = String((friendDatabase[index].name).prefix(1))
                if var friendsOnLetterKey = friendsDictionary[letterKey] {
                    friendsOnLetterKey.append(friendDatabase[index])
                    friendsDictionary[letterKey] = friendsOnLetterKey
                } else {
                    friendsDictionary[letterKey] = [friendDatabase[index]]
                }
        }
        
        friendsSectionTitles = [String](friendsDictionary.keys).sorted(by: { $0 < $1 })
    }
}

// search

extension MyFriendsTVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        guard !searchText.isEmpty else {
            friendsFilteredDictionary = friendsDictionary
            friendsSectionTitles = [String](friendsFilteredDictionary.keys).sorted()
            tableView.reloadData()
            return
        }
        
        friendsFilteredDictionary.removeAll()
        friendsSectionTitles.removeAll()
        
        for key in friendsDictionary.keys {
            guard let friend = friendsDictionary[key] else { return }
            friendsFilteredDictionary[key] = friend.filter({ $0.name.lowercased().contains(searchText.lowercased()) })
        }
        
        friendsSectionTitles = ([String](friendsFilteredDictionary.keys).sorted())
                                .filter({ !friendsFilteredDictionary[$0]!.isEmpty })
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        friendsFilteredDictionary = friendsDictionary
        friendsSectionTitles = [String](friendsFilteredDictionary.keys).sorted()
        tableView.reloadData()
    }
    
    @objc func setSearchBar() {
        searchBar.searchTextField.text = ""
        searchBar.showsCancelButton = true
    }
    
}
