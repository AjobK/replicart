import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { CheckoutComponent } from './checkout/checkout.component';
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './login/login.component';
import { ManageComponent } from './manage/manage.component';
import { OrdersOverviewComponent } from './orders-overview/orders-overview.component';
import { ReplicasOverviewComponent } from './replicas-overview/replicas-overview.component';
import { AdminGuardService } from './shared/guards/admin-guard.service';
import { AuthGuardService } from './shared/guards/auth-guard.service';

const appRoutes: Routes = [
  {
    path: '',
    component: HomeComponent
  },
  {
    path: 'replicas',
    component: ReplicasOverviewComponent
  },
  {
    path: 'checkout',
    component: CheckoutComponent,
    canActivate: [AuthGuardService]
  },
  {
    path: 'login',
    component: LoginComponent
  },
  {
    path: 'orders',
    component: OrdersOverviewComponent,
    canActivate: [AuthGuardService]
  },
  {
    path: 'manage',
    component: ManageComponent,
    canActivate: [AuthGuardService, AdminGuardService]
  },
  {
    path: '**',
    redirectTo: '/'
  }
];

@NgModule({
  imports: [RouterModule.forRoot(appRoutes)],
  exports: [RouterModule]
})
export class AppRoutingModule {}
