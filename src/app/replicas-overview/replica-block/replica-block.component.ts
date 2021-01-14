import { Component, Input, OnInit } from '@angular/core';
import { BasketService } from 'src/app/shared/basket.service';
import { Replica } from 'src/app/shared/replica.model';
import { ReplicaService } from 'src/app/shared/replica.service';

@Component({
  selector: 'app-replica-block',
  templateUrl: './replica-block.component.html',
  styleUrls: ['./replica-block.component.scss']
})
export class ReplicaBlockComponent implements OnInit {
    @Input() replica: Replica;
    @Input() index: number;

    constructor(
        private basketService: BasketService
    ) { }

    ngOnInit(): void {
        // Temporary
        // this.basketService.addReplica(this.replica)
    }

    addToCart(): void {
        this.basketService.addReplica(this.replica);
    }
}
