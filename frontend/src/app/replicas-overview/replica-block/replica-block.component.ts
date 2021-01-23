import { Component, Input, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { AccountService } from 'src/app/shared/services/account.service';
import { BasketService } from 'src/app/shared/services/basket.service';
import { Replica } from 'src/app/shared/models/replica.model';
import { ReplicaService } from 'src/app/shared/services/replica.service';

@Component({
  selector: 'app-replica-block',
  templateUrl: './replica-block.component.html',
  styleUrls: ['./replica-block.component.scss']
})
export class ReplicaBlockComponent implements OnInit {
    @Input() replica: Replica;
    @Input() index: number;

    constructor(
        private basketService: BasketService,
        private router: Router,
        public accountService: AccountService
    ) { }

    ngOnInit(): void { }

    addToCart(): void {
        if (!this.accountService.account.loggedIn)
            this.router.navigate(['login'])
        else
            this.basketService.addReplica(this.replica);
    }
}
