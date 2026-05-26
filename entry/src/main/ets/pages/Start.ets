@Builder
export function StartBuilder() {
  Start()
}

@Component
struct Start {
  pathStack: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      Button("跳过")
        .onClick(() => {
          this.pathStack.pushPathByName('Layout', null, false);
        })
    }
    .title('广告页')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
  }
}