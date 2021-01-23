import { Component, ElementRef, OnInit, Output } from '@angular/core';
import { Basket } from '../shared/models/basket.model';
import { Replica } from '../shared/models/replica.model';
import { BasketService } from '../shared/services/basket.service';
import { ReplicaService } from '../shared/services/replica.service';

@Component({
  selector: 'app-manage',
  templateUrl: './manage.component.html',
  styleUrls: ['./manage.component.scss']
})
export class ManageComponent implements OnInit {
  @Output() replicaList: Replica[] = [];

  constructor(
    public basketService: BasketService,
    public replicaService: ReplicaService,
    private elementRef: ElementRef
  ) { }

  ngOnInit(): void {
    this.replicaService.fetchReplicas();
    this.replicaList = this.replicaService.getReplicas();

    this.replicaService.replicasChanged.subscribe(res => this.replicaList = this.replicaService.getReplicas())

    this.elementRef.nativeElement.ownerDocument.body.classList.add('grey-body');
  }

  ngOnDestroy(): void {
    this.elementRef.nativeElement.ownerDocument.body.classList.remove('grey-body');
  }
}