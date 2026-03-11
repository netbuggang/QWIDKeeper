export default {
  "last_updated": "2026-03-09 14:30:00",
  "app_name": "com.tencent.wework",
  "versions": [
    {
      "app_version": "5.0.6",
      "capture_date": "2026-03-09",
      "activities": {
        "AddFriendActivity": {
          "search_button": "com.tencent.wework:id/g3a",
          "input_field": "com.tencent.wework:id/f2b",
          "add_button": "com.tencent.wework:id/h4c"
        },
        "ChatActivity": {
          "message_input": "com.tencent.wework:id/j5d",
          "send_button": "com.tencent.wework:id/k6e"
        }
      }
    },
  ]
}

// // 不是简单地搜"查找按钮"，而是指定页面
// const buttonId = client.getButtonId(
//     version = "4.1.0",           // 企微版本
//     activity = "AddFriendActivity", // 在添加好友页面
//     buttonType = "search_button"    // 查找按钮
// )
// // 返回：com.tencent.wework:id/g3a
