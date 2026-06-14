import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import preferences from '@ohos.data.preferences';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 先设置默认值，确保AppStorage中有coins和paddleUpgrade
    AppStorage.setOrCreate('coins', 0);
    AppStorage.setOrCreate('paddleUpgrade', 0);
    
    // 异步从本地存储读取数据并更新
    try {
      preferences.getPreferences(this.context, 'game_data').then((prefs) => {
        // 读取金币
        prefs.get('coins', 0).then((value) => {
          let coins = value as number;
          AppStorage.setOrCreate('coins', coins);
          hilog.info(DOMAIN, 'testTag', 'Loaded coins: %{public}d', coins);
        });
        // 读取升级次数
        prefs.get('paddleUpgrade', 0).then((value) => {
          let paddleUpgrade = value as number;
          AppStorage.setOrCreate('paddleUpgrade', paddleUpgrade);
          hilog.info(DOMAIN, 'testTag', 'Loaded paddleUpgrade: %{public}d', paddleUpgrade);
        });
      });
    } catch (e) {
      hilog.error(DOMAIN, 'testTag', 'Failed to load data: %{public}s', JSON.stringify(e));
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}