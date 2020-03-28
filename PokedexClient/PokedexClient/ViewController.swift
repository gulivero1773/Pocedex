import UIKit

enum Result<T> {
    case success(T)
    case falure(Error)
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        getPokemons { [weak self] (result) in
            switch result {
            case .success(let pokemons):
                self?.pokemons = pokemons
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            case .falure(let error):
                let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default) { [weak self] (_) in
                    self?.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    private func getPokemons(completion: @escaping (Result<[Pokemon]>) -> ()) {
        let url = URL(string: "http://localhost:8080/pokemons")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.falure(error))
                return
            }
            do {
                let pokemons = try JSONDecoder().decode([Pokemon].self, from: data!)
                completion(.success(pokemons))
            } catch {
                completion(.falure(error))
            }
        }.resume()
        
    }
}
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = pokemons[indexPath.row]
        cell.textLabel?.text = pokemon.name
        
        return cell
    }
}
