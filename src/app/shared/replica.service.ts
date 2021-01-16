import { Observable, Subject, throwError } from 'rxjs';
import { Replica } from './replica.model';
import {
    HttpClient,
    HttpErrorResponse,
    HttpHeaders
} from '@angular/common/http';
import { catchError } from 'rxjs/operators';
import { Injectable } from '@angular/core';

@Injectable()
export class ReplicaService {
  private replicas: Replica[] = []
//     new Replica (
//       1,
//       'William-Adolphe Bougereau',
//       'A Young Girl Defending Herself against Eros',
//       'France',
//       680,
//       'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg/1200px-A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg',
//       new Date()
//     ),
//     new Replica (
//       2,
//       'Johannes Vermeer',
//       'Lady with pearl earring',
//       'Netherlands',
//       940,
//       'https://i.imgur.com/sSM9iFa.png',
//       new Date()
//     ),
//     new Replica (
//       3,
//       '2William-Adolphe Bougereau',
//       'A Young Girl Defending Herself against Eros',
//       'France',
//       680,
//       'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg/1200px-A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg',
//       new Date()
//     ),
//     new Replica (
//       4,
//       '2Johannes Vermeer',
//       'Lady with pearl earring',
//       'Netherlands',
//       940,
//       'https://i.imgur.com/sSM9iFa.png',
//       new Date()
//     ),
//     new Replica (
//       6,
//       '3Johannes Vermeer',
//       'Lady with pearl earring',
//       'Netherlands',
//       940,
//       'https://i.imgur.com/sSM9iFa.png',
//       new Date()
//     ),
//     new Replica (
//       5,
//       '3William-Adolphe Bougereau',
//       'A Young Girl Defending Herself against Eros',
//       'France',
//       680,
//       'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg/1200px-A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg',
//       new Date()
//     ),
//     new Replica (
//       8,
//       '4Johannes Vermeer',
//       'Lady with pearl earring',
//       'Netherlands',
//       940,
//       'https://i.imgur.com/sSM9iFa.png',
//       new Date()
//     ),
//     new Replica (
//       7,
//       '4William-Adolphe Bougereau',
//       'A Young Girl Defending Herself against Eros',
//       'France',
//       680,
//       'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg/1200px-A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg',
//       new Date()
//     )
//   ];

  replicasChanged = new Subject<Replica[]>();

  constructor(
    private http: HttpClient
  ) {
    this.replicasChanged.next(this.replicas);

    this.http
    .get<any>('http://localhost:8080/api/replica')
    .subscribe(res => {
        res.replicas.map((replica) => {
            this.replicas.push(new Replica(
                replica.id,
                replica.artist,
                replica.name,
                replica.origin,
                replica.cost,
                replica.image_url,
                replica.year
            ))
        })

        this.replicasChanged.next(this.replicas);
    })
  }

  setReplicas(replicas: Replica[]) {
    this.replicas = replicas;
  }

  getReplicas() {
    return this.replicas.slice();
  }

  getReplica(index: number) {
    return this.replicas[index];
  }
}
