import { Component } from '@angular/core';

import { MinePage } from '../mine/mine';
import { HomePage } from '../home/home';
import { PlusPage } from '../plus/plus';

@Component({
  templateUrl: 'tabs.html'
})
export class TabsPage {

  tab1Root = HomePage;
  tab2Root = PlusPage;
  tab3Root = MinePage;

  constructor() {

  }
}
