const admin = require('firebase-admin');

// Initialize App with application default credentials or local configuration
try {
  admin.initializeApp({
    projectId: 'scalesync-pro'
  });
  const db = admin.firestore();
  db.collection('marketplace_listings').get().then(snapshot => {
    console.log(`Found ${snapshot.size} listings.`);
    snapshot.forEach(doc => {
      console.log(doc.id, JSON.stringify(doc.data(), null, 2));
    });
  }).catch(err => {
    console.error('Error getting documents', err);
  });
} catch (e) {
  console.error(e);
}
