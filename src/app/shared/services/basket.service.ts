import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Subject } from 'rxjs';
import { Basket } from '../models/basket.model';
import { Replica } from '../models/replica.model';

@Injectable({
  providedIn: 'root'
})
export class BasketService {
    public basketChanged = new Subject<Basket>();
    private basket = new Basket([]);

    constructor(private http: HttpClient, private router: Router) {
        this.basketChanged.next(this.basket);
    }

    addReplica(replica: Replica) {
        for (let i = 0; i < this.basket.storedReplicas.length; i++) {
            if (replica.id == this.basket.storedReplicas[i].replica.id) {
                this.basket.storedReplicas[i].amount++;
                this.basketChanged.next(this.basket);

                return;
            }
        }

        this.basket.storedReplicas.push({'replica': replica, 'amount': 1})
        this.basketChanged.next(this.basket);
    }

    removeReplica(replica: Replica) {
        for (let i = 0; i < this.basket.storedReplicas.length; i++) {
            if (replica.id == this.basket.storedReplicas[i].replica.id) {
                this.basket.storedReplicas[i].amount--;

                if (this.basket.storedReplicas[i].amount <= 0)
                    this.basket.storedReplicas.splice(i, 1);
                    this.basketChanged.next(this.basket);

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

    sendOrder() {
        const httpOptions = {
            headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
            
            withCredentials: true, 
            observe: 'response' as 'response'
        };

        this.http
        .post<any>('http://localhost:8080/api/order', { 'orderItems': this.basket.storedReplicas }, httpOptions)
        .subscribe(
            (res: HttpResponse<any>) => {
                this.basket.storedReplicas = [];
                this.basketChanged.next(this.basket);
                this.router.navigate(['/orders']);
            }
        )
    }
}
