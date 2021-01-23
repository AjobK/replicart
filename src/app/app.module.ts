import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HomeComponent } from './home/home.component';
import { ReplicasOverviewComponent } from './replicas-overview/replicas-overview.component';
import { ReplicaBlockComponent } from './replicas-overview/replica-block/replica-block.component';
import { ReplicaService } from './shared/services/replica.service';
import { NavigationComponent } from './shared/navigation/navigation.component';
import { HamburgerComponent } from './shared/hamburger/hamburger.component';
import { BasketService } from './shared/services/basket.service';
import { CheckoutComponent } from './checkout/checkout.component';
import { CheckoutItemComponent } from './checkout/checkout-item/checkout-item.component';
import { HttpClientModule } from '@angular/common/http';
import { LoginComponent } from './login/login.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { AuthGuardService } from './shared/guards/auth-guard.service';
import { OrdersOverviewComponent } from './orders-overview/orders-overview.component';
import { ManageComponent } from './manage/manage.component';
import { AdminGuardService } from './shared/guards/admin-guard.service';
import { ManageReplicaComponent } from './manage-replica/manage-replica.component';
import { RegisterComponent } from './register/register.component';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    ReplicasOverviewComponent,
    ReplicaBlockComponent,
    NavigationComponent,
    HamburgerComponent,
    CheckoutComponent,
    CheckoutItemComponent,
    LoginComponent,
    OrdersOverviewComponent,
    ManageComponent,
    ManageReplicaComponent,
    RegisterComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule
  ],
  providers: [ReplicaService, BasketService, AuthGuardService, AdminGuardService],
  bootstrap: [AppComponent]
})
export class AppModule { }
