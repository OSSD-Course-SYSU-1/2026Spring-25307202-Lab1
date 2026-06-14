import preferences from '@ohos.data.preferences';

@Component
export struct Shop {
  // 使用 @StorageLink 从 AppStorage 获取金币数量
  @StorageLink('coins') coins: number = 0
  // 使用 @StorageLink 从 AppStorage 获取升级次数
  @StorageLink('paddleUpgrade') paddleUpgrade: number = 0

  // 升级球拍
  upgradePaddle(): void {
    // 检查是否已达到最大升级次数
    if (this.paddleUpgrade >= 3) {
      console.log('已达到最大升级次数')
      return
    }
    // 检查金币是否足够
    if (this.coins < 5) {
      console.log('金币不足')
      return
    }
    // 扣除金币并增加升级次数
    this.coins -= 5
    this.paddleUpgrade += 1
    // 保存到本地
    this.saveData()
  }

  // 保存数据到本地存储
  saveData(): void {
    try {
      preferences.getPreferences(getContext(this), 'game_data').then((prefs) => {
        prefs.put('coins', this.coins).then(() => {
          prefs.put('paddleUpgrade', this.paddleUpgrade).then(() => {
            prefs.flush()
            console.log('数据已保存: coins=' + this.coins + ', paddleUpgrade=' + this.paddleUpgrade)
          })
        })
      })
    } catch (e) {
      console.error('保存数据失败: ' + e)
    }
  }

  build() {
    Stack() {
      Column({ space: 20 }) {
        Text('商店')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
        
        // 升级球拍按钮
        Column({ space: 10 }) {
          Text('升级球拍')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          
          Text('当前等级: ' + this.paddleUpgrade + '/3')
            .fontSize(16)
            .fontColor('#888888')
          
          Text('玩家球拍高度: ' + (65 + this.paddleUpgrade * 5))
            .fontSize(16)
            .fontColor('#888888')
          
          if (this.paddleUpgrade < 3) {
            Button('升级 (花费5金币)')
              .width(200)
              .height(50)
              .fontSize(18)
              .backgroundColor(this.coins >= 5 ? '#4CAF50' : '#CCCCCC')
              .enabled(this.coins >= 5)
              .onClick(() => {
                this.upgradePaddle()
              })
            
            if (this.coins < 5) {
              Text('金币不足')
                .fontSize(14)
                .fontColor('#FF0000')
            }
          } else {
            Text('已达到最高等级')
              .fontSize(16)
              .fontColor('#FFD700')
          }
        }
        .padding(20)
        .backgroundColor('#f5f5f5')
        .borderRadius(10)
      }
      .width('100%')
      .height('100%')
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