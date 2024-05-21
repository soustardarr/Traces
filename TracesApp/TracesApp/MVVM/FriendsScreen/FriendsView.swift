//
//  FriendsView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.05.2024.
//


import UIKit
import JGProgressHUD


class FriendsView: UIView {

    var hud = JGProgressHUD(style: .dark)

    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "поиск по никнейму..."
        searchBar.searchTextField.textColor = .black
        searchBar.barStyle = .default
        searchBar.backgroundColor = .white
        searchBar.barTintColor = .white
        return searchBar
    }()

    var friendsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "ваши друзья:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    var peopleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isHidden = true
        return tableView
    }()

    var friendsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        return tableView
    }()


    var noFriendsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 30)
        label.text = "друзей нет"
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        addSubview(friendsLabel)
        addSubview(peopleTableView)
        addSubview(friendsTableView)
        addSubview(noFriendsLabel)
        NSLayoutConstraint.activate([

            friendsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            friendsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            noFriendsLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noFriendsLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            peopleTableView.topAnchor.constraint(equalTo: topAnchor),
            peopleTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            peopleTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            peopleTableView.bottomAnchor.constraint(equalTo: bottomAnchor),


            friendsTableView.topAnchor.constraint(equalTo: friendsLabel.bottomAnchor, constant: 3),
            friendsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            friendsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            friendsTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }

}
