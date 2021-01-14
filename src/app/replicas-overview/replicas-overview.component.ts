import { Component, HostListener, OnInit, Output } from '@angular/core';
import { Subscription } from 'rxjs';
import { Replica } from '../shared/replica.model';
import { ReplicaService } from '../shared/replica.service';

@Component({
  selector: 'app-replicas-overview',
  templateUrl: './replicas-overview.component.html',
  styleUrls: ['./replicas-overview.component.scss']
})
export class ReplicasOverviewComponent implements OnInit {
  @Output() columnSize = 4;
  replicas: Replica[];
  replicaLists = []
  subscription: Subscription;
  
  constructor(private replicaService: ReplicaService) { }

  ngOnInit(): void {
    this.subscription = this.replicaService.replicasChanged
    .subscribe(
      (replicas: Replica[]) => {
        this.replicas = replicas;
        
        this.setColumnSizeAutomatically(window.innerWidth);
        this.buildReplicaLists();
      }
    );

    this.replicas = this.replicaService.getReplicas();
    this.setColumnSizeAutomatically(window.innerWidth);
    this.buildReplicaLists();
  }

  buildReplicaLists(): void {
    this.replicaLists = [[], [], [], []];
    for (let i = 0; i < this.replicas.length; i++) {
      if (!this.replicaLists[i % this.columnSize])
        this.replicaLists[i % this.columnSize] = [];

      this.replicaLists[i % this.columnSize].push(this.replicas[i]);
    }
  }

  @HostListener('window:resize', ['$event'])
  onResize(event) {
    const { innerWidth } = event.target;

    this.setColumnSizeAutomatically(innerWidth);
  }

  setColumnSizeAutomatically(innerWidth) {
    let newColumnSize = 0;

    if (innerWidth < 640)
      newColumnSize = 1;
    else if (innerWidth < 960)
      newColumnSize = 2;
    else if (innerWidth < 1200)
      newColumnSize = 3;
    else
      newColumnSize = 4;

    if (newColumnSize != 0 && newColumnSize != this.columnSize) {
      this.columnSize = newColumnSize;
      this.buildReplicaLists();
    }
  }
}
