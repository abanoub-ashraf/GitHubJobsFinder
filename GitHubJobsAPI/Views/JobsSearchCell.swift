import UIKit
import SDWebImage

class JobsSearchCell: UICollectionViewCell {

    // MARK: - Properties -

    static let cellId = Constants.cellId
    
    // this computed variable will get set from the main controller inside the cellForItemAt() function
    var jobResult: Results! {
        didSet {
            companyLabel.text = jobResult.company
            titleLabel.text = jobResult.title
            typeLabel.text = jobResult.type
            locationLabel.text = jobResult.location
            
            // load the image to the logo image view using sdwebimage library
            guard let url = URL(string: jobResult.companyLogo ?? "") else { return }
            logoImageView.sd_setImage(with: url, placeholderImage: Constants.logoImage)
        }
    }

    // MARK: - UI -

    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Constants.logoImage
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    let companyLabel: UILabel = {
        let label = UILabel()
        label.text = "Awesome Company"
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iOS Developer"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Seattle, WA"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()

    let typeLabel: UILabel = {
        let label = UILabel()
        label.text = "Full-Time"
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()


    // MARK: - Init -

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Helper Functions -

    private func configureUI() {
        backgroundColor = Constants.cellBackgroundColor
        layer.cornerRadius = 10

        addSubview(logoImageView)
        // a helper extension from the helpers folder
        logoImageView.anchor(
            top: topAnchor,
            leading: nil,
            bottom: nil,
            trailing: trailingAnchor,
            padding: .init(top: 10, left: 10, bottom: 0, right: 10),
            size: .init(width: 80, height: 100)
        )

        let stackView = UIStackView(arrangedSubviews: [
            companyLabel, titleLabel, typeLabel, locationLabel
        ])

        addSubview(stackView)
        stackView.anchor(
            top: topAnchor,
            leading: leadingAnchor,
            bottom: nil,
            trailing: logoImageView.leadingAnchor,
            padding: .init(top: 10, left: 20, bottom: 0, right: 20)
        )
        stackView.axis = .vertical
        stackView.spacing = 10
    }

}
