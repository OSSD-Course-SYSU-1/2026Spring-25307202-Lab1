import { StartBuilder } from './Start'
import { LayoutBuilder } from './Layout'
import { SinglePlayerBuilder } from './Single-player'
import { TwoPlayersBuilder } from './Two-players'
import { EndlessModeBuilder } from './Endless-mode'

@Entry
@Component
struct SystemRoutingTable {
  pageStack : NavPathStack = new NavPathStack();

  @Builder
  pageMap(name: string) {
    if (name === 'Start') {
      StartBuilder()
    } else if (name === 'Layout') {
      LayoutBuilder()
    } else if (name === 'SinglePlayer') {
      SinglePlayerBuilder()
    } else if (name === 'TwoPlayers') {
      TwoPlayersBuilder()
    } else if (name === 'EndlessMode') {
      EndlessModeBuilder()
    }
  }

  build() {
    Navigation(this.pageStack){
    }.navDestination(this.pageMap)
    .onAppear(() => {
      this.pageStack.pushPathByName('Start', null, false);
    })
    .hideNavBar(true)
  }
}