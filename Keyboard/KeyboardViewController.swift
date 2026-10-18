import UIKit

final class KeyboardViewController: UIInputViewController {
    private let backgroundColor = UIColor(red: 0.82, green: 0.84, blue: 0.87, alpha: 1)
    private let keyColor = UIColor.white
    private let specialKeyColor = UIColor(red: 0.68, green: 0.72, blue: 0.77, alpha: 1)
    private let accentColor = UIColor(red: 0.10, green: 0.42, blue: 0.88, alpha: 1)
    private let historyKey = "keyboard.clipboardHistory.v1"

    private var isShifted = true
    private var isSymbolsMode = false
    private var heightConstraint: NSLayoutConstraint?
    private var clipboardButton: UIButton?
    private var statusLabel: UILabel?

    private let numberKeys: [String] = [
        "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"
    ]
    private let letterRows: [[String]] = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]
    ]
    private let symbolRows = [
        ["@", "#", "$", "%", "&", "-", "+", "(", ")", "/"],
        ["*", "\"", "'", ":", ";", "!", "?", "₺", "€"],
        ["=", "_", "\\", "[", "]", "{", "}"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        buildKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshClipboardMenu()
    }

    private func buildKeyboard() {
        view.subviews.forEach { $0.removeFromSuperview() }
        heightConstraint?.isActive = false
        view.backgroundColor = backgroundColor

        let root = UIStackView()
        root.axis = .vertical
        root.alignment = .fill
        root.distribution = .fill
        root.spacing = 5
        root.translatesAutoresizingMaskIntoConstraints = false

        let toolbar = UIStackView()
        toolbar.axis = .horizontal
        toolbar.distribution = .fillEqually
        toolbar.spacing = 6
        toolbar.addArrangedSubview(makeToolButton(title: "Düzelt", action: #selector(correctLastWord)))

        let clipboard = makeToolButton(title: "Pano", action: nil)
        clipboard.showsMenuAsPrimaryAction = true
        clipboardButton = clipboard
        toolbar.addArrangedSubview(clipboard)
        toolbar.addArrangedSubview(makeToolButton(title: "OTP", action: #selector(pasteOTPFromClipboard)))
        toolbar.heightAnchor.constraint(equalToConstant: 32).isActive = true
        root.addArrangedSubview(toolbar)

        let status = UILabel()
        status.font = .systemFont(ofSize: 11)
        status.textColor = .secondaryLabel
        status.textAlignment = .center
        status.numberOfLines = 1
        status.text = ""
        status.heightAnchor.constraint(equalToConstant: 15).isActive = true
        statusLabel = status
        root.addArrangedSubview(status)

        root.addArrangedSubview(makeKeyRow(numberKeys, keyHeight: 31))

        let firstRow = isSymbolsMode ? symbolRows[0] : letterRows[0]
        root.addArrangedSubview(makeKeyRow(firstRow, keyHeight: 40))

        let secondRow = isSymbolsMode ? symbolRows[1] : letterRows[1]
        let secondStack = UIStackView()
        secondStack.axis = .horizontal
        secondStack.distribution = .fillEqually
        secondStack.spacing = 4
        secondStack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        secondStack.isLayoutMarginsRelativeArrangement = true
        secondRow.forEach { secondStack.addArrangedSubview(makeCharacterButton($0)) }
        secondStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        root.addArrangedSubview(secondStack)

        root.addArrangedSubview(makeThirdRow())
        root.addArrangedSubview(makeBottomRow())

        view.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            root.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            root.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            root.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -5)
        ])
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 285)
        heightConstraint?.priority = .defaultHigh
        heightConstraint?.isActive = true
        refreshClipboardMenu()
    }

    private func makeKeyRow(_ keys: [String], keyHeight: CGFloat) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 4
        keys.forEach { row.addArrangedSubview(makeCharacterButton($0)) }
        row.heightAnchor.constraint(equalToConstant: keyHeight).isActive = true
        return row
    }

    private func makeThirdRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fillEqually
        row.spacing = 4

        row.addArrangedSubview(makeKeyButton(title: "⇧", value: "SHIFT", color: specialKeyColor))
        let keys = isSymbolsMode ? symbolRows[2] : letterRows[2]
        keys.forEach { row.addArrangedSubview(makeCharacterButton($0)) }
        row.addArrangedSubview(makeKeyButton(title: "⌫", value: "DELETE", color: specialKeyColor))
        row.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return row
    }

    private func makeBottomRow() -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .fill
        row.alignment = .fill
        row.spacing = 4

        let mode = makeKeyButton(title: isSymbolsMode ? "ABC" : "123", value: "MODE", color: specialKeyColor)
        mode.widthAnchor.constraint(equalToConstant: 45).isActive = true
        row.addArrangedSubview(mode)

        let globe = makeKeyButton(title: "🌐", value: "GLOBE", color: specialKeyColor)
        globe.widthAnchor.constraint(equalToConstant: 38).isActive = true
        row.addArrangedSubview(globe)

        let comma = makeKeyButton(title: ",", value: ",", color: keyColor)
        comma.widthAnchor.constraint(equalToConstant: 28).isActive = true
        row.addArrangedSubview(comma)

        let space = makeKeyButton(title: "boşluk", value: "SPACE", color: keyColor)
        space.setContentHuggingPriority(.defaultLow, for: .horizontal)
        space.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        row.addArrangedSubview(space)

        let period = makeKeyButton(title: ".", value: ".", color: keyColor)
        period.widthAnchor.constraint(equalToConstant: 28).isActive = true
        row.addArrangedSubview(period)

        let enter = makeKeyButton(title: "↵", value: "RETURN", color: specialKeyColor)
        enter.widthAnchor.constraint(equalToConstant: 45).isActive = true
        row.addArrangedSubview(enter)

        row.heightAnchor.constraint(equalToConstant: 41).isActive = true
        return row
    }

    private func makeCharacterButton(_ value: String) -> UIButton {
        let title = (!isSymbolsMode && isShifted) ? value.uppercased() : value
        return makeKeyButton(title: title, value: value, color: keyColor)
    }

    private func makeKeyButton(title: String, value: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: title.count > 2 ? 13 : 19, weight: .regular)
        button.backgroundColor = color
        button.layer.cornerRadius = 5
        button.accessibilityIdentifier = value
        button.addTarget(self, action: #selector(handleKey(_:)), for: .touchUpInside)
        return button
    }

    private func makeToolButton(title: String, action: Selector?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.backgroundColor = accentColor
        button.layer.cornerRadius = 7
        if let action {
            button.addTarget(self, action: action, for: .touchUpInside)
        }
        return button
    }

    @objc private func handleKey(_ sender: UIButton) {
        guard let value = sender.accessibilityIdentifier else { return }
        switch value {
        case "SHIFT":
            isShifted.toggle()
            buildKeyboard()
        case "DELETE":
            textDocumentProxy.deleteBackward()
        case "MODE":
            isSymbolsMode.toggle()
            buildKeyboard()
        case "GLOBE":
            advanceToNextInputMode()
        case "SPACE":
            textDocumentProxy.insertText(" ")
            updateShiftAfterInput(" ")
        case "RETURN":
            textDocumentProxy.insertText("\n")
            isShifted = true
            buildKeyboard()
        default:
            let output: String
            if !isSymbolsMode && isShifted {
                output = value.uppercased()
            } else {
                output = value
            }
            textDocumentProxy.insertText(output)
            updateShiftAfterInput(output)
        }
    }

    private func updateShiftAfterInput(_ input: String) {
        if isShifted {
            isShifted = false
            buildKeyboard()
        } else if [".", "!", "?", "\n"].contains(input) {
            isShifted = true
            buildKeyboard()
        }
    }

    // This is a small on-device dictionary, not an AI service or full TDK checker.
    @objc private func correctLastWord() {
        guard let context = textDocumentProxy.documentContextBeforeInput, !context.isEmpty else {
            showStatus("Düzeltilecek kelime bulunamadı")
            return
        }
        let pattern = #"[A-Za-zÇĞİÖŞÜçğıöşü']+$"#
        guard let range = context.range(of: pattern, options: .regularExpression) else {
            showStatus("Düzeltmek için önce bir kelime yazın")
            return
        }
        let original = String(context[range])
        let key = original.lowercased(with: Locale(identifier: "tr_TR"))
        let corrections: [String: String] = [
            "herkez": "herkes", "yanlız": "yalnız", "orjinal": "orijinal",
            "yalnış": "yanlış", "birşey": "bir şey", "şuan": "şu an",
            "teh": "the", "recieve": "receive", "definately": "definitely",
            "seperate": "separate", "becuase": "because"
        ]
        guard let replacement = corrections[key] else {
            showStatus("Bu kelime yerel sözlükte bulunamadı")
            return
        }
        let formatted = original.first?.isUppercase == true ? replacement.capitalized : replacement
        for _ in original { textDocumentProxy.deleteBackward() }
        textDocumentProxy.insertText(formatted)
        showStatus("Kelime düzeltildi · yerel sözlük")
    }

    private func loadedClipboardHistory() -> [String] {
        UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }

    private func refreshClipboardMenu() {
        guard let clipboardButton else { return }
        var actions: [UIAction] = []
        actions.append(UIAction(title: "Panodaki metni kaydet ve yapıştır", image: UIImage(systemName: "doc.on.clipboard")) { [weak self] _ in
            self?.captureClipboardAndInsert()
        })
        let history = loadedClipboardHistory()
        if !history.isEmpty {
            actions.append(contentsOf: history.map { text in
                UIAction(title: Self.menuTitle(for: text), image: UIImage(systemName: "clock")) { [weak self] _ in
                    self?.textDocumentProxy.insertText(text)
                    self?.showStatus("Pano geçmişinden eklendi")
                }
            })
        }
        clipboardButton.menu = UIMenu(title: "Pano geçmişi", children: actions)
        clipboardButton.showsMenuAsPrimaryAction = true
    }

    private static func menuTitle(for text: String) -> String {
        let flattened = text.replacingOccurrences(of: "\n", with: " ")
        return String(flattened.prefix(35)) + (flattened.count > 35 ? "…" : "")
    }

    private func captureClipboardAndInsert() {
        guard hasFullAccess else {
            showStatus("Pano için Ayarlar'dan Tam Erişim'i açın")
            return
        }
        guard let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            showStatus("Panoda metin bulunamadı")
            return
        }
        var history = loadedClipboardHistory().filter { $0 != text }
        history.insert(text, at: 0)
        UserDefaults.standard.set(Array(history.prefix(20)), forKey: historyKey)
        textDocumentProxy.insertText(text)
        refreshClipboardMenu()
        showStatus("Metin panoya kaydedildi ve eklendi")
    }

    @objc private func pasteOTPFromClipboard() {
        guard hasFullAccess else {
            showStatus("OTP için Ayarlar'dan Tam Erişim'i açın")
            return
        }
        guard let text = UIPasteboard.general.string else {
            showStatus("Panoda doğrulama kodu bulunamadı")
            return
        }
        let pattern = #"(?<!\d)\d{4,8}(?!\d)"#
        guard let range = text.range(of: pattern, options: .regularExpression) else {
            showStatus("Panoda 4–8 haneli kod bulunamadı")
            return
        }
        let code = String(text[range])
        textDocumentProxy.insertText(code)
        showStatus("Doğrulama kodu eklendi")
    }

    private func showStatus(_ message: String) {
        statusLabel?.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard self?.statusLabel?.text == message else { return }
            self?.statusLabel?.text = ""
        }
    }
}
