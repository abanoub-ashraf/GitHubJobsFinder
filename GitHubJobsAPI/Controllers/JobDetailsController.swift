import UIKit
import SafariServices
import SDWebImage

class JobDetailsController: UIViewController {
    
    // MARK: - Variables -
    
    // this computed variable will get set from the cell controller inside the  function
    var jobResultDetail: Results! {
        didSet {
            companyLabel.text = jobResultDetail.company
            titleLabel.text = jobResultDetail.title
            jobTypeLabel.text = jobResultDetail.type
            locationLabel.text = jobResultDetail.location
            
            guard let url = URL(string: jobResultDetail.companyLogo ?? "") else { return }
            logoImageview.sd_setImage(with: url, placeholderImage: Constants.logoImage)
            
            companyUrl = jobResultDetail.companyUrl ?? ""
            applyUrl = jobResultDetail.url ?? ""
            
            htmlText = jobResultDetail.description ?? ""
            let dsecriptionHTML = convertHTML(text: htmlText, attributedText: &descriptionTextView.attributedText)
            descriptionTextView.attributedText = dsecriptionHTML
        }
    }
    
    var companyUrl = ""
    
    var applyUrl = ""
    
    var htmlText = ""
    
    // to zoom in and out in the description text view
    var pinchGesture = UIPinchGestureRecognizer()
    
    // MARK: - UI -
    
    // this class is coming from the helper extensions file
    let logoImageview = AspectFitImageView(image: Constants.logoImage, cornerRadius: 12)
    
    let companyLabel: UILabel = {
        let label = UILabel()
        label.text = "Awesome company"
        label.font = .boldSystemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iOS Developer"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    let jobTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Full-Time"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Seattle, WA"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        return label
    }()
    
    let urlButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Visit Company's Website", for: .normal)
        button.tintColor = .label
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleCompanyUrl), for: .touchUpInside)
        return button
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.textAlignment = .left
        textView.textColor = .label
        textView.backgroundColor = Constants.textViewBackgroundColor
        textView.isEditable = false
        textView.layer.cornerRadius = 12
        return textView
    }()

    let applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Apply", for: .normal)
        button.tintColor = .label
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleApplyUrl), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Helper Functions -
    
    private func setupUI() {
        view.backgroundColor = Constants.mainColor
        
        view.addSubview(logoImageview)
        logoImageview.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: nil,
            bottom: nil,
            trailing: view.trailingAnchor,
            padding: .init(top: 10, left: 10, bottom: 10, right: 10),
            size: .init(width: 80, height: 100)
        )
        
        let stackView = UIStackView(arrangedSubviews: [
            companyLabel, titleLabel, jobTypeLabel, locationLabel, urlButton
        ])
        
        view.addSubview(stackView)
        stackView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor,
            leading: view.leadingAnchor,
            bottom: nil,
            trailing: logoImageview.leadingAnchor,
            padding: .init(top: 10, left: 20, bottom: 20, right: 20)
        )
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(descriptionTextView)
        descriptionTextView.anchor(
            top: stackView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: nil,
            trailing: view.trailingAnchor,
            padding: .init(top: 10, left: 20, bottom: 20, right: 20)
        )
        
        view.addSubview(applyButton)
        applyButton.anchor(
            top: descriptionTextView.bottomAnchor,
            leading: view.leadingAnchor,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: .init(top: 10, left: 70, bottom: 30, right: 70)
        )
        
        // change the attributedText of this ul to the new one we made using this function
        descriptionTextView.attributedText = convertHTML(
            text: htmlText,
            attributedText: &descriptionTextView.attributedText
        )
        
        // add the pinch gesture to this text view
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchText(sender:)))
        descriptionTextView.addGestureRecognizer(pinchGesture)
        
    }
    
    /** convert HTML string format into NSAttributedString */
    // inout means we gonna mutate the attributedText param then return it
    private func convertHTML(text: String, attributedText: inout NSAttributedString) -> NSAttributedString {
        // first convert the given html string into data
        let data = Data(text.utf8)
        // create the options for the conversion process
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        // create the new attributed string
        if let attriburtedString = try? NSMutableAttributedString(
            data: data, options: options, documentAttributes: nil
        ) {
            attributedText = attriburtedString
            return attriburtedString
        }
        // then return it
        return attributedText
    }
    
    // MARK: - Selectors -
    
    // go to the content of the url of the selected company cell
    @objc private func handleCompanyUrl() {
        if companyUrl == "" {
            let ac = UIAlertController(
                title: "Link is not available",
                message: nil,
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
        
        guard let url = URL(string: companyUrl) else { return }
        // create a controller of the safari controller class giving it a url to open
        let safariController = SFSafariViewController(url: url)
        safariController.modalPresentationStyle = .formSheet
        // then present that controller
        self.present(safariController, animated: true, completion: nil)
    }
    
    // go to the apply link of the selected company cell
    @objc private func handleApplyUrl() {
        if applyUrl == "" {
            let ac = UIAlertController(
                title: "Link is not available to apply for this job",
                message: nil,
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            ac.modalPresentationStyle = .formSheet
            present(ac, animated: true, completion: nil)
        }
        
        guard let url = URL(string: applyUrl) else { return }
        // create a controller of the safari controller class giving it a url to open
        let safariController = SFSafariViewController(url: url)
        safariController.modalPresentationStyle = .formSheet
        // then present that controller
        self.present(safariController, animated: true, completion: nil)
    }
    
    //
    @objc private func pinchText(sender: UIPinchGestureRecognizer) {
        var pointSize = descriptionTextView.font?.pointSize
        pointSize = ((sender.velocity > 0) ? 1 : -1) * 1 + pointSize!
        descriptionTextView.font = UIFont(name: "arial", size: (pointSize)!)
    }
    
}
