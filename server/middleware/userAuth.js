const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
    try {
        const token = req.header("Authorization").replace("Bearer ", "");
        if (!token) {
            return res.status(401).json({ msg: "No authentication token, access denied." });
        }

        const verified = jwt.verify(token, "passwordKey");
        if (!verified) {
            return res.status(401).json({ msg: "Token verification failed, authorization denied." });
        }

        req.user = verified;
        next();
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = authMiddleware;
