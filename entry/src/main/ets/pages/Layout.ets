import { Shop } from "./Shop"
import { Mine } from "./Mine"
import { Square } from "./Square"

interface TabClass {
  text: string
  icon: ResourceStr
}

@Builder
export function LayoutBuilder() {
  Layout()
}

@Component
struct Layout {
  @State currentIndex: number = 0
  // 控制跳转对象
  pathStack: NavPathStack = new NavPathStack()
  tabData: TabClass[]=[
    {text:'广场', icon: $r('app.media.icn_tab_square')},
    {text:'商店', icon: $r('app.media.icn_tab_shop')},
    {text:'规则',icon: $r('app.media.icn_tab_mine')}
  ]

  @Builder
  tabBuilder (item: TabClass, index: number) {
    Column({ space: 5 }){
      Image(item.icon)
        .width(26)
        .fillColor(this.currentIndex === index ? '#E85A88' : '#63AAAA')
      Text(item.text)
        .fontSize(15)
        .fontColor('#63AAAA')
    }
  }

  build() {
    NavDestination() {
      Tabs({ barPosition : BarPosition.End }) {
        ForEach(this.tabData, (item: TabClass, index: number)=>{
          TabContent() {
            if (this.currentIndex === 0) {
              Square()
            }
            else if (this.currentIndex === 1) {
              Shop()
            }
            else if (this.currentIndex === 2) {
              Mine()
            }
          }
          .tabBar(this.tabBuilder(item, index))
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        })
      }
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    //.title('布局页')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      // 存储到 AppStorage
      AppStorage.setOrCreate<NavPathStack>('pathStack', this.pathStack)
    })
  }
}