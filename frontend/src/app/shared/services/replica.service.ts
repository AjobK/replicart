import { Subject } from 'rxjs';
import { Replica } from '../models/replica.model';
import {
    HttpClient,
    HttpResponse
} from '@angular/common/http';
import { Injectable } from '@angular/core';
import { environment } from 'src/environments/environment';
import { first } from 'rxjs/operators';

@Injectable()
export class ReplicaService {
    private replicas: Replica[] = [];

    replicasChanged = new Subject<Replica[]>();

    constructor(
        private http: HttpClient,
    ) {
        this.fetchReplicas();
    }

    fetchReplicas() {
        this.replicasChanged.next(this.replicas);

        this.http
        .get<any>(environment.API_URL + '/api/replica', environment.DEFAULT_HTTP_OPTIONS)
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
                        replica.image_url || 'https://i.guim.co.uk/img/media/26392d05302e02f7bf4eb143bb84c8097d09144b/446_167_3683_2210/master/3683.jpg?width=1200&height=1200&quality=85&auto=format&fit=crop&s=49ed3252c0b2ffb49cf8b508892e452d',
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

    getReplicaById(id: number) {
        return this.http
        .get<any>(environment.API_URL + `/api/replica/${id}`, environment.DEFAULT_HTTP_OPTIONS)
    }

    updateReplicaById(replicaData: {
        artist: string,
        name: string,
        origin: string,
        cost: number,
        year: number,
        imageUrl: string
    }, id: number) {

        return this.http
        .put<any>(environment.API_URL + `/api/replica/${id}`, replicaData, environment.DEFAULT_HTTP_OPTIONS)
    }

    createReplica(replicaData: {
        artist: string,
        name: string,
        origin: string,
        cost: number,
        year: number,
        imageUrl: string
    }) {
        return this.http
        .post<any>(environment.API_URL + `/api/replica`, replicaData, environment.DEFAULT_HTTP_OPTIONS)
    }

    removeReplica(replica: Replica) {
        this.http
        .delete<any>(environment.API_URL + `/api/replica/${replica.id}`, environment.DEFAULT_HTTP_OPTIONS)
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
