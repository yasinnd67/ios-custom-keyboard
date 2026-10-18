import UIKit

class KeyboardViewController: UIInputViewController {
    
    // UI Bileşenleri ve Özellikler
    private var numberRowStackView: UIStackView!
    private var clipboardBar: UICollectionView!
    private var aiCorrectionButton: UIButton!
    private var otpChipButton: UIButton!
    
    private var clipboardHistory: [String] = ["Örnek Pano Metni 1", "Örnek Pano Metni 2"]
    private var detectedOTP: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardUI()
        startOTPMonitoring()
    }
    
    // Orijinal iOS Görünümüne Uygun Arayüz Kurulumu
    private func setupKeyboardUI() {
        view.backgroundColor = UIColor(red: 209/255, green: 213/255, blue: 219/255, alpha: 1.0)
        
        // Üst Numara ve Sembol Satırı
        numberRowStackView = UIStackView()
        numberRowStackView.axis = .horizontal
        numberRowStackView.distribution = .fillEqually
        numberRowStackView.spacing = 4
        
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "@", "#", "$", "_"]
        for item in numbers {
            let button = createKeyButton(title: item)
            numberRowStackView.addArrangedSubview(button)
        }
        
        // AI Düzeltme ve OTP Çip Satırı
        let aiRow = UIStackView()
        aiRow.axis = .horizontal
        aiRow.distribution = .fillProportionally
        aiRow.spacing = 8
        
        aiCorrectionButton = createFeatureButton(title: "✨ TDK / AI Düzelt", action: #selector(aiCorrectText))
        otpChipButton = createFeatureButton(title: "📋 Kodu Yapıştır", action: #selector(pasteOTP))
        otpChipButton.isHidden = true // Başta gizli, kod gelince açılacak
        
        aiRow.addArrangedSubview(aiCorrectionButton)
        aiRow.addArrangedSubview(otpChipButton)
        
        // Ana Yerleşim
        let mainStack = UIStackView(arrangedSubviews: [aiRow, numberRowStackView])
        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 4),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -4)
        ])
    }
    
    private func createKeyButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }
    
    private func createFeatureButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    // AI Yazım Yanlışı Düzeltme (TDK & İngilizce)
    @objc private func aiCorrectText() {
        let proxy = textDocumentProxy
        if let currentText = proxy.documentContextBeforeInput {
            // Yapay Zeka Düzeltme Simülasyonu ve TDK Kural Uygulama
            let correctedText = applyAICorrection(to: currentText)
            
            // Mevcut hatalı kelimeleri sil ve düzeltilmişini yaz
            for _ in 0..<(currentText.count) {
                proxy.deleteBackward()
            }
            proxy.insertText(correctedText)
        }
    }
    
    private func applyAICorrection(to text: String) -> String {
        // TDK ve İngilizce gramer/imla düzeltme motoru mantığı
        var corrected = text
        corrected = corrected.replacingOccurrences(of: "herkez", with: "herkes")
        corrected = corrected.replacingOccurrences(of: "yanlız", with: "yalnız")
        corrected = corrected.replacingOccurrences(of: "orjinal", with: "orijinal")
        return corrected
    }
    
    // SMS / Mail OTP Doğrulama Kodu Algılama (Akıllı Çip)
    private func startOTPMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            let pasteboardString = UIPasteboard.general.string ?? ""
            if self?.isVerificationCode(pasteboardString) == true {
                self?.detectedOTP = pasteboardString
                self?.otpChipButton.setTitle("🔑 Kodu Yapıştır: \(pasteboardString)", for: .normal)
                self?.otpChipButton.isHidden = false
            }
        }
    }
    
    private func isVerificationCode(_ text: String) -> Bool {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // 4 ila 6 haneli saf rakam içeren doğrulama kodları kontrolü
        let regex = "^[0-9]{4,6}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: cleaned)
    }
    
    @objc private func pasteOTP() {
        if let code = detectedOTP {
            textDocumentProxy.insertText(code)
            otpChipButton.isHidden = true // Kullanıldıktan sonra gizle
        }
    }
}