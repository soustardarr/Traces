//
//  EmojyView.swift
//  TracesApp
//
//  Created by Ruslan Kozlov on 02.06.2024.
//

import UIKit

protocol EmojiViewDelegate: AnyObject {
    func didTappedHappyEmoji()
    func didTappedAngryEmoji()
}

class EmojiView: UIView {

    weak var delegate: EmojiViewDelegate?

    var label: UILabel = {
        let label = UILabel()
        label.text = "реакции"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var happyEmoji: UIImageView = {
        let happyEmoji = UIImageView()
        happyEmoji.translatesAutoresizingMaskIntoConstraints = false
        happyEmoji.isUserInteractionEnabled = true
        happyEmoji.image = UIImage.happyEmoji
        return happyEmoji
    }()

    var angryEmoji: UIImageView = {
        let angryEmoji = UIImageView()
        angryEmoji.translatesAutoresizingMaskIntoConstraints = false
        angryEmoji.isUserInteractionEnabled = true
        angryEmoji.image = UIImage.emojiAngry
        return angryEmoji
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
        addGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func addGesture() {
        let gestureHappyEmoji = UITapGestureRecognizer(target: self, action: #selector(didTappedHappyEmoji))
        happyEmoji.addGestureRecognizer(gestureHappyEmoji)

        let gestureAngryEmoji = UITapGestureRecognizer(target: self, action: #selector(didTappedAngryEmoji))
        angryEmoji.addGestureRecognizer(gestureAngryEmoji)
    }

    @objc private func didTappedHappyEmoji() {
        delegate?.didTappedHappyEmoji()
    }

    @objc private func didTappedAngryEmoji() {
        delegate?.didTappedAngryEmoji()
    }


    func animateHappyEmoji() {
        UIView.animate(withDuration: 0.3) {
            let transformRotation = CGAffineTransform(rotationAngle: .pi / 2)
            let transformScale = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.happyEmoji.transform = transformScale.concatenating(transformRotation)

        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.happyEmoji.transform = .identity

            }
        }

    }


    func animateAngryEmoji() {
        UIView.animate(withDuration: 0.1, animations: {
            let transformRotation = CGAffineTransform(rotationAngle: .pi / 3)
            let transformScale = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.angryEmoji.transform = transformRotation.concatenating(transformScale)
        }) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                self.angryEmoji.transform = .identity
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    let transformRotation = CGAffineTransform(rotationAngle: -.pi / 3)
                    let transformScale = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    self.angryEmoji.transform = transformRotation.concatenating(transformScale)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        self.angryEmoji.transform = .identity
                    }
                })
            })
        }
    }



    private func setUpLayout() {
        backgroundColor = .white
        addSubview(label)
        addSubview(happyEmoji)
        addSubview(angryEmoji)

        NSLayoutConstraint.activate([

            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 15),



            happyEmoji.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            happyEmoji.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),

            angryEmoji.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            angryEmoji.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)

        ])
    }

}
