@Component
export struct Mine {
  build() {
    Stack() {
      // 背景图片
      Image($r('app.media.rules'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      
      // 规则说明
      Column() {
        Text('游戏规则')
          .fontSize(32)
          .fontColor('#000000')
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 30 })
        
        Text('单人模式每次简单模式/困难模式/地狱模式获胜可获得1/3/10个金币，多人模式不会获得金币；')
          .fontSize(20)
          .fontColor('#000000')
          .textAlign(TextAlign.Center)
          .lineHeight(30)
          .padding({ left: 30, right: 30 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
