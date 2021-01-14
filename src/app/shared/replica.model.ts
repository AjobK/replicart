export class Replica {
    public id: number;
    public artist: string;
    public name: string;
    public origin: string;
    public cost: number;
    public imageUrl: string;
    public date: Date

    constructor(
        id: number,
        artist: string,
        name: string,
        origin: string,
        cost: number,
        imageUrl: string,
        date: Date
    ) {
        this.id = id;
        this.artist = artist;
        this.name = name;
        this.origin = origin;
        this.cost = cost;
        this.imageUrl = imageUrl;
        this.date = date;
    }
}
