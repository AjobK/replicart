// src/app/auth/auth-guard.service.ts
import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { AccountService } from '../services/account.service';

@Injectable({
  providedIn: 'root'
})
export class AuthGuardService implements CanActivate {
  constructor(public accountService: AccountService, public router: Router) {}

  canActivate(): boolean {
    if (!this.accountService.account.loggedIn) {
      this.router.navigate(['login']);

      return false;
    }

    return true;
  }
}