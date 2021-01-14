import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';
import { Basket } from './basket';
import { Replica } from './replica.model';

@Injectable({
  providedIn: 'root'
})
export class BasketService {
    public basketChanged = new Subject<Basket>();
    private basket = new Basket([]);

    constructor() {
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
}
