const crypto = require('crypto');

console.log('\n========================================');
console.log('JWT Secret Generator');
console.log('========================================\n');

console.log('Copy these to your .env file:\n');
console.log('JWT_ACCESS_SECRET=' + crypto.randomBytes(32).toString('hex'));
console.log('JWT_REFRESH_SECRET=' + crypto.randomBytes(32).toString('hex'));
console.log('\n========================================\n');
