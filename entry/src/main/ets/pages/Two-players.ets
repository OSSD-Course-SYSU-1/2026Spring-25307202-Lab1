import window from '@ohos.window';

@Builder
export function TwoPlayersBuilder() {
  TwoPlayers()
}

@Component
struct TwoPlayers {
  // 游戏区域尺寸
  @State canvasWidth: number = 0
  @State canvasHeight: number = 0

  // 球的状态
  @State ballX: number = 0
  @State ballY: number = 0
  @State ballVX: number = 5  // 水平速度
  @State ballVY: number = 0  // 垂直速度
  ballRadius: number = 15

  // 重力方向：1为向下，-1为向上
  @State gravityDirection: number = 1
  gravity: number = 0.3  // 重力加速度

  // 球拍状态
  paddleWidth: number = 15
  paddleHeight: number = 60  // 双人模式两边球拍高度都是60
  @State leftPaddleY: number = 0   // 左侧球拍Y位置
  @State rightPaddleY: number = 0  // 右侧球拍Y位置

  // 游戏状态
  @State gameOver: boolean = false
  @State winner: string = ''
  @State countdown: number = 3  // 倒计时
  @State gameStarted: boolean = false  // 游戏是否开始
  @State isPaused: boolean = false  // 是否暂停

  // 定时器ID
  private intervalId: number = -1

  // 路由栈
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    // 设置横屏
    try {
      window.getLastWindow(getContext(this)).then((windowClass) => {
        windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE)
      })
    } catch (e) {
      console.error('设置横屏失败: ' + e)
    }
    
    // 初始化游戏
    setTimeout(() => {
      this.initGame()
    }, 100)
  }

  startCountdown(): void {
    this.countdown = 3
    this.gameStarted = false
    
    let countdownInterval = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        clearInterval(countdownInterval)
        this.gameStarted = true
        this.startGameLoop()
      }
    }, 1000)
  }

  aboutToDisappear(): void {
    // 恢复竖屏
    try {
      window.getLastWindow(getContext(this)).then((windowClass) => {
        windowClass.setPreferredOrientation(window.Orientation.PORTRAIT)
      })
    } catch (e) {
      console.error('恢复竖屏失败: ' + e)
    }
    
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId)
    }
  }

  initGame(): void {
    // 获取屏幕尺寸作为画布尺寸（横屏）
    this.canvasWidth = 640
    this.canvasHeight = 360

    // 初始化球位置（屏幕正中）
    this.ballX = this.canvasWidth / 2
    this.ballY = this.canvasHeight / 2
    this.ballVX = 5
    this.ballVY = 0
    this.gravityDirection = 1

    // 初始化球拍位置
    this.leftPaddleY = this.canvasHeight / 2 - this.paddleHeight / 2
    this.rightPaddleY = this.canvasHeight / 2 - this.paddleHeight / 2

    this.gameOver = false
    this.winner = ''
    
    // 直接开始倒计时（没有难度选择）
    this.startCountdown()
  }

  startGameLoop(): void {
    if (this.intervalId !== -1) {
      clearInterval(this.intervalId)
    }
    this.intervalId = setInterval(() => {
      if (this.gameStarted && !this.gameOver && !this.isPaused) {
        this.updateGame()
      }
    }, 16)  // 约60fps
  }

  // 暂停/继续游戏
  togglePause(): void {
    if (this.gameStarted && !this.gameOver) {
      this.isPaused = !this.isPaused
    }
  }

  updateGame(): void {
    // 更新球的速度（重力影响）
    this.ballVY += this.gravity * this.gravityDirection

    // 更新球的位置
    this.ballX += this.ballVX
    this.ballY += this.ballVY

    // 碰撞检测：顶部和底部
    if (this.ballY - this.ballRadius < 0) {
      this.ballY = this.ballRadius
      this.ballVY = -this.ballVY * 0.9  // 反弹，带一点能量损失
    }
    if (this.ballY + this.ballRadius > this.canvasHeight) {
      this.ballY = this.canvasHeight - this.ballRadius
      this.ballVY = -this.ballVY * 0.9
    }

    // 碰撞检测：左侧球拍（玩家1）
    let leftPaddleX = this.paddleWidth
    if (this.ballX - this.ballRadius < leftPaddleX &&
        this.ballX + this.ballRadius > 0 &&
        this.ballY > this.leftPaddleY &&
        this.ballY < this.leftPaddleY + this.paddleHeight) {
      this.ballX = leftPaddleX + this.ballRadius
      this.ballVX = -this.ballVX * 1.05  // 反弹并稍微加速
      this.gravityDirection = -this.gravityDirection  // 反转重力
    }

    // 碰撞检测：右侧球拍（玩家2）
    let rightPaddleX = this.canvasWidth - this.paddleWidth
    if (this.ballX + this.ballRadius > rightPaddleX &&
        this.ballX - this.ballRadius < this.canvasWidth &&
        this.ballY > this.rightPaddleY &&
        this.ballY < this.rightPaddleY + this.paddleHeight) {
      this.ballX = rightPaddleX - this.ballRadius
      this.ballVX = -this.ballVX * 1.05
      this.gravityDirection = -this.gravityDirection
    }

    // 检测得分（球出界）
    if (this.ballX < 0) {
      // 玩家2得分
      this.gameOver = true
      this.winner = '玩家2获胜！'
    }
    if (this.ballX > this.canvasWidth) {
      // 玩家1得分
      this.gameOver = true
      this.winner = '玩家1获胜！'
    }
  }

  // 触摸控制左侧球拍（玩家1）
  handleLeftTouch(y: number): void {
    this.leftPaddleY = y - this.paddleHeight / 2
    // 限制球拍在画布内
    if (this.leftPaddleY < 0) this.leftPaddleY = 0
    if (this.leftPaddleY + this.paddleHeight > this.canvasHeight) {
      this.leftPaddleY = this.canvasHeight - this.paddleHeight
    }
  }

  // 触摸控制右侧球拍（玩家2）
  handleRightTouch(y: number): void {
    this.rightPaddleY = y - this.paddleHeight / 2
    // 限制球拍在画布内
    if (this.rightPaddleY < 0) this.rightPaddleY = 0
    if (this.rightPaddleY + this.paddleHeight > this.canvasHeight) {
      this.rightPaddleY = this.canvasHeight - this.paddleHeight
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 游戏画布
          Stack() {
            // 游戏区域背景
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('#1a1a2e')

            // 中线
            Rect()
              .width(2)
              .height(this.canvasHeight)
              .fill('#ffffff')
              .position({ x: this.canvasWidth / 2 - 1, y: 0 })

            // 左侧球拍（玩家1）
            Rect()
              .width(this.paddleWidth)
              .height(this.paddleHeight)
              .fill('#e94560')
              .position({ x: 0, y: this.leftPaddleY })

            // 右侧球拍（玩家2）
            Rect()
              .width(this.paddleWidth)
              .height(this.paddleHeight)
              .fill('#0f3460')
              .position({ x: this.canvasWidth - this.paddleWidth, y: this.rightPaddleY })

            // 球
            Circle()
              .width(this.ballRadius * 2)
              .height(this.ballRadius * 2)
              .fill('#ffffff')
              .position({ x: this.ballX - this.ballRadius, y: this.ballY - this.ballRadius })

            // 倒计时显示
            if (!this.gameStarted && this.countdown > 0) {
              Column() {
                Text(this.countdown.toString())
                  .fontSize(80)
                  .fontColor('#ffffff')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0, 0, 0, 0.5)')
            }

            // 游戏结束提示
            if (this.gameOver) {
              Column() {
                Text(this.winner)
                  .fontSize(30)
                  .fontColor('#ffffff')
                  .fontWeight(FontWeight.Bold)
                Button('重新开始')
                  .margin({ top: 20 })
                  .onClick(() => {
                    this.initGame()
                  })
                Button('返回')
                  .margin({ top: 10 })
                  .onClick(() => {
                    this.pathStack.pop()
                  })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0, 0, 0, 0.7)')
            }

            // 暂停提示
            if (this.isPaused) {
              Column() {
                Text('游戏暂停')
                  .fontSize(40)
                  .fontColor('#ffffff')
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .backgroundColor('rgba(0, 0, 0, 0.5)')
            }
          }
          .width(this.canvasWidth)
          .height(this.canvasHeight)
          .onTouch((event: TouchEvent) => {
            if (this.gameStarted && !this.isPaused && (event.type === TouchType.Move || event.type === TouchType.Down)) {
              let touchX = event.touches[0].x
              let touchY = event.touches[0].y
              
              // 根据触摸位置判断控制哪个球拍
              // 左半边控制左侧球拍，右半边控制右侧球拍
              if (touchX < this.canvasWidth / 2) {
                this.handleLeftTouch(touchY)
              } else {
                this.handleRightTouch(touchY)
              }
            }
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#16213e')

        // 暂停按钮
        if (this.gameStarted && !this.gameOver) {
          Button(this.isPaused ? '继续' : '暂停')
            .width(70)
            .height(45)
            .fontSize(18)
            .backgroundColor(this.isPaused ? '#4CAF50' : '#FF9800')
            .position({ x: '100%', y: '100%' })
            .translate({ x: -80, y: -55 })
            .onClick(() => {
              this.togglePause()
            })
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: 10, right: 10 })
      .backgroundColor('#16213e')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
