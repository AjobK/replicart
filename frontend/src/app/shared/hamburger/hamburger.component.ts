import { Component, Input, OnInit, Output } from '@angular/core';

@Component({
  selector: 'app-hamburger',
  templateUrl: './hamburger.component.html',
  styleUrls: ['./hamburger.component.scss']
})
export class HamburgerComponent implements OnInit {
  @Output() open;

  constructor() { }

  ngOnInit(): void {
  }

  toggle(): void {
    this.open = !this.open;
  }
}
