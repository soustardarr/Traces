//
//  LocationErrorController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 31.05.2024.
//

import UIKit

class LocationErrorController: UIViewController {

    private var locationErrorView: LocationErrorView?
    private var viewModel: LocationErrorViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        locationErrorView = LocationErrorView()
        view = locationErrorView
        viewModel = LocationErrorViewModel()
    }

}
