//
//  FriendsCollectionViewController.swift
//  MyHomeworkApp
//
//  Created by Tim on 18.12.2021.
//

import UIKit
import RealmSwift

final class FriendCVC: UICollectionViewController {
    
    var friend: UserRealm?
    private let networkService = NetworkService<Photos>()
    private var photos: Results<PhotoRealm>? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private var photosToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(FriendPage.self)
        collectionView.register(header: FriendCVCHeader.self)
        
        configureLayout()
        networkServiceFunction()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photosToken = photos?.observe { [weak self] photosChanges in
            guard let self = self else { return }
            switch photosChanges {
            case .initial, .update:
                self.collectionView.reloadData()
            case .error(let error):
                print(error)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        photosToken?.invalidate()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { photos?.count ?? 0 }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header: FriendCVCHeader = collectionView.dequeueReusableSupplementaryView(for: indexPath)
        guard let currentFriend = friend else { return FriendCVCHeader() }
    
        header.configure(
            friendName: currentFriend.fullName,
            url: currentFriend.photoBig,
            friendGender: (currentFriend.sex == 1) ? "female":"male" )
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: FriendPage = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(url: photos?[indexPath.row].url ?? "")
        return cell
    }
    
    func configureLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width

        layout.headerReferenceSize = CGSize(width: width, height: 120)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width / 3 - 2, height: width / 3 - 2)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 3
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.systemBackground
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showPhoto") as? LargePhoto {
            vc.photos = photos!
            vc.chosenPhotoIndex = indexPath.row
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func networkServiceFunction() {
        networkService.fetch(type: .photos, id: friend!.id){ [weak self] result in
            switch result {
            case .success(let photos):
                DispatchQueue.main.async {
                    let photoRealm = photos.map { PhotoRealm(ownerID: self?.friend?.id ?? 0, photo: $0) }
                    do {
                    try RealmService.save(items: photoRealm)
                        self?.photos = try RealmService.load(typeOf: PhotoRealm.self).filter("ownerID == %@", self?.friend?.id ?? "")
                    self?.collectionView.reloadData()
                    } catch {
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
