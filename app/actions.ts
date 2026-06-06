"use server";

import * as admin from "firebase-admin";
import { cookies } from "next/headers";

// Helper to initialize Firebase Admin SDK safely
function getAdminAuth() {
  if (admin.apps.length === 0) {
    // Check if we are running in an environment with service account credentials,
    // otherwise fallback to default initialization
    const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT;
    
    if (serviceAccount) {
      try {
        admin.initializeApp({
          credential: admin.credential.cert(JSON.parse(serviceAccount)),
        });
      } catch (e) {
        console.error("Failed to parse FIREBASE_SERVICE_ACCOUNT env var:", e);
        admin.initializeApp();
      }
    } else {
      admin.initializeApp();
    }
  }
  return {
    auth: admin.auth(),
    db: admin.firestore(),
  };
}

// ----------------------------------------------------
// Section 4-A: Verification Middleware Action
// ----------------------------------------------------
export async function verifyAdminClaim(sessionToken: string): Promise<boolean> {
  if (!sessionToken) return false;

  // Local development bypass to streamline test suites
  if (process.env.NODE_ENV === "development" && sessionToken === "dev-admin-bypass") {
    console.log("Local development admin bypass token successfully authorized.");
    return true;
  }

  const { auth } = getAdminAuth();
  
  try {
    const decodedToken = await auth.verifyIdToken(sessionToken);
    return decodedToken.admin === true;
  } catch (error) {
    try {
      const decodedCookie = await auth.verifySessionCookie(sessionToken);
      return decodedCookie.admin === true;
    } catch (cookieError) {
      console.error("Error verifying token or cookie admin claim:", error, cookieError);
      return false;
    }
  }
}

// Helper to check current user admin status from request cookies
export async function checkCurrentAdminStatus(): Promise<boolean> {
  const cookieStore = cookies();
  const sessionToken = cookieStore.get("__session")?.value || "";
  return await verifyAdminClaim(sessionToken);
}

// Helper to audit admin actions
export async function logAdminAudit(actionName: string, details: string): Promise<boolean> {
  try {
    const { db } = getAdminAuth();
    await db.collection("audit_logs").add({
      action: actionName,
      details: details,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    return true;
  } catch (e) {
    console.error("Failed to write audit log:", e);
    return false;
  }
}

// ----------------------------------------------------
// Section 5-B: Standardized Try/Catch Action Responses
// ----------------------------------------------------

// Set Admin custom claims on a user (Requires caller to be admin or in dev mode)
export async function setAdminClaimAction(targetUid: string, isAdmin: boolean) {
  try {
    const isCallerAdmin = await checkCurrentAdminStatus();
    if (!isCallerAdmin && process.env.NODE_ENV !== "development") {
      throw new Error("Unauthorized: Only admins can assign roles.");
    }

    const { auth } = getAdminAuth();
    await auth.setCustomUserClaims(targetUid, { admin: isAdmin });
    
    await logAdminAudit("SET_ADMIN_CLAIM", `Uid: ${targetUid}, isAdmin: ${isAdmin}`);
    
    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

// ----------------------------------------------------
// Standalone Reptile breeding tracker Actions
// ----------------------------------------------------
export async function createBreedingProjectAction(userId: string, projectData: {
  projectName: string;
  male: string;
  female: string;
  startDate: string;
  notes?: string;
}) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    const newProject = {
      ...projectData,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db
      .collection("users")
      .doc(userId)
      .collection("breeding_logs")
      .add(newProject);

    return { success: true, id: docRef.id };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function getBreedingProjectsAction(userId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    const snapshot = await db
      .collection("users")
      .doc(userId)
      .collection("breeding_logs")
      .orderBy("createdAt", "desc")
      .get();

    const projects = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    return { success: true, data: projects };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function deleteBreedingProjectAction(userId: string, projectId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    await db
      .collection("users")
      .doc(userId)
      .collection("breeding_logs")
      .doc(projectId)
      .delete();

    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

// ----------------------------------------------------
// Social Media Feed Actions (Internal domain)
// ----------------------------------------------------
export async function createPostAction(userId: string, authorName: string, content: string, photoUrl?: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    const newPost = {
      uid: userId,
      authorName,
      content,
      photoUrl: photoUrl || null,
      likesCount: 0,
      recentLikers: [],
      likesMap: {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection("posts").add(newPost);
    return { success: true, id: docRef.id };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function getPostsAction() {
  try {
    const { db } = getAdminAuth();
    const snapshot = await db.collection("posts").orderBy("createdAt", "desc").get();
    const posts = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt ? (data.createdAt as admin.firestore.Timestamp).toDate().toISOString() : null,
      };
    });
    return { success: true, data: posts };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function likePostAction(postId: string, userId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();
    const postRef = db.collection("posts").doc(postId);

    await db.runTransaction(async (transaction) => {
      const postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw new Error("Post not found");
      }

      const postData = postDoc.data() || {};
      const likesMap = postData.likesMap || {};
      const isLiked = !!likesMap[userId];
      
      const newLikesMap = { ...likesMap };
      let likesDelta = 0;
      
      if (isLiked) {
        delete newLikesMap[userId];
        likesDelta = -1;
      } else {
        newLikesMap[userId] = true;
        likesDelta = 1;
      }

      const newLikesCount = Math.max(0, (postData.likesCount || 0) + likesDelta);
      const recentLikers = Object.keys(newLikesMap).slice(0, 5);

      // Perform updates matching Firestore Security Rules delta validation (hasOnly(['likesCount', 'recentLikers', 'likesMap']))
      transaction.update(postRef, {
        likesCount: newLikesCount,
        recentLikers: recentLikers,
        likesMap: newLikesMap,
      });
    });

    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function deletePostAction(userId: string, postId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();
    const postRef = db.collection("posts").doc(postId);
    const postDoc = await postRef.get();
    
    if (!postDoc.exists) {
      throw new Error("Post not found");
    }

    const postData = postDoc.data() || {};
    const isAdmin = await checkCurrentAdminStatus();
    
    // Authorization check matching security rules
    if (postData.uid !== userId && !isAdmin) {
      throw new Error("Unauthorized: Only the creator or administrator can delete this post.");
    }

    await postRef.delete();
    
    if (isAdmin && postData.uid !== userId) {
      await logAdminAudit("ADMIN_DELETE_POST", `Deleted post: ${postId} authored by ${postData.uid}`);
    }

    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

// ----------------------------------------------------
// Internal Marketplace Actions (Internal domain)
// ----------------------------------------------------
export async function createListingAction(userId: string, listingData: {
  title: string;
  description: string;
  price: number;
  species: string;
  morph?: string;
  gender: string;
  photoUrls: string[];
}) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    const newListing = {
      ...listingData,
      uid: userId,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection("listings").add(newListing);
    return { success: true, id: docRef.id };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function getListingsAction() {
  try {
    const { db } = getAdminAuth();
    const snapshot = await db.collection("listings").orderBy("createdAt", "desc").get();
    const listings = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt ? (data.createdAt as admin.firestore.Timestamp).toDate().toISOString() : null,
      };
    });
    return { success: true, data: listings };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function updateListingStatusAction(userId: string, listingId: string, status: "active" | "sold") {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();
    const listingRef = db.collection("listings").doc(listingId);
    const doc = await listingRef.get();

    if (!doc.exists) throw new Error("Listing not found");
    const data = doc.data() || {};

    const isAdmin = await checkCurrentAdminStatus();
    if (data.uid !== userId && !isAdmin) {
      throw new Error("Unauthorized");
    }

    await listingRef.update({ status });
    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function deleteListingAction(userId: string, listingId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();
    const listingRef = db.collection("listings").doc(listingId);
    const doc = await listingRef.get();

    if (!doc.exists) throw new Error("Listing not found");
    const data = doc.data() || {};

    const isAdmin = await checkCurrentAdminStatus();
    if (data.uid !== userId && !isAdmin) {
      throw new Error("Unauthorized");
    }

    await listingRef.delete();
    
    if (isAdmin && data.uid !== userId) {
      await logAdminAudit("ADMIN_DELETE_LISTING", `Deleted listing: ${listingId} owned by ${data.uid}`);
    }

    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

// ----------------------------------------------------
// Reptiles Management Actions
// ----------------------------------------------------
export async function createReptileAction(userId: string, reptileData: any) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    const newReptile = {
      ...reptileData,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db
      .collection("users")
      .doc(userId)
      .collection("reptiles")
      .add(newReptile);

    return { success: true, id: docRef.id };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function getReptilesAction(userId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    const snapshot = await db
      .collection("users")
      .doc(userId)
      .collection("reptiles")
      .orderBy("createdAt", "desc")
      .get();

    const reptiles = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
      };
    });

    return { success: true, data: reptiles };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}

export async function deleteReptileAction(userId: string, reptileId: string) {
  try {
    if (!userId) throw new Error("Unauthenticated");
    const { db } = getAdminAuth();

    await db
      .collection("users")
      .doc(userId)
      .collection("reptiles")
      .doc(reptileId)
      .delete();

    return { success: true };
  } catch (error: any) {
    console.error("Action error:", error);
    return { success: false, error: error.message };
  }
}
