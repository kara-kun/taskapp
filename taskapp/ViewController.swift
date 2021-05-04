//
//  ViewController.swift
//  taskapp
//
//  Created by 唐津 哲也 on 2021/05/01.
//

import UIKit
import RealmSwift

//viewControllerに必要なプロトコルを宣言（tableViewDelegate/tableViewDataSource/searchBarDelegate）
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Realmインスタンスの取得
    let realm = try! Realm()
    
    //検索フィールドの入力文字列を格納する変数
    var query:String = ""

    //DB内のタスクが管理されているリスト
    //日付の近い順からソート：昇順
    //以降内容を更新すると、リスト内は自動で更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //tableView,検索窓searchBarのdelegateを宣言
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        //---------SearchBarをカスタマイズ--------------
        //serachBarのプレースホルダーを設定
        searchBar.placeholder = "カテゴリーを入力してください"
        searchBar.showsCancelButton = true
        //searchBar.showsSearchResultsButton = true
        
        //realmデータベースの場所をログに出力（確認用。最終的にはコメントアウト）
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    //inputViewControllerから戻った際にTableViewを更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
            
    //セルの数を返すメソッド　UITableViewDataSourceプロトコルのメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //セルの数を返す
        return taskArray.count
    }
    
    //各セルの内容を返すメソッド　UITableViewDataSourceプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //-------------セルに値を設定する(titleタイトルとsubTitle日付)--------
            //taskにtaskArrayからのデータを格納（indexPathのrow行データから）
            let task = taskArray[indexPath.row]
            //cellのタイトル用、入力されているtitleプロパティをtaskから取ってきて表示する
            cell.textLabel?.text = task.title
            //日付表記方法の設定
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            //cellのsubtitleに日付を設定->cellのsubTitleに表示
            let dateString :String = formatter.string(from: task.date)
            cell.detailTextLabel?.text = dateString
        //データの入ったセルを返す
        return cell
    }
    
    //セルを選択した際に実行するメソッド UITableViewDelegateプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //viewController上のcellをタップしたら、identifier”cellSegue”で識別されるsegue画面遷移を実行
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能であることを伝えるメソッド　UITableViewDelegateプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        //削除可能だと伝える（EditingStyleは列挙体enum .deleteは1 .insertは2）
        return .delete
    }
    
    //Deleteボタンが押された時のメソッド　UITableViewDataSourceプロトコルのデリゲートメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //指定されたセルのedithingStyleが .deleteだったら
        if editingStyle == .delete {
            //削除するタスクを定数deleteTaskに取得する。
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知からtaskを削除する
            let center = UNUserNotificationCenter.current()
            print(center)
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //realmデータベースの記載を書き換える
            try! realm.write {
                //指定されたセルの内容を、データベースから消す
                self.realm.delete(task)
                //tableViewから指定されたセルを消す
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            //---------おまけ未通知のローカル通知一覧のログを出力------------
            center.getPendingNotificationRequests {
                (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/--------------/")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    //ーーーーーーーーーーーー検索関連の機能実装ーーーーーーーーーーーーーーー
    //キーボードの検索ボタンが押された際の処理
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //キーボードを閉じる。
        searchBar.endEditing(true)
        
        //入力された文字を得る
        query = searchBar.text!
        //print(query)
        //入力内容が空欄でなければ
        if query != "" {
            //入力内容でカテゴリーを検索した結果をtaskArrayに代入
            taskArray = filterCategory("\(query)")
        } else {
            //taskArrayはそのままtabel全体
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        }
        //tableViewを再読み込み
        tableView.reloadData()
    }
    
    //realm内の検索メソッド
    func filterCategory(_ query:String) -> Results<Task> {
        let resultArray = try! Realm().objects(Task.self).filter("category=='\(query)'").sorted(byKeyPath: "date", ascending: true)
        return resultArray
    }
    
    //キャンセルボタンが押された時の処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // searchBarの入力フィールドを空に戻す
        searchBar.text = ""
        //taskArrayはtabel全体に戻す
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        //tableViewを再読み込み
        tableView.reloadData()
     }
    
    //---------segue実行時にinputViewControllerにデータを渡す---------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //inputViewControllerを
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        //identifierがcellSegueの時＝セルがタップされた時
        if segue.identifier == "cellSegue" {
            //indexPathを現在選択されているセルに設定
            let indexPath = self.tableView.indexPathForSelectedRow
            //inputViewControllerのtaskに、選択されたセルの内容を代入
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            //＋ボタンが押された際は、Taskのインスタンスを作成
            let task = Task()
            //print(task)
            //データベースから、登録されている全タスクを取得
            let allTasks = realm.objects(Task.self)
            //全タスクのタスク数が０でなければ（1つでもタスクがあれば）taskのidを「現在存在するidの最大値＋１」で設定
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            //inputViewControllerに送るtaskのプロパティを、新規taskインスタンス（=id以外の要素は空）で設定
            inputViewController.task = task
        }
    }
}

