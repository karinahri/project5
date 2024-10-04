//
//  ViewController.swift
//  Project5
//
//  Created by Karina Dolmatova on 02.10.2024.
//

import UIKit

enum ValidationError: Error {
    case notOriginalWord
    case notRealWord
    case alreadyUsedWord
    case tooShort
    case notPossibleWord
}


class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWordsString = try? String(contentsOf: startWordsURL) {
                allWords = startWordsString.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer: answer.lowercased())
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    
    @objc func restartGame() {
        let ac = UIAlertController(title: "Restart game?", message: nil, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) {
            [weak self] _ in
            self?.startGame()
        }
        
        ac.addAction(restartAction)
        present(ac, animated: true)
    }
    
    func submit(answer: String) {
        let lowerAnswer = answer.lowercased()
        do {
            try checkPossible(word: lowerAnswer)
            try checkOriginal(word: lowerAnswer)
            try checkReal(word: lowerAnswer)
            usedWords.insert(lowerAnswer, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
        } catch let error as ValidationError {
            switch error {
            case .notOriginalWord:
                showErrorMessage("Word not original", "Be more original!")
            case .notRealWord:
                showErrorMessage("Word not recognised", "You can't just make them up, you know!")
            case .notPossibleWord:
                showErrorMessage("Word not possible", "You can't spell that word from \"\(title!)\"")
            case .alreadyUsedWord:
                showErrorMessage("Word not original", "Be more original!")
            case .tooShort:
                showErrorMessage("Word not recognised", "You can't just make them up, you know!")
            }
        } catch {
            
        }
        
    }
    
    func showErrorMessage(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    
    func checkPossible(word: String) throws {
        var tempWord = title!.lowercased()
        
        for letter in word.lowercased() {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                throw ValidationError.notPossibleWord
            }
        }
    }
    
    func checkOriginal(word: String) throws {
        if word == title { throw ValidationError.notOriginalWord }
        
        guard !usedWords.contains(word.lowercased()) else {
            throw ValidationError.alreadyUsedWord
        }
    }
    
    func checkReal(word: String) throws {
        if word.count < 3 { throw ValidationError.tooShort }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if misspelledRange.location != NSNotFound {
            throw ValidationError.notRealWord
        }
    }
}

