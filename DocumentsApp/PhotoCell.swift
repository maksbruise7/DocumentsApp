import UIKit

class PhotoCell: UITableViewCell {
    static let identifier = "PhotoCell"
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let fileNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(fileNameLabel)
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            photoImageView.widthAnchor.constraint(equalToConstant: 80),
            photoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            fileNameLabel.leadingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: 16),
            fileNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            fileNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with fileURL: URL) {
        fileNameLabel.text = fileURL.lastPathComponent
        
        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            photoImageView.image = image
        } else {
            photoImageView.image = UIImage(systemName: "photo")
        }
    }
}
