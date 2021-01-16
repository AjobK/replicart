export class Replica {
    public id: number;
    public artist: string;
    public name: string;
    public origin: string;
    public cost: number;
    public imageUrl: string;
    public year: number
    public width: number;
    public height: number;

    constructor(
        id: number,
        artist: string,
        name: string,
        origin: string,
        cost: number,
        imageUrl: string,
        year: number,
    ) {
        this.id = id;
        this.artist = artist;
        this.name = name;
        this.origin = origin;
        this.cost = cost % ~~cost == 0 ? ~~cost : cost; // Removes zeros from rounded price
        this.imageUrl = imageUrl;
        this.year = year;

        let img = new Image();

        img.addEventListener('load', () => {
            this.width = img.width;
            this.height = img.height;
        });

        img.src = this.imageUrl;
    }
}
