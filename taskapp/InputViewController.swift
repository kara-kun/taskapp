//
//  InputViewController.swift
//  taskapp
//
//  Created by 唐津 哲也 on 2021/05/01.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    //各入力パーツの接続
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task:Task!
    
    //viewControllerから遷移してきた時に実行される処理->入力フィールドの描画
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //背景をタップしたらdissmissKeyboardでキーボードを消す
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        //print(task.title)
        
        //各入力フィールドに、既存のデータベース上の各プロパティを表示する
        titleTextField.text = task.title
        categoryTextField.text = task.category
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
    }
    
    //inputViewControllerを消すタイミングで呼び出される処理->入力内容をRealmデータベースに書き込む
    override func viewWillDisappear(_ animated: Bool) {
        //realmデータベースに入力されたデータを書き込む
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.category = self.categoryTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        
        //通知を設定
        setNotification(task: task)
        //viewWillDisappear
        super.viewWillDisappear(animated)
    }
    
    //キーボートを消すメソッドを設定
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //------------タスクのローカル通知を設定---------------------
    func setNotification(task: Task) {
        //通知内容の設定を行うUNMutableNotificationContent()のインスタンスcontentを作成
        let content = UNMutableNotificationContent()
        //タイトルを設定
        if task.title == "" {
            content.title = "（タイトルなし）"
        } else {
            content.title = task.title
        }

        //コンテンツ（内容）を設定
        if task.contents == "" {
            content.body = "（内容なし）"
        } else {
            content.body = task.contents
        }

        //音を設定
        content.sound = UNNotificationSound.default

        //-------ローカル通知のトリガーを設定
        //現在のカレンダー状態のインスタンスを作成
        let calender = Calendar.current
        //タスクで設定された日時のインスタンスを作成
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        //トリガーを設定
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        //ローカル通知を作成（identifierが同じ場合は上書き）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        //現在のUNUserNorificationCenterのインスタンス
        let center = UNUserNotificationCenter.current()
        //ローカル通知を登録
        center.add(request) {
            //？？これは何？
            (error) in print(error ?? "ローカル通知登録　OK")
        }

        //未通知のローカル通知一覧のログ出力
        center.getPendingNotificationRequests {
            (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/--------------/")
                    print(request)
                    print("---------------/")
                }
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
