import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';
import { CheckoutComponent } from './checkout/checkout.component';
import { HomeComponent } from './home/home.component';
import { LoginComponent } from './login/login.component';
import { ManageReplicaComponent } from './manage-replica/manage-replica.component';
import { ManageComponent } from './manage/manage.component';
import { OrdersOverviewComponent } from './orders-overview/orders-overview.component';
import { RegisterComponent } from './register/register.component';
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
    path: 'register',
    component: RegisterComponent
  },
  {
    path: 'orders',
    component: OrdersOverviewComponent,
    canActivate: [AuthGuardService]
  },
  {
    path: 'manage/replica',
    component: ManageReplicaComponent,
    pathMatch: 'full',
    canActivate: [AuthGuardService, AdminGuardService]
  },
  {
    path: 'manage/replica/new',
    component: ManageReplicaComponent,
    data: { manageType: 'create' },
    pathMatch: 'full',
    canActivate: [AuthGuardService, AdminGuardService]
  },
  {
    path: 'manage/replica/:id',
    component: ManageReplicaComponent,
    canActivate: [AuthGuardService, AdminGuardService]
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
