//
//  InitialViewController.swift
//  Example
//
//  Created by Anitha Sangu on 03/01/25.
//

import UIKit
import GlamAR

class FirstViewController: UIViewController {
    private enum SDKMode: Int {
        case vto = 0
        case skinAnalysis = 1
    }

    private struct SDKInput {
        let accessKey: String
        let overrides: GlamAROverrides
    }

    private let defaultAccessKey = "25cd4d7a-fe7d-4fc4-af1b-608414bf0c99"
    private let defaultSkinAnalysisAppId = "38eec760-b8e2-4ef9-9dd1-67a89a678ff5"

    private let modeControl = UISegmentedControl(items: ["VTO", "Skin Analysis"])
    private let vtoFieldsStack = UIStackView()
    private let skinAnalysisFieldsStack = UIStackView()
    private let vtoAccessKeyField = UITextField()
    private let skinAnalysisAccessKeyField = UITextField()
    private let skinAnalysisAppIdField = UITextField()
    private let startButton = UIButton(type: .system)
    private let validationLabel = UILabel()

    private var selectedMode: SDKMode {
        SDKMode(rawValue: modeControl.selectedSegmentIndex) ?? .vto
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        startTapped()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupIntroPage()
    }

    private func setupIntroPage() {
        title = "GlamAR Example"
        view.backgroundColor = .systemBackground
        view.subviews.forEach { $0.removeFromSuperview() }

        let scrollView = UIScrollView()
        let contentStack = UIStackView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 32),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])

        configureFields()
        configureActionControls()

        contentStack.addArrangedSubview(makeHeaderStack())
        contentStack.addArrangedSubview(makeLabel(text: "SDK Mode", font: .preferredFont(forTextStyle: .headline)))
        contentStack.addArrangedSubview(modeControl)
        contentStack.addArrangedSubview(vtoFieldsStack)
        contentStack.addArrangedSubview(skinAnalysisFieldsStack)
        contentStack.addArrangedSubview(validationLabel)
        contentStack.addArrangedSubview(startButton)

        modeChanged()
    }

    private func configureFields() {
        modeControl.selectedSegmentIndex = SDKMode.vto.rawValue
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

        configureTextField(vtoAccessKeyField, placeholder: "VTO access key")
        configureTextField(skinAnalysisAccessKeyField, placeholder: "Skin Analysis access key")
        configureTextField(skinAnalysisAppIdField, placeholder: "Skin Analysis app id")

        vtoAccessKeyField.text = defaultAccessKey
        skinAnalysisAccessKeyField.text = defaultAccessKey
        skinAnalysisAppIdField.text = defaultSkinAnalysisAppId

        configureFieldStack(vtoFieldsStack, arrangedSubviews: [
            makeFieldStack(title: "VTO Access Key", textField: vtoAccessKeyField)
        ])

        configureFieldStack(skinAnalysisFieldsStack, arrangedSubviews: [
            makeFieldStack(title: "Skin Analysis Access Key", textField: skinAnalysisAccessKeyField),
            makeFieldStack(title: "App ID", textField: skinAnalysisAppIdField)
        ])
    }

    private func configureActionControls() {
        startButton.setTitle("Start VTO", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 8
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)

        validationLabel.font = .preferredFont(forTextStyle: .footnote)
        validationLabel.textColor = .systemRed
        validationLabel.numberOfLines = 0
        validationLabel.isHidden = true
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.borderStyle = .roundedRect
        textField.placeholder = placeholder
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.textContentType = .none
        textField.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
    }

    private func configureFieldStack(_ stackView: UIStackView, arrangedSubviews: [UIView]) {
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .fill
        arrangedSubviews.forEach { stackView.addArrangedSubview($0) }
    }

    private func makeHeaderStack() -> UIStackView {
        let titleLabel = makeLabel(text: "GlamAR SDK", font: .preferredFont(forTextStyle: .largeTitle))
        titleLabel.font = .boldSystemFont(ofSize: 32)

        let subtitleLabel = makeLabel(text: "Select a mode and enter credentials.", font: .preferredFont(forTextStyle: .subheadline))
        subtitleLabel.textColor = .secondaryLabel

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }

    private func makeFieldStack(title: String, textField: UITextField) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [
            makeLabel(text: title, font: .preferredFont(forTextStyle: .subheadline)),
            textField
        ])
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }

    private func makeLabel(text: String, font: UIFont) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }

    @objc private func modeChanged() {
        validationLabel.isHidden = true
        vtoFieldsStack.isHidden = selectedMode != .vto
        skinAnalysisFieldsStack.isHidden = selectedMode != .skinAnalysis

        switch selectedMode {
        case .vto:
            startButton.setTitle("Start VTO", for: .normal)
        case .skinAnalysis:
            startButton.setTitle("Start Skin Analysis", for: .normal)
        }
    }

    @objc private func textFieldDidReturn(_ textField: UITextField) {
        textField.resignFirstResponder()
    }

    @objc private func startTapped() {
        view.endEditing(true)
        validationLabel.isHidden = true

        guard let input = makeSDKInput() else { return }
        initializeSDK(with: input)
        showSDKViewController()
    }

    private func makeSDKInput() -> SDKInput? {
        let accessKey = selectedMode == .vto
            ? trimmedText(from: vtoAccessKeyField)
            : trimmedText(from: skinAnalysisAccessKeyField)

        guard !accessKey.isEmpty else {
            showValidation("Access key is required.")
            return nil
        }

        let overrides: GlamAROverrides

        switch selectedMode {
        case .vto:
            overrides = GlamAROverrides(
                meta: ["sdkVersion": "2.0.0", "vto": ["multiTryon": true]]
            )
            return SDKInput(
                accessKey: accessKey,
                overrides: overrides
            )
        case .skinAnalysis:
            let appId = trimmedText(from: skinAnalysisAppIdField)

            guard !appId.isEmpty else {
                showValidation("App ID is required for Skin Analysis.")
                return nil
            }

            overrides = GlamAROverrides(
                category: "skinanalysis",
                configuration: Configuration(skinAnalysis: SkinAnalysisConfig(appId: appId)),
                meta: ["sdkVersion": "2.0.0"]
            )
            return SDKInput(
                accessKey: accessKey,
                overrides: overrides
            )
        }
    }

    private func initializeSDK(with input: SDKInput) {
        GlamAr.initialize(
            accessKey: input.accessKey,
            debug: true,
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            overrides: input.overrides
        )
    }

    private func showSDKViewController() {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            showValidation("Unable to open SDK view.")
            return
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

    private func trimmedText(from textField: UITextField) -> String {
        return textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private func showValidation(_ message: String) {
        validationLabel.text = message
        validationLabel.isHidden = false
    }
}
