import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { AccountService } from '../services/account.service';

@Injectable({
  providedIn: 'root'
})
export class AdminGuardService implements CanActivate {
  constructor(public accountService: AccountService, public router: Router) {}

  canActivate(): boolean {
    if (this.accountService.account.roleName != 'Administrator') {
      this.router.navigate(['']);

      return false;
    }

    return true;
  }
}