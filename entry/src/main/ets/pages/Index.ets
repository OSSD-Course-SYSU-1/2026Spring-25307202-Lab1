@Entry
@Component
struct SystemRoutingTable {
  pageStack : NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack){
    }.onAppear(() => {
      this.pageStack.pushPathByName('Start', null, false);
    })
    .hideNavBar(true)
  }
}