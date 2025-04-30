// loggingMiddleware.js
// This middleware logs every incoming request along with method, URL, response status, and duration.
function loggingMiddleware(req, res, next) {
  const startTime = process.hrtime();

  res.on('finish', () => {
    const diff = process.hrtime(startTime);
    const durationInMs = diff[0] * 1e3 + diff[1] / 1e6;
    console.log(`${req.method} ${req.originalUrl} ${res.statusCode} - ${durationInMs.toFixed(2)} ms`);
  });

  next();
}

module.exports = loggingMiddleware;
