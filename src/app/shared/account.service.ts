import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Router } from '@angular/router';


@Injectable({
  providedIn: 'root'
})
export class AccountService {

    constructor(private http: HttpClient, private router: Router) { }

    login(username: string, password: string) {
        return this.http
        .post<any>(
            'http://localhost:8080/api/auth/login',
            {
                username: username,
                password: password
            }
        ).subscribe((res) => {
            console.log([res.id, res.token, res.username]);
        });
    }
}
