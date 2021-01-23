export class Account {
    public username: string;
    public roleName: string;
    public loggedIn: boolean;
    public orders: any;

    constructor(
        username: string,
        roleName: string,
        loggedIn: boolean
    ) {
        this.username = username;
        this.roleName = roleName;
        this.loggedIn = loggedIn;
    }

    setOrders(orders) {
        this.orders = orders;
    }
}
