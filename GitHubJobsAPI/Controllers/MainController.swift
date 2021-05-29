import UIKit

class MainController: UICollectionViewController {
    
    // MARK: - Variables -
    
    private var jobResults = [Results]()
    
    var timer: Timer?
    
    // MARK: - UI -
    
    // the search controller we gonna integrate inside the navigation item
    private let searchController = UISearchController(searchResultsController: nil)
    
    // the search bar that's gonna appear once the search controller is tapped
    let citySearchBar = UISearchBar()
    
    // MARK: - LifeCycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.appName
        
        configureNavigationBar()
        
        configureCollectionView()

        setupSearchBar()
    }
    
    // MARK: - Helper Functions -
    
    // load the results from the api into the collection view
    private func fetchResults(descriptionQuery: String, locactionQuery: String) {
        NetworkManager.shared.getResults(
            description: descriptionQuery,
            location: locactionQuery
        ) { [weak self] result in
            switch result {
                case .success(let results):
                    // assign the array we got from the api to the array we use to populate the collection view
                    self?.jobResults = results
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    // display the error in an alert
                    DispatchQueue.main.async {
                        let ac = UIAlertController(title: error.rawValue, message: nil, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self?.present(ac, animated: true, completion: nil)
                    }
                    print(error.localizedDescription)
            }
        }
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = Constants.mainColor
        collectionView.register(JobsSearchCell.self, forCellWithReuseIdentifier: JobsSearchCell.cellId)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = Constants.mainColor
        navigationController?.navigationBar.isTranslucent = true
        // to make the search controller visible when the app launches
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupSearchBar() {
        definesPresentationContext = true
        // put the search controller inside the navigation item's integrated search controller
        navigationItem.searchController = self.searchController
        
        searchController.searchBar.delegate = self
        
        // the text for the search bar inside the navigation item
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .label
        textFieldInsideSearchBar?.placeholder = "enter position..."
        
        // the view that's gonna show when the navigation item search bar is tapped
        // what's gonna show is another search bar for searching by the city
        searchController.view.addSubview(citySearchBar)
        citySearchBar.frame = CGRect(
            x: 10,
            y: searchController.searchBar.frame.height + 50 ,
            width: view.frame.size.width - 30,
            height: 50
        )
        
        citySearchBar.placeholder = "enter location..."
        citySearchBar.layer.cornerRadius = 12
        citySearchBar.center.x = searchController.view.center.x
        citySearchBar.barTintColor = Constants.mainColor
        citySearchBar.delegate = self
    }
    
    // MARK: - Init -
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
       
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
}

// MARK: - UICollectionViewDelegate -

extension MainController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = JobDetailsController()
        // pass the data of each cell to the detail controller when the cell is tapped
        detailController.jobResultDetail = jobResults[indexPath.item]
        navigationController?.pushViewController(detailController, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource -

extension MainController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jobResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: JobsSearchCell.cellId,
            for: indexPath
        ) as! JobsSearchCell
        // pass the data from this controller to each cell
        cell.jobResult = jobResults[indexPath.item]
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension MainController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 10, right: 1.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width - 20, height: 180)
    }
    
}

// MARK: - UISearchBarDelegate -

extension MainController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // perform the web request only if there are vlaues in the both search bars
        if let position = searchController.searchBar.text, let city = citySearchBar.text {
            // stop the timer if it was running
            timer?.invalidate()
            // then call the api after some delay to avoid instant many web requests the app sends
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (_) in
                self.jobResults = []
                self.fetchResults(descriptionQuery: position, locactionQuery: city)
            })
        }
        
        citySearchBar.text = ""
        searchController.searchBar.text = ""
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.jobResults = []
        collectionView.reloadData()
        searchBar.text = ""
        citySearchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
}
