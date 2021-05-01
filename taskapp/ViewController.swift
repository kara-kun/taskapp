//
//  ViewController.swift
//  taskapp
//
//  Created by 唐津 哲也 on 2021/05/01.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //セルの数を返すメソッド　UITableViewDataSourceプロトコルのメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //セルの数を返す
        return 3
    }
    
    //各セルの内容を返すメソッド　UITableViewDataSourceプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    //セルを選択した際に実行するメソッド UITableViewDelegateプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //viewController上のcellをタップしたら、identifier”cellSegue”で識別されるsegue画面遷移を実行
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能であることを伝えるメソッド　UITableViewDelegateプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時のメソッド　UITableViewDataSourceプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}

