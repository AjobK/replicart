import { Component, Input, OnInit } from '@angular/core';
import { BasketService } from 'src/app/shared/basket.service';
import { Replica } from 'src/app/shared/replica.model';

@Component({
  selector: 'app-checkout-item',
  templateUrl: './checkout-item.component.html',
  styleUrls: ['./checkout-item.component.scss']
})
export class CheckoutItemComponent implements OnInit {
  @Input() replicaItem: { replica: Replica, amount: number };

  constructor(public basketService: BasketService) { }

  ngOnInit(): void { }

  increaseAmount() {
    this.basketService.addReplica(this.replicaItem.replica)
  }

  decreaseAmount() {
    this.basketService.removeReplica(this.replicaItem.replica);
  }
}
