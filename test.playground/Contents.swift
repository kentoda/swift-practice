import Foundation
import Dispatch

// values: 入力の配列、transform: 各要素に適用する変換関数
// 戻り値: 変換関数を適用した結果の配列
func concurrentMap<Input, Output>(_ values: [Input], transform: @escaping (Input) -> Output) -> [Output] {
    // 並列処理を実行するためのディスパッチキューを作成
    let queue = DispatchQueue(label: "concurrentMap", attributes: .concurrent)
    // DispatchGroupを作成して、全ての非同期タスクの完了を監視
    let group = DispatchGroup()

    // 出力の配列を初期化。初期値はnilで、タスク完了時に値をセット
    var outputs: [Output?] = Array(repeating: nil, count: values.count)

    // valuesの各要素に対して非同期タスクを登録
    for (index, value) in values.enumerated() {
        queue.async(group: group) {
            // 各要素に対して変換関数を適用
            let output = transform(value)
            // 結果をoutputsにセット
            outputs[index] = output
        }
    }

    // 全ての非同期タスクが完了するまで待機
    group.wait()

    // 全てのタスクが完了していることが保証されているので、強制アンラップが安全
    return outputs.map { $0! }
}

// 1から10000までの配列を作成
let numbers = Array(1...10000)
// concurrentMap関数で各要素を二乗
let squares = concurrentMap(numbers) { $0 * $0 }
// 結果を出力
print("=====\(squares)")

