import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse, HttpHeaders, HttpResponse } from '@angular/common/http';
import { Router } from '@angular/router';
import { Subject } from 'rxjs';
import { Account } from '../models/account.model';
import { logging } from 'protractor';
import { Replica } from '../models/replica.model';
import { BasketService } from './basket.service';


@Injectable({
  providedIn: 'root'
})
export class AccountService {
    account: Account = new Account('', '', false);
    accountChanged: Subject<Account> = new Subject<Account>();

    constructor(private http: HttpClient, private router: Router, private basketService: BasketService) {
        const httpOptions = {
            headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
            
            withCredentials: true, 
            observe: 'response' as 'response'
        };

        this.http
        .get<any>(
            'http://localhost:8080/api/auth/login-check',
            httpOptions
        ).subscribe((res: HttpResponse<any>) => {
            const { loggedIn, username, roleName } = res.body;

            this.account = new Account(username || '', roleName || '', loggedIn);
            this.accountChanged.next(this.account);
        });

        this.accountChanged.next(this.account);
    }

    login(username: string, password: string) {
        const httpOptions = {
            headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
           
            withCredentials: true, 
            observe: 'response' as 'response'
        };  
          
        return this.http
        .post<any>(
            'http://localhost:8080/api/auth/login',
            {
                username: username,
                password: password
            },
            httpOptions
        )
    }

    logout() {
        const httpOptions = {
            headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
            
            withCredentials: true, 
            observe: 'response' as 'response'
        };

        this.http
        .get<any>(
            'http://localhost:8080/api/auth/logout',
            httpOptions
        ).subscribe((res: HttpResponse<any>) => {
            this.account = new Account('', '', false);
            this.accountChanged.next(this.account);
            this.basketService.clearBasket();
            this.router.navigate(['/login']);
        })
    }

    fetchOrders() {
        const httpOptions = {
            headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
            
            withCredentials: true, 
            observe: 'response' as 'response'
        };

        this.http
        .get<any>(
            'http://localhost:8080/api/order',
            httpOptions
        ).subscribe((res: HttpResponse<any>) => {
            let orders = [];

            Object.keys(res.body.orders).forEach(order => {
                let newOrder = [];
                for (let i = 0; i < res.body.orders[order].length; i++) {
                    newOrder.push({
                        replica: new Replica(
                            res.body.orders[order][i].id,
                            res.body.orders[order][i].artist,
                            res.body.orders[order][i].name,
                            res.body.orders[order][i].origin,
                            res.body.orders[order][i].cost,
                            res.body.orders[order][i].image_url,
                            res.body.orders[order][i].year
                        ),
                        amount: res.body.orders[order][i].quantity
                    })
                }
                orders.push(newOrder);
            });

            this.account.setOrders(orders);
            this.accountChanged.next(this.account);
        });
    }
}
