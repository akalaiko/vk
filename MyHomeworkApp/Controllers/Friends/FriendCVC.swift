//
//  FriendsCollectionViewController.swift
//  MyHomeworkApp
//
//  Created by Tim on 18.12.2021.
//

import UIKit

final class FriendCVC: UICollectionViewController {
    
    var friend: FriendModel?
    var viewForSmooth = UIView()
    var currentIndex = Int()
    static var freakingIndex = Int()
    var chosenPhoto = FriendPage()
    var enlargedPhoto = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        viewForSmooth.alpha = 0.0
        configureLayout()

        collectionView.register(
            UINib(
                nibName: "FriendPage",
                bundle: nil),
            forCellWithReuseIdentifier: "friendPageCell")
        
        collectionView.register(
            UINib(
                nibName: "FriendCVCHeader",
                bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "friendHeader")
        
    }
    
    override func viewWillAppear(_ animated: Bool = false) {
        if CGFloat(viewForSmooth.alpha).rounded(.up) == 1 {
            enlargedPhoto.image = photoDatabase[friend!.id]![FriendCVC.freakingIndex].image
            viewForSmooth.alpha = 1.0
            postAnimation([0, FriendCVC.freakingIndex])
        }
    }
    override func viewDidAppear(_ animated: Bool = false) {
       
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoDatabase[friend!.id]!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "friendHeader",
                for: indexPath) as? FriendCVCHeader
        else { return UICollectionReusableView() }
        
        guard let currentFriend = friend else { return UICollectionViewCell() }
    
        header.configure(
            friendName: currentFriend.name,
            friendAvatar: currentFriend.avatar!,
            friendAge: currentFriend.age,
            friendGender: currentFriend.gender.rawValue)
        
        return header
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "friendPageCell",
            for: indexPath) as? FriendPage
        else { return UICollectionViewCell() }
        
        guard let currentFriend = friend else { return UICollectionViewCell() }
        cell.friendPhotoAlbumItem.image = photoDatabase[currentFriend.id]![indexPath.row].image
        
        return cell
    }
    
    func configureLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width

        layout.headerReferenceSize = CGSize(width: width, height: 120)
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: width / 3, height: width / 3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "showPhoto") as? LargePhoto {
            vc.photoArray = photoDatabase[friend!.id]!
            vc.chosenPhotoIndex = indexPath.row
            currentIndex = indexPath.row
            vc.friend = friend
            preAnimation(indexPath,vc)
        }
    }
    
    func preAnimation(_ chosenIndex: IndexPath, _ vc: LargePhoto) {
        viewForSmooth.backgroundColor = UIColor.white
        viewForSmooth.frame = view.bounds
        chosenPhoto = collectionView.cellForItem(at: chosenIndex) as! FriendPage

        enlargedPhoto = UIImageView(image: chosenPhoto.friendPhotoAlbumItem.image)
        enlargedPhoto.frame = chosenPhoto.friendPhotoAlbumItem.frame
        enlargedPhoto.layer.position.x = chosenPhoto.frame.midX
        enlargedPhoto.layer.position.y = chosenPhoto.frame.midY + chosenPhoto.frame.size.height/1.33
        
        let scaling = self.view.frame.width / enlargedPhoto.frame.width
        
        self.view.addSubview(viewForSmooth)
        self.view.addSubview(enlargedPhoto)
        
        UIView.animateKeyframes(
            withDuration: 1.0,
            delay: 0.0,
            options: [
                .calculationModePaced
            ],
            animations: {

                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 1.0,
                    animations: {
                        self.enlargedPhoto.layer.position = CGPoint(
                            x: self.enlargedPhoto.layer.frame.width * scaling / 2,
                            y: self.view.frame.height / 2)
                        self.viewForSmooth.backgroundColor = UIColor.white.withAlphaComponent(1.0)
                        self.viewForSmooth.alpha = 1.0
                    })
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 1.0,
                    animations: {
                        let scale = CGAffineTransform(
                            scaleX: scaling,
                            y: scaling)
                        self.enlargedPhoto.transform = scale
                })
            },
            completion: { i in
                self.viewForSmooth.alpha = 0.1
                self.navigationController?.pushViewController(vc, animated: false)
            })
    }
    
    func postAnimation(_ chosenIndex: IndexPath) {
        
        chosenPhoto = collectionView.cellForItem(at: chosenIndex) as! FriendPage
        
        let x = chosenPhoto.frame.midX
        let y = chosenPhoto.frame.midY + chosenPhoto.frame.size.height/1.33
        let scaling = self.view.frame.width / enlargedPhoto.frame.width
        
        UIView.animateKeyframes(
            withDuration: 1.0,
            delay: 0.0,
            options: [
                .calculationModePaced
            ],
            animations: {

                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 1.0,
                    animations: {
                        self.enlargedPhoto.layer.position = CGPoint(
                            x: x,
                            y: y)
                        self.viewForSmooth.backgroundColor = UIColor.white.withAlphaComponent(0.0)
                        self.viewForSmooth.alpha = 0.0
                    })
                
                UIView.addKeyframe(
                    withRelativeStartTime: 0.0,
                    relativeDuration: 1.0,
                    animations: {
                        let scale = CGAffineTransform(
                            scaleX: scaling,
                            y: scaling)
                        self.enlargedPhoto.transform = scale
                })
            },
            completion: { i in
                self.viewForSmooth.removeFromSuperview()
                self.enlargedPhoto.removeFromSuperview()
            })
    }
}
