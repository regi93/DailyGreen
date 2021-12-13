//
//  MainPageViewController.swift
//  DailyGreen
//
//  Created by 유준용 on 2021/11/02.
//

import UIKit
import SafariServices

class MainPageViewController: UIViewController{
    
    lazy var dataManager = CoParticipateDataManager()
    lazy var participateView = ParticipateView()
    lazy var subscribeDataManager = CoSubscribeDataManager()
    lazy var cListDataManager = CommunityListDataManager() // 현재 구독중인 커뮤니티
    lazy var cancelDataManager = CancelCommunityDataManager() // 참여한 커뮤니티 구독취소하기
    lazy var eventBannerDataManager = EventBannerDataManager()
    lazy var gridViews = [grid00View ,grid01View, grid02View, grid10View, grid12View, grid20View, grid21View, grid22View]
    
    var bannerIdx = [Int]()
    var bannerCommunityIdx = [Int]()
    var bannerName = [String]()
    var bannerLocationDetail = [String]()
    var bannerWhen = [String]()
    var bannerPhoto = [String]()
    var bannerType = [String]()
    
    @IBOutlet weak var eventLinkButton: UIButton!
    @IBOutlet weak var profileDimmingView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var upperDivider: UIView!
    @IBOutlet weak var lowerDivider: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var communityTitleLabel: UILabel!
    @IBOutlet weak var guideButton: UIButton!
    @IBOutlet weak var cmUpperBodyLabel: UILabel!
    @IBOutlet weak var cmLowerBodyLabel: UILabel!
    @IBOutlet weak var grid00View: CommunityView!
    @IBOutlet weak var grid01View: CommunityView!
    @IBOutlet weak var grid02View: CommunityView!
    @IBOutlet weak var grid10View: CommunityView!
    @IBOutlet weak var gridProfileImageView: UIImageView!
    @IBOutlet weak var grid12View: CommunityView!
    @IBOutlet weak var grid20View: CommunityView!
    @IBOutlet weak var grid21View: CommunityView!
    @IBOutlet weak var grid22View: CommunityView!

    
    @IBAction func presentGuide(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Guide", bundle: nil)
        let GuideVC = storyBoard.instantiateViewController(withIdentifier: "GuideVC")
        GuideVC.modalPresentationStyle = .fullScreen
        self.present(GuideVC, animated: true, completion: nil)
    }
    
    @IBAction func eventLink(_ sender: Any) {
        

        let eventUrl = NSURL(string: "https://seoulkfem.or.kr/notice/?q=YToxOntzOjEyOiJrZXl3b3JkX3R5cGUiO3M6MzoiYWxsIjt9&bmode=view&idx=9102777&t=board")
        let safariView: SFSafariViewController = SFSafariViewController(url: eventUrl as! URL)
        self.present(safariView, animated: true, completion: nil)

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGridView()
        configureUI()
        eventBannerDataManager.getEventBanner(delegate: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        cListDataManager.getCommunityList(delegate: self)
        guard let url = UserDefaults.standard.string(forKey: "profilePhotoUrl") else{return}
        
        gridProfileImageView.load(strUrl: url)

    }
    
    @objc func participate(_ sender: UIButton){ // 커뮤니티 view 눌렀을때
        guard let communityView = sender.superview as? CommunityView else{return}
        dataManager.getCoParticpate(delegate: self, communityIdx: communityView.tag - 10)
    }
    

    
    @objc func postSubscribe(_ sender: UIButton) {
        

        guard let participateView = sender.superview as? ParticipateView else{return}
        let idx = participateView.tag
        
        if CommunityData.shared.subscribedList.contains(idx) {
            
            let param = CancelCommunityRequest(communityIdx: String(idx))
            cancelDataManager.patchCancelCommunity(param, delegate: self, communityIdx: idx)
            
        }else{
            let param = CoSubscribeRequest(communityIdx: "\(idx)")
            subscribeDataManager.postSubscribe(param, delegate: self, communityIdx: idx)
        }

        participateView.removeFromSuperview()

        
    }

    private func configureParticipateView(_ communityIdx: Int, urls: [String], followers: Int, contain: Bool){
        participateView.translatesAutoresizingMaskIntoConstraints = false
        for (i,url) in urls.enumerated(){
            switch i {
            case 0:
                participateView.profileImageView1.load(strUrl: url)
            case 1:
                participateView.profileImageView2.load(strUrl: url)
            default:
                participateView.profileImageView3.load(strUrl: url)
            }
        }
        
        participateView.tag = communityIdx
        participateView.followerLabel.text = "\(followers)"
        participateView.titleLabel.text = CommunityData.shared.nameArr[communityIdx]
        participateView.subTitleLabel.text = CommunityData.shared.subTitleArr[communityIdx]
        participateView.communityImageView.image = UIImage(named: CommunityData.shared.imageArr[communityIdx])
        participateView.dismissBtn.addTarget(self, action: #selector(dismissParticipateView(_:)) , for: .touchUpInside)
        participateView.participateButton.addTarget(self, action: #selector(postSubscribe(_:)), for: .touchUpInside)

    
        if contain {
            participateView.participateButton.setTitle("참여 취소하기", for: .normal)
            participateView.participateButtonView.backgroundColor = .white
            participateView.participateButtonView.layer.borderWidth = 2
            participateView.participateButtonView.layer.borderColor = UIColor.primary.cgColor

        }else{
            participateView.participateButton.setTitle("참여하기", for: .normal)

        }
        self.view.addSubview(participateView)
        NSLayoutConstraint.activate([
            participateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            participateView.topAnchor.constraint(equalTo: self.view.topAnchor),
            participateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            participateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    @objc func dismissParticipateView(_ sender: UIButton){
        participateView.removeFromSuperview()
    }
    @objc func detailButton(_ sender: UIButton){
        let communityIdx = sender.tag - 100
    }
    private func configureGridView(){
        

        for (idx,gridView) in gridViews.enumerated() {
            gridView?.participateBtn.addTarget(self, action: #selector(participate(_:)), for: .touchUpInside)
            gridView?.nameLabel.text = CommunityData.shared.nameArr[idx + 1]
            gridView?.nameLabel.font = UIFont(name: NanumFont.bold, size: 12)
            gridView?.imageView.image = UIImage(named: CommunityData.shared.imageArr[idx + 1])
            gridView?.tag = idx + 11
            gridView?.layer.shadowColor = UIColor.black.cgColor
            gridView?.layer.shadowOpacity = 0.12
            gridView?.layer.shadowRadius = 4
            gridView?.layer.shadowOffset = CGSize(width: 2, height: 2)
        }
        guard let url = UserDefaults.standard.string(forKey: "profilePhotoUrl") else{return}
        gridProfileImageView.load(strUrl: url)
        gridProfileImageView.layer.cornerRadius = gridProfileImageView.layer.frame.size.height / 2
        profileDimmingView.layer.cornerRadius = profileDimmingView.layer.frame.size.height / 2
        profileDimmingView.layer.shadowColor = UIColor.black.cgColor
        profileDimmingView.layer.shadowOpacity = 0.12
        profileDimmingView.layer.shadowRadius = 4
        profileDimmingView.layer.shadowOffset = CGSize(width: 2, height: 2)
    }

    private func configureCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        self.collectionView.isScrollEnabled = true
        self.collectionView.isPagingEnabled = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = flowLayout
        self.collectionView.showsHorizontalScrollIndicator = false
        let nib = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "eventCell")
    }
    
    private func configureUI(){
        eventLinkButton.setTitle("", for: .normal)
        self.navigationController?.isNavigationBarHidden = true
        upperDivider.backgroundColor = UIColor.dark1
        lowerDivider.backgroundColor = UIColor.dark1
        guideButton.setTitle("", for: .normal)
        
        let nickName = UserDefaults.standard.string(forKey: "nickName") ?? ""
        userNameLabel.text = "안녕, \(nickName)"
        communityTitleLabel.font = UIFont(name: NanumFont.bold, size: 17)
        let attributedStr = NSMutableAttributedString(string: communityTitleLabel.text!)
        attributedStr.addAttribute(.foregroundColor , value: UIColor.dark2, range:(communityTitleLabel.text! as NSString).range(of: "그린이") )
        communityTitleLabel.attributedText = attributedStr
        cmUpperBodyLabel.font = UIFont(name: NanumFont.regular, size: 13)
        cmLowerBodyLabel.font = UIFont(name: NanumFont.regular, size: 13)
    }
}
extension MainPageViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 310, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
}

extension MainPageViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerIdx.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let idx = indexPath.row
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? EventCollectionViewCell else {return UICollectionViewCell() }
        cell.imageView.load(strUrl: bannerPhoto[idx])
        cell.locationLabel.text = bannerLocationDetail[idx]
        cell.titleLabel.text = bannerName[idx]
        cell.dateLabel.text = bannerWhen[idx]
        cell.typeLabel.text = bannerType[idx]
        cell.detailButton.tag = bannerCommunityIdx[idx] + 100
        cell.detailButton.addTarget(self, action: #selector(detailButton(_:)), for: .touchUpInside)
        return cell
    }
}


extension MainPageViewController {
    
    func failedToRequest(message: String){
//        presentAlert(title: message)
    }
    
    func didSuccessGet(message: String, results: CoPResult, communityIdx: Int){  // 커뮤니티 클릭시 참가 Alert창 프사받아오는용
        var urls = [String]()
        if results.urlList.count > 0{
            for url in results.urlList {
                urls.append(url.profilePhotoUrl)
            }
        }
        if CommunityData.shared.subscribedList.contains(communityIdx) {
            configureParticipateView(communityIdx, urls: urls, followers: results.totalFollowers, contain: true)
        }else{
            configureParticipateView(communityIdx, urls : urls, followers: results.totalFollowers, contain: false)
        }
        
    }
    
    func didSuccessPostSubscribe(message: String, communityIdx: Int){
        
        cListDataManager.getCommunityList(delegate: self)

    }
    func didSuccessGetEventBanner(message: String, results: [EventBannerResult]){

        
        for result in results{
            bannerIdx.append(result.idx)
            bannerCommunityIdx.append(result.communityIdx)
            bannerName.append(result.name)
            bannerLocationDetail.append(result.locationDetail)
            bannerWhen.append(result.when)
            bannerPhoto.append(result.photo)
            bannerType.append(result.type)
        }
        
        configureCollectionView()

    }
    
    func didSuccessGetCList(message: String, dataList: [CommunityList]){
        
        var newList = [Int]()
        for data in dataList {
            view.viewWithTag(data.idx + 10)?.backgroundColor = .selected
            view.viewWithTag(data.idx + 10)?.layer.borderColor = UIColor.grayStroke.cgColor
            
            newList.append(data.idx)
        }
        
        CommunityData.shared.subscribedList = newList
        for idx in 1...8{
            if CommunityData.shared.subscribedList.contains(idx) == false{
                view.viewWithTag(idx + 10)?.backgroundColor = .white
            }
        }

    }
    
    func didSuccessCancelCommunity(message: String, communityIdx: Int){
//        self.presentAlert(title: message)
        cListDataManager.getCommunityList(delegate: self)
    }
}


