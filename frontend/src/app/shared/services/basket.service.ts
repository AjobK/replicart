import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Subject } from 'rxjs';
import { environment } from 'src/environments/environment';
import { Basket } from '../models/basket.model';
import { Replica } from '../models/replica.model';
import { AccountService } from './account.service';

@Injectable({
  providedIn: 'root'
})
export class BasketService {
    public basketChanged = new Subject<Basket>();
    private basket = new Basket([]);

    constructor(private http: HttpClient, private router: Router, private accountService: AccountService) {
        this.basketChanged.next(this.basket);

        accountService.accountChanged.subscribe((account) => {
            if (!account.loggedIn) {
                this.clearBasket();
            } else {
                this.basket.storedReplicas = [];
                this.fetchBasketItems();
            }
        })
    }

    fetchBasketItems() {
        this.http
        .get<any>('http://localhost:8080/api/basket-item', environment.DEFAULT_HTTP_OPTIONS)
        .subscribe(
            (res: HttpResponse<any>) => {
                if (!res.body.basketItems) return;

                res.body.basketItems.map((item) => {
                    this.basket.storedReplicas.push({ replica: new Replica(
                        item.replica.id,
                        item.replica.artist,
                        item.replica.name,
                        item.replica.origin,
                        item.replica.cost,
                        item.replica.imageUrl,
                        item.replica.year
                    ), amount: item.quantity });
                })

                this.basketChanged.next(this.basket);
            }
        )
    }

    addReplica(replica: Replica) {
        let replicaIndex = -1;

        for (let i = 0; i < this.basket.storedReplicas.length; i++) {
            if (replica.id == this.basket.storedReplicas[i].replica.id) {
                replicaIndex = i;
            }
        }

        this.http
        .post<any>('http://localhost:8080/api/basket-item', {
            replicaId: replica.id,
            quantity: replicaIndex == -1 ? 1 : this.basket.storedReplicas[replicaIndex].amount+1
        }, environment.DEFAULT_HTTP_OPTIONS)
        .subscribe(
            (res: HttpResponse<any>) => {
                if (replicaIndex != -1)
                    this.basket.storedReplicas[replicaIndex].amount++;
                else
                    this.basket.storedReplicas.push({'replica': replica, 'amount': 1});

                this.basketChanged.next(this.basket);
            }
        )
    }

    updateBasketItem(basketItem: { replica: Replica, amount: number }) {
        let replicaIndex = -1;

        for (let i = 0; i < this.basket.storedReplicas.length; i++) {
            if (basketItem.replica.id == this.basket.storedReplicas[i].replica.id) {
                replicaIndex = i;
            }
        }

        if (replicaIndex == -1) return;

        this.http
        .put<any>('http://localhost:8080/api/basket-item', {
            replicaId: basketItem.replica.id,
            quantity: basketItem.amount
        }, environment.DEFAULT_HTTP_OPTIONS)
        .subscribe(
            (res: HttpResponse<any>) => {
                if (basketItem.amount <= 0)
                    this.basket.storedReplicas.splice(replicaIndex, 1);
                else
                    this.basket.storedReplicas[replicaIndex].amount = basketItem.amount;

                this.basketChanged.next(this.basket);
            }
        )
    }

    removeReplica(replica: Replica) {
        for (let i = 0; i < this.basket.storedReplicas.length; i++) {
            if (replica.id == this.basket.storedReplicas[i].replica.id) {
                this.updateBasketItem({ replica: replica, amount: this.basket.storedReplicas[i].amount-1});

                return;
            }
        }
    }

    getBasket() {
        return this.basket;
    }

    clearBasket() {
        this.basket.storedReplicas = [];
        this.basketChanged.next(this.basket);
    }

    clearBasketItems() {
        this.http
        .delete<any>('http://localhost:8080/api/basket-item', environment.DEFAULT_HTTP_OPTIONS)
        .subscribe(() => {
            this.clearBasket()
        });
    }

    sendOrder() {
        this.http
        .post<any>('http://localhost:8080/api/order', { 'orderItems': this.basket.storedReplicas }, environment.DEFAULT_HTTP_OPTIONS)
        .subscribe(
            (res: HttpResponse<any>) => {
                this.clearBasketItems();
                this.basketChanged.next(this.basket);
                this.router.navigate(['orders']);
            }
        )
    }
}
