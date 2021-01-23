import { HttpResponse } from '@angular/common/http';
import { Component, ElementRef, OnInit, Output, ViewChild } from '@angular/core';
import { NgForm } from '@angular/forms';
import { Router } from '@angular/router';
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

    constructor(
        private elementRef: ElementRef,
        private accountService: AccountService,
        private router: Router
    ) { }

    ngOnInit(): void {
        this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
    }

    onSubmit(form: NgForm) {
        if (form.value.password != form.value.repeatPassword) {
            this.hasErrors = true;

            this.form.statusChanges.pipe(first()).subscribe(res => { if (this.hasErrors) this.hasErrors = false; });
            return;
        }
        this.accountService.register(form.value.username, form.value.password)
        .subscribe(
            (res: HttpResponse<any>) => {
                const { username, roleName } = res.body;
                
                this.accountService.account = new Account(username || '', roleName || '', true);
                this.accountService.accountChanged.next(this.accountService.account);

                this.router.navigate(['replicas']);
            },
            () => {
                this.hasErrors = true;
                this.form.reset();

                this.form.statusChanges.pipe(first()).subscribe(res => { if (this.hasErrors) this.hasErrors = false; });
            }
        )
    }

    ngOnDestroy(): void {
        this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
    }
}
