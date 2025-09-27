//
//  CommentView.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import UIKit

final class CommentView: UIViewController {
    var answer: String
    var comment: String
    
    private let answerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 20)
        label.textColor = Colors.textSecondary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 20)
        label.textColor = Colors.textPrimary
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    init(answer: String, comment: String) {
        self.answer = answer
        self.comment = comment
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainBackground()
        configureUI()
    }
    
    private func configureUI() {
        view.addSubview(answerLabel)
        view.addSubview(commentLabel)
        
        answerLabel.text = "Ваш ответ:\n\(answer)"
        commentLabel.text = "Комментарий преподавателя:\n\(comment)"
        
        answerLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 16)
        answerLabel.pinHorizontal(view, 16)
        
        commentLabel.pinTop(answerLabel.bottomAnchor, 16)
        commentLabel.pinHorizontal(view, 16)
        commentLabel.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 16)
    }
}
