import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { ReplicasOverviewComponent } from './replicas-overview/replicas-overview.component';
import { ReplicaBlockComponent } from './replicas-overview/replica-block/replica-block.component';
import { ReplicaService } from './shared/replica.service';
import { NavigationComponent } from './shared/navigation/navigation.component';
import { HamburgerComponent } from './shared/hamburger/hamburger.component';
import { BasketService } from './shared/basket.service';
import { CheckoutComponent } from './checkout/checkout.component';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    ReplicasOverviewComponent,
    ReplicaBlockComponent,
    NavigationComponent,
    HamburgerComponent,
    CheckoutComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [ReplicaService, BasketService],
  bootstrap: [AppComponent]
})
export class AppModule { }
