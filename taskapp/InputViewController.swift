//
//  InputViewController.swift
//  taskapp
//
//  Created by 唐津 哲也 on 2021/05/01.
//

import UIKit

class InputViewController: UIViewController {
    //各入力パーツの接続
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextField: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
