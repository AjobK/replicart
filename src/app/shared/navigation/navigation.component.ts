import { Component, OnInit, Output } from '@angular/core';
import { Basket } from '../basket';
import { BasketService } from '../basket.service';

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
  ]

  @Output() menuOpen = false;
  @Output() basketSize = 0;

  constructor(
    private basketService: BasketService
  ) { }

  ngOnInit(): void {
    this.windowWidth = window.innerWidth;
    this.basketService.basketChanged.subscribe(
      (basket: Basket) => {
          this.basketSize = basket.getReplicaCount();
      }
    )

    this.basketSize = this.basketService.getBasket().getReplicaCount();
  }

  toggleMenu(): void {
    this.windowWidth = window.innerWidth;
    this.menuOpen = !this.menuOpen 
  }
}
