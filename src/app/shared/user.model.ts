export class User {
    public username: String;
    public email: String;
    public token: String;
    public roleId: number;

    constructor(
        username: String,
        email: String,
        token: String,
        roleId: number
    ) {
        this.username = username;
        this.email = email;
        this.token = token;
        this.roleId = roleId;
    }
}
