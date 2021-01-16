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
  @Output() replicaListsLoaded = false;
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
        this.buildReplicaLists()
      }
    );

    this.replicas = this.replicaService.getReplicas();
    this.setColumnSizeAutomatically(window.innerWidth);
    this.buildReplicaLists()
  }

    buildReplicaLists(): void {
        this.replicaListsLoaded = false;

        let replicaHasSizeList = this.replicas.map(replica => replica.height == undefined || replica.width == undefined);
        let replicasWithoutSize = replicaHasSizeList.filter(i => i == true);

        // Recursion, makes sure size of replicas is readable
        if (replicasWithoutSize.length > 0) {
            setTimeout(() => this.buildReplicaLists(), 100);
            return;
        }

        this.replicaLists = [];

        for (let i = 0; i < this.columnSize; i++) {
            this.replicaLists.push([]);
        }

        // Makes sure all the replicas are placed in the shortest list each time
        // to maintain a healthy size of each list
        for (let i = 0; i < this.replicas.length; i++) {
            let bestList = [0, Infinity]
            for (let y = 0; y < this.replicaLists.length; y++) {
                let totalRatioStack = 0;
                for (let x = 0; x < this.replicaLists[y].length; x++) {
                    // Since sizes can differ and the images are scaled down to the width of the parent
                    // we need to use the width/height ratio instead of raw height in pixels
                    totalRatioStack += this.replicaLists[y][x].height / this.replicaLists[y][x].width;
                }
                if (totalRatioStack < bestList[1]) bestList = [y, totalRatioStack];
            }

            console.log(this.replicas[i].name + ' placed in list ' + bestList[0] + '/' + (this.columnSize-1))
            this.replicaLists[bestList[0]].push(this.replicas[i]);
        }

        this.replicaListsLoaded = true;
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
