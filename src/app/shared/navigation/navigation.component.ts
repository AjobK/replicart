import { Component, OnInit, Output } from '@angular/core';
import { AccountService } from '../services/account.service';
import { Basket } from '../models/basket.model';
import { BasketService } from '../services/basket.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-navigation',
  templateUrl: './navigation.component.html',
  styleUrls: ['./navigation.component.scss']
})
export class NavigationComponent implements OnInit {
    @Output() windowWidth: number;
    @Output() links = [
        ['HOME', '/'],
        ['REPLICAS', '/replicas'],
        ['LOGIN', '/login']
    ];
    @Output() menuOpen = false;
    @Output() basketSize = 0;
    accountChangedSubscription: Subscription;
    basketChangedSubscription: Subscription;

    constructor(private basketService: BasketService, public accountService: AccountService) {
        this.accountChangedSubscription = this.accountService.accountChanged.subscribe(
            (account) => {
                this.setLinks(account);
            }
        );

        this.setLinks(this.accountService.account);
    }

    ngOnInit(): void {
        this.windowWidth = window.innerWidth;
        this.basketChangedSubscription = this.basketService.basketChanged.subscribe(
            (basket: Basket) => {
                this.basketSize = basket.getReplicaCount();
            }
        );

        this.basketSize = this.basketService.getBasket().getReplicaCount();
    }

    setLinks(account): void {
        let newLinks = [
            ['HOME', '/'],
            ['REPLICAS', '/replicas'],
        ];

        if (!account.loggedIn)
            newLinks.push(['LOGIN', '/login'])

        if (account.roleName == 'Administrator')
            newLinks.push(['MANAGE', '/manage'])

        if (account.roleName == 'Customer')
            newLinks.push(['ORDERS', '/orders'])

        console.log('LINKS:')
        console.log(account)
        console.log(newLinks)

        this.links = newLinks;
    }

    toggleMenu(): void {
        this.windowWidth = window.innerWidth;
        this.menuOpen = !this.menuOpen 
    }

    ngOnDestroy(): void {
        this.accountChangedSubscription.unsubscribe();
        this.basketChangedSubscription.unsubscribe();
    }
}
