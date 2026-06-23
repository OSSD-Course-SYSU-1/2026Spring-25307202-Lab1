@Component
export struct Square {
  // 使用 @StorageLink 从 AppStorage 获取 pathStack
  @StorageLink('pathStack') pathStack: NavPathStack = new NavPathStack()
  // 使用 @StorageLink 从 AppStorage 获取金币数量
  @StorageLink('coins') coins: number = 0
  // 屏幕宽度
  @State screenWidth: number = 0
  // 背景图横向偏移量（像素）
  @State bgOffsetX: number = 0
  // 定时器ID
  private bgAnimationId: number = -1
  // 背景图宽度（已知474像素）
  private bgImageWidth: number = 474
  // 滚动速度（像素/毫秒）
  private scrollSpeed: number = 0.02

  aboutToAppear(): void {
    // 获取屏幕宽度
    try {
      this.screenWidth = 360  // 默认竖屏宽度
    } catch (e) {
      console.error('获取屏幕宽度失败: ' + e)
    }
    
    // 启动背景动画（缓慢横向移动）
    this.bgAnimationId = setInterval(() => {
      this.bgOffsetX -= this.scrollSpeed * 50  // 每50毫秒移动的距离
      // 当第一层背景图完全移出屏幕左侧时重置，实现无缝循环
      if (this.bgOffsetX <= -this.bgImageWidth) {
        this.bgOffsetX = 0
      }
    }, 50)  // 每50毫秒更新一次
  }

  aboutToDisappear(): void {
    // 清除定时器
    if (this.bgAnimationId !== -1) {
      clearInterval(this.bgAnimationId)
    }
  }

  build() {
    Stack() {
      // 动态背景图 - 使用两层背景实现无缝循环
      Image($r('app.media.Square_background'))
        .width(this.bgImageWidth)
        .height('100%')
        .objectFit(ImageFit.Fill)
        .position({ x: this.bgOffsetX, y: 0 })

      // 第二层背景图，紧接在第一层后面，实现无缝循环
      Image($r('app.media.Square_background'))
        .width(this.bgImageWidth)
        .height('100%')
        .objectFit(ImageFit.Fill)
        .position({ x: this.bgOffsetX + this.bgImageWidth, y: 0 })

      Column({ space: 20 }) {
        // 单人模式按钮
        Button('单人模式')
          .width('80%')
          .height(100)
          .fontSize(25)
          .fontColor('#4169E1')
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
          .fontColor('#4169E1')
          .fontWeight(FontWeight.Bold)
          .backgroundImage($r('app.media.two_players_button'))
          .backgroundImageSize({ width: '100%', height: '100%' })
          .align(Alignment.Start)
          .padding({ left: 30 })
          .onClick(() => {
            this.pathStack.pushPathByName('TwoPlayers', null)
          })

        // 无尽模式按钮
        Button('无尽模式')
          .width('80%')
          .height(100)
          .fontSize(25)
          .fontColor('#4169E1')
          .fontWeight(FontWeight.Bold)
          .backgroundImage($r('app.media.Endless_mode_button'))
          .backgroundImageSize({ width: '100%', height: '100%' })
          .align(Alignment.Start)
          .padding({ left: 30 })
          .onClick(() => {
            this.pathStack.pushPathByName('EndlessMode', null)
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