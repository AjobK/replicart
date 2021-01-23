import { Component, ElementRef, OnInit, Output } from '@angular/core';
import { Basket } from '../shared/models/basket.model';
import { BasketService } from '../shared/services/basket.service';
import { Replica } from '../shared/models/replica.model';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-checkout',
  templateUrl: './checkout.component.html',
  styleUrls: ['./checkout.component.scss']
})
export class CheckoutComponent implements OnInit {
  @Output() replicaList: Array<{replica: Replica, amount: number}> = [];
  basketChangedSubscription: Subscription;

  constructor(public basketService: BasketService, private elementRef: ElementRef) { }

  ngOnInit(): void {
    this.basketChangedSubscription = this.basketService.basketChanged.subscribe(
      (basket: Basket) => {
          this.replicaList = basket.getReplicas();
      }
    )

    this.replicaList = this.basketService.getBasket().getReplicas();

    this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
  }

  ngOnDestroy(): void {
    this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
    this.basketChangedSubscription.unsubscribe();
  }
}
