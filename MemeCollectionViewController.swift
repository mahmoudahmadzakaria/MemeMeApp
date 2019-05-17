//
//  MemeCollectionViewController.swift
//  MemeMe2.4
//
//

import Foundation
import UIKit

// MARK: - VillainCollectionViewController: UICollectionViewController

class MemeCollectionViewController: UICollectionViewController {

    // MARK: Properties
    
    // Get ahold of some villains, for the table
    // This is an array of Villain instances.
    var memes: [Meme]!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector((startOver)))

        
    }
    @objc func startOver() {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        present (detailController, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        collectionView!.delegate = self
        collectionView!.dataSource = self
        collectionView!.reloadData()
        self.tabBarController?.tabBar.isHidden = false
        
        
    }
    
    // MARK: Collection View Data Source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        
        cell.nameLabel.text = meme.topText
        cell.villainImageView?.image = meme.memedImage
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
}
