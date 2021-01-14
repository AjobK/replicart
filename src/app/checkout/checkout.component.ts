import { Component, ElementRef, OnInit, Output } from '@angular/core';
import { Basket } from '../shared/basket';
import { BasketService } from '../shared/basket.service';
import { Replica } from '../shared/replica.model';

@Component({
  selector: 'app-checkout',
  templateUrl: './checkout.component.html',
  styleUrls: ['./checkout.component.scss']
})
export class CheckoutComponent implements OnInit {
  @Output() replicaList: Array<{replica: Replica, amount: number}> = [];

  constructor(private basketService: BasketService, private elementRef: ElementRef) { }

  ngOnInit(): void {
    this.basketService.basketChanged.subscribe(
      (basket: Basket) => {
          this.replicaList = basket.getReplicas();
      }
    )

    this.replicaList = this.basketService.getBasket().getReplicas();

    console.log(this.replicaList)

    this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
  }

  ngOnDestroy(): void {
    this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
  }
}
