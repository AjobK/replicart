class InvalidIDError extends Error {
    constructor(message) {
        super(message);
        this.name = 'InvalidIDError';
    }
}

module.exports = InvalidIDError;