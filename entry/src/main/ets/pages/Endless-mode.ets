import window from '@ohos.window';

@Builder
export function EndlessModeBuilder() {
  EndlessMode()
}

@Component
struct EndlessMode {
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
  aiPaddleHeight: number = 80  // AI球拍高度
  @State playerPaddleHeight: number = 65  // 玩家球拍高度
  @State leftPaddleY: number = 0   // 左侧AI球拍Y位置
  @State rightPaddleY: number = 0  // 右侧玩家球拍Y位置

  // 升级次数
  @StorageLink('paddleUpgrade') @Watch('onPaddleUpgradeChange') paddleUpgrade: number = 0

  // 监听升级次数变化，更新玩家球拍高度
  onPaddleUpgradeChange(): void {
    this.playerPaddleHeight = 65 + this.paddleUpgrade * 5
  }

  // AI移动速度上限（固定为8）
  aiMaxSpeed: number = 8

  // 游戏状态
  @State gameOver: boolean = false
  @State countdown: number = 3  // 倒计时
  @State gameStarted: boolean = false  // 游戏是否开始
  @State isPaused: boolean = false  // 是否暂停
  @State showEndScreen: boolean = false  // 是否显示结束画面

  // 比分
  @State aiScore: number = 0
  @State playerScore: number = 0

  // 定时器ID
  private intervalId: number = -1
  private countdownIntervalId: number = -1

  // 路由栈
  pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    // 初始化玩家球拍高度
    this.playerPaddleHeight = 65 + this.paddleUpgrade * 5

    // 设置横屏
    try {
      window.getLastWindow(getContext(this)).then((windowClass) => {
        windowClass.setPreferredOrientation(window.Orientation.LANDSCAPE)
      })
    } catch (e) {
      console.error('设置横屏失败: ' + e)
    }

    // 初始化游戏并开始倒计时
    setTimeout(() => {
      this.initGame()
      this.startCountdown()
    }, 100)
  }

  startCountdown(): void {
    this.countdown = 3
    this.gameStarted = false

    this.countdownIntervalId = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        clearInterval(this.countdownIntervalId)
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
    if (this.countdownIntervalId !== -1) {
      clearInterval(this.countdownIntervalId)
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
    this.leftPaddleY = this.canvasHeight / 2 - this.aiPaddleHeight / 2
    this.rightPaddleY = this.canvasHeight / 2 - this.playerPaddleHeight / 2

    this.gameOver = false
  }

  // 重新发球
  resetBall(): void {
    this.ballX = this.canvasWidth / 2
    this.ballY = this.canvasHeight / 2
    this.ballVX = 5
    this.ballVY = 0
    this.gravityDirection = 1
    this.gameOver = false
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

    // 碰撞检测：左侧球拍（AI）
    let leftPaddleX = this.paddleWidth
    if (this.ballX - this.ballRadius < leftPaddleX &&
        this.ballX + this.ballRadius > 0 &&
        this.ballY > this.leftPaddleY &&
        this.ballY < this.leftPaddleY + this.aiPaddleHeight) {
      this.ballX = leftPaddleX + this.ballRadius
      this.ballVX = -this.ballVX * 1.05  // 反弹并稍微加速
      this.gravityDirection = -this.gravityDirection  // 反转重力
    }

    // 碰撞检测：右侧球拍（玩家）
    let rightPaddleX = this.canvasWidth - this.paddleWidth
    if (this.ballX + this.ballRadius > rightPaddleX &&
        this.ballX - this.ballRadius < this.canvasWidth &&
        this.ballY > this.rightPaddleY &&
        this.ballY < this.rightPaddleY + this.playerPaddleHeight) {
      this.ballX = rightPaddleX - this.ballRadius
      this.ballVX = -this.ballVX * 1.05
      this.gravityDirection = -this.gravityDirection
    }

    // 检测得分（球出界）
    if (this.ballX < 0) {
      // 玩家得分
      this.playerScore++
      this.gameOver = true
      // 延迟后重新发球
      setTimeout(() => {
        if (!this.showEndScreen) {
          this.resetBall()
        }
      }, 1000)
    }
    if (this.ballX > this.canvasWidth) {
      // AI得分
      this.aiScore++
      this.gameOver = true
      // 延迟后重新发球
      setTimeout(() => {
        if (!this.showEndScreen) {
          this.resetBall()
        }
      }, 1000)
    }

    // AI控制左侧球拍
    let targetY = this.ballY - this.aiPaddleHeight / 2
    let diff = targetY - this.leftPaddleY
    if (Math.abs(diff) > this.aiMaxSpeed) {
      this.leftPaddleY += diff > 0 ? this.aiMaxSpeed : -this.aiMaxSpeed
    } else {
      this.leftPaddleY += diff
    }
    // 限制球拍在画布内
    if (this.leftPaddleY < 0) this.leftPaddleY = 0
    if (this.leftPaddleY + this.aiPaddleHeight > this.canvasHeight) {
      this.leftPaddleY = this.canvasHeight - this.aiPaddleHeight
    }
  }

  // 触摸控制右侧球拍
  handleTouch(y: number): void {
    this.rightPaddleY = y - this.playerPaddleHeight / 2
    // 限制球拍在画布内
    if (this.rightPaddleY < 0) this.rightPaddleY = 0
    if (this.rightPaddleY + this.playerPaddleHeight > this.canvasHeight) {
      this.rightPaddleY = this.canvasHeight - this.playerPaddleHeight
    }
  }

  build() {
    NavDestination() {
      Stack() {
        // 游戏背景图 - 与游戏画布宽度对齐
        Image($r('app.media.Game_background'))
          .width(this.canvasWidth)
          .height(this.canvasHeight)
          .objectFit(ImageFit.Fill)

        Column() {
          // 游戏画布
          Stack() {
            // 游戏区域背景
            Column()
              .width('100%')
              .height('100%')
              .backgroundColor('transparent')  // 透明背景，显示底层背景图

            // 中线
            Rect()
              .width(2)
              .height(this.canvasHeight)
              .fill('#ffffff')
              .position({ x: this.canvasWidth / 2 - 1, y: 0 })

            // 左侧球拍（AI）
            Rect()
              .width(this.paddleWidth)
              .height(this.aiPaddleHeight)
              .fill('#e94560')
              .position({ x: 0, y: this.leftPaddleY })

            // 右侧球拍（玩家）
            Rect()
              .width(this.paddleWidth)
              .height(this.playerPaddleHeight)
              .fill('#0f3460')
              .position({ x: this.canvasWidth - this.paddleWidth, y: this.rightPaddleY })

            // 球
            Circle()
              .width(this.ballRadius * 2)
              .height(this.ballRadius * 2)
              .fill('#ffffff')
              .position({ x: this.ballX - this.ballRadius, y: this.ballY - this.ballRadius })

            // 比分显示（屏幕中间上方）
            Text(this.playerScore + ' : ' + this.aiScore)
              .fontSize(30)
              .fontColor('#ffffff')
              .fontWeight(FontWeight.Bold)
              .position({ x: this.canvasWidth / 2, y: 10 })
              .translate({ x: '-50%' })

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

            // 结束画面
            if (this.showEndScreen) {
              Column() {
                if (this.aiScore <= this.playerScore) {
                  Image($r('app.media.victory_imag'))
                    .width(300)
                    .height(150)
                } else {
                  Image($r('app.media.defeat_imag'))
                    .width(300)
                    .height(150)
                }
                Button('重新开始')
                  .margin({ top: 20 })
                  .backgroundColor('transparent')
                  .fontColor('#ffffff')
                  .fontSize(18)
                  .onClick(() => {
                    this.aiScore = 0
                    this.playerScore = 0
                    this.showEndScreen = false
                    this.initGame()
                    this.startCountdown()
                  })
                Button('返回')
                  .margin({ top: 10 })
                  .backgroundColor('transparent')
                  .fontColor('#ffffff')
                  .fontSize(18)
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
            if (this.gameStarted && !this.showEndScreen && (event.type === TouchType.Move || event.type === TouchType.Down)) {
              let touchY = event.touches[0].y
              this.handleTouch(touchY)
            }
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)

        // 结束按钮（左上角）
        if (!this.showEndScreen) {
          Button('结束')
            .width(70)
            .height(45)
            .fontSize(18)
            .backgroundColor('#F44336')
            .position({ x: 10, y: 10 })
            .onClick(() => {
              // 停止所有定时器
              if (this.intervalId !== -1) {
                clearInterval(this.intervalId)
              }
              if (this.countdownIntervalId !== -1) {
                clearInterval(this.countdownIntervalId)
              }
              // 停止游戏
              this.gameStarted = false
              this.showEndScreen = true
            })
        }

        // 暂停按钮
        if (this.gameStarted && !this.gameOver && !this.showEndScreen) {
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
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}
