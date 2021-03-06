import { HttpResponse } from '@angular/common/http';
import { Component, ElementRef, OnInit, Output, ViewChild } from '@angular/core';
import { NgForm } from '@angular/forms';
import { Router } from '@angular/router';
import { Subscription } from 'rxjs';
import { first } from 'rxjs/operators';
import { Account } from '../shared/models/account.model';
import { AccountService } from '../shared/services/account.service';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent implements OnInit {
    @ViewChild('authForm') form: NgForm;
    @Output() hasErrors: boolean = false
    isLoading = false;
    accountChangedSubscription: Subscription;
    errorMessage: string;

    constructor(
        private elementRef: ElementRef,
        private accountService: AccountService,
        private router: Router
    ) { }

    ngOnInit(): void {
        this.accountChangedSubscription = this.accountService.accountChanged.subscribe((account) => {
            if (account.loggedIn) this.router.navigate(['replicas']);
        })
        this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
    }

    onSubmit(form: NgForm) {
        if (form.value.password != form.value.repeatPassword) {
            this.hasErrors = true;
            this.errorMessage = 'Passwords do not match'

            this.form.statusChanges.pipe(first()).subscribe(res => {
                if (this.hasErrors) {
                    this.hasErrors = false;
                    this.errorMessage = undefined;
                }
            });
            return;
        }
        this.accountService.register(form.value.username, form.value.password)
        .pipe(first())
        .subscribe(
            (res: HttpResponse<any>) => {
                const { username, roleName, loggedIn } = res.body;
                
                this.accountService.account = new Account(username || '', roleName || '', loggedIn || false);
                this.accountService.accountChanged.next(this.accountService.account);

                this.router.navigate(['replicas']);
            },
            (res) => {
                this.hasErrors = true;
                this.errorMessage = res.error.message.split('\n').join('\n');

                this.form.statusChanges.pipe(first()).subscribe(res => {
                    if (this.hasErrors) {
                        this.hasErrors = false;
                        this.errorMessage = undefined;
                    }
                });
            }
        )
    }

    ngOnDestroy(): void {
        this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
        this.accountChangedSubscription.unsubscribe();
    }
}
