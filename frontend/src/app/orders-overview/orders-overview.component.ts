import { Component, ElementRef, OnInit } from '@angular/core';
import { Subscription } from 'rxjs';
import { AccountService } from '../shared/services/account.service';

@Component({
  selector: 'app-orders-overview',
  templateUrl: './orders-overview.component.html',
  styleUrls: ['./orders-overview.component.scss']
})
export class OrdersOverviewComponent implements OnInit {
    orders: any = [];
    accountChangedSubscription: Subscription;

    constructor(public accountService: AccountService, private elementRef: ElementRef) { }

    ngOnInit(): void {
        this.accountChangedSubscription = this.accountService.accountChanged.subscribe((account) => {
            this.orders = account.orders;
        })
        this.accountService.fetchOrders();
        this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
    }

    ngOnDestroy(): void {
        this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
        this.accountChangedSubscription.unsubscribe();
    }
}
