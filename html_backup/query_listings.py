import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

try:
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {
        'projectId': 'scalesync-pro',
    })
    db = firestore.client()
    docs = db.collection('marketplace_listings').stream()
    print("Found listings:")
    for doc in docs:
        print(doc.id, doc.to_dict())
except Exception as e:
    print("Error:", e)
