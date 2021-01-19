import { Observable, Subject, throwError } from 'rxjs';
import { Replica } from '../models/replica.model';
import {
    HttpClient,
    HttpErrorResponse,
    HttpHeaders,
    HttpResponse
} from '@angular/common/http';
import { catchError, first } from 'rxjs/operators';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';

@Injectable()
export class ReplicaService {
    private replicas: Replica[] = [];

    replicasChanged = new Subject<Replica[]>();

    constructor(
        private http: HttpClient,
        private router: Router
    ) {
        this.fetchReplicas();
    }

  fetchReplicas() {
    this.replicasChanged.next(this.replicas);
    
    const httpOptions = {
        headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
      
        withCredentials: true, 
        observe: 'response' as 'response'
    };

    this.http
    .get<any>('http://localhost:8080/api/replica', httpOptions)
    .subscribe(
        (res: HttpResponse<any>) => {
            this.replicas = [];
            res.body.replicas.map((replica) => {
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
        }
    )
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

  removeReplica(replica: Replica) {
    const httpOptions = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json' }),
    
      withCredentials: true, 
      observe: 'response' as 'response'
    };

    this.http
    .delete<any>(`http://localhost:8080/api/replica/${replica.id}`, httpOptions)
    .pipe(first())
    .subscribe(
      (res: HttpResponse<any>) => {
        for (let i = 0; i < this.replicas.length; i++) {
          if (this.replicas[i].id == replica.id) {
            this.replicas.splice(i, 1);
            this.replicasChanged.next(this.replicas);
            break;
          }
        }
      }
    )
  }
}
