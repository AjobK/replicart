import { Replica } from './replica.model';

export class Basket {
    public storedReplicas: Array<{replica: Replica, amount: number}>

    constructor(
        storedReplicas: Array<{replica: Replica, amount: number}> = []
    ) {
        this.storedReplicas = storedReplicas
    }

    getSize() {
        return this.storedReplicas.length;
    }

    getReplicaCount() {
        let count: number = 0;

        for (let i = 0; i < this.storedReplicas.length; i++)
            count += this.storedReplicas[i].amount;

        return count;
    }

    getReplicas() {
        return this.storedReplicas;
    }

    getTotalCost() {
        let totalCost: number = 0;

        for (let i = 0; i < this.storedReplicas.length; i++)
            totalCost += this.storedReplicas[i].amount * this.storedReplicas[i].replica.cost;

        return totalCost;
    }
}
