//
//  EmojyController.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.06.2024.
//

import UIKit

class EmojiController: UIViewController {

    private var emojiView: EmojiView?
    private var viewModel: EmojiViewModel?
    private var safeEmail: String


    init(safeEmail: String) {
        self.safeEmail = safeEmail
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        emojiView = EmojiView()
        view = emojiView
        emojiView?.delegate = self
        viewModel = EmojiViewModel()
    }


}

extension EmojiController: EmojiViewDelegate {
    func didTappedAngryEmoji() {
        emojiView?.animateAngryEmoji()
        viewModel?.playAngry()
        viewModel?.handleSendMessages(toUserEmail: safeEmail, text: "😡")
    }
    
    func didTappedHappyEmoji() {
        emojiView?.animateHappyEmoji()
        viewModel?.playHappy()
        viewModel?.handleSendMessages(toUserEmail: safeEmail, text: "😂")
    }
}
