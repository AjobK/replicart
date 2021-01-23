import { Component, Input, OnInit } from '@angular/core';
import { BasketService } from 'src/app/shared/services/basket.service';
import { Replica } from 'src/app/shared/models/replica.model';
import { ReplicaService } from 'src/app/shared/services/replica.service';

@Component({
  selector: 'app-checkout-item',
  templateUrl: './checkout-item.component.html',
  styleUrls: ['./checkout-item.component.scss']
})
export class CheckoutItemComponent implements OnInit {
  @Input() replicaItem: { replica: Replica, amount: number };
  @Input() noButtons: boolean = false;
  @Input() adminView: boolean = false;
  @Input() customClasses: string;

  constructor(public basketService: BasketService, public replicaService: ReplicaService) { }

  ngOnInit(): void { }

  increaseAmount() {
    // this.basketService.addReplica(this.replicaItem.replica)
    this.replicaItem.amount++;
    this.basketService.updateBasketItem(this.replicaItem);
  }
  
  decreaseAmount() {
    this.replicaItem.amount--;
    this.basketService.updateBasketItem(this.replicaItem);
  }
}
