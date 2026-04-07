'use strict';

class ErrorHandler {
    static handle(err, req, res, next) {
        console.error(err.stack);

        const status = err.status || 500;
        const message = err.message || 'Internal Server Error';

        res.status(status).json({
            status,
            message,
            // For debugging, you might want to include additional details in development
            ...(process.env.NODE_ENV === 'development' ? { stack: err.stack } : {}),
        });
    }
}

module.exports = ErrorHandler.handle;