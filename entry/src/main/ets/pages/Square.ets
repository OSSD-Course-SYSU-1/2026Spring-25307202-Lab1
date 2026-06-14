@Component
export struct Square {
  // 使用 @StorageLink 从 AppStorage 获取 pathStack
  @StorageLink('pathStack') pathStack: NavPathStack = new NavPathStack()
  // 使用 @StorageLink 从 AppStorage 获取金币数量
  @StorageLink('coins') coins: number = 0

  build() {
    Stack() {
      Column({ space: 20 }) {
        // 单人模式按钮
        Button('单人模式')
          .width('80%')
          .height(100)
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .backgroundImage($r('app.media.Single_player_button'))
          .backgroundImageSize({ width: '100%', height: '100%' })
          .align(Alignment.Start)
          .padding({ left: 30 })
          .onClick(() => {
            this.pathStack.pushPathByName('SinglePlayer', null)
          })

        // 双人模式按钮
        Button('双人模式')
          .width('80%')
          .height(100)
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .backgroundImage($r('app.media.two_players_button'))
          .backgroundImageSize({ width: '100%', height: '100%' })
          .align(Alignment.Start)
          .padding({ left: 30 })
          .onClick(() => {
            this.pathStack.pushPathByName('TwoPlayers', null)
          })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 10, right: 10, top: 20, bottom: 20 })
      .justifyContent(FlexAlign.Center)

      // 金币显示（右上角）
      Row() {
        Text('💰 ' + this.coins)
          .fontSize(20)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
      }
      .position({ x: '90%', y: 20 })
      .translate({ x: '-100%' })
    }
    .width('100%')
    .height('100%')
  }
}