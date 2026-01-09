import * as admin from 'firebase-admin';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Initialize Firebase Admin
const projectId = process.env.FIREBASE_PROJECT_ID;
const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;

if (!projectId || !privateKey || !clientEmail) {
  console.error('Firebase Admin configuration missing. Please check your .env file.');
  process.exit(1);
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: projectId,
      privateKey: privateKey,
      clientEmail: clientEmail,
    }),
  });
}

async function createDemoUser() {
  const email = 'demo@gmail.com';
  const password = 'Demo@123';

  try {
    // Check if user already exists
    let user;
    try {
      user = await admin.auth().getUserByEmail(email);
      console.log(`User ${email} already exists with UID: ${user.uid}`);
      console.log('If you want to reset the password, use Firebase Console or delete and recreate the user.');
      return;
    } catch (error: any) {
      if (error.code === 'auth/user-not-found') {
        // User doesn't exist, create it
        user = await admin.auth().createUser({
          email: email,
          password: password,
          emailVerified: true,
        });
        console.log(`✅ Successfully created demo user:`);
        console.log(`   Email: ${email}`);
        console.log(`   Password: ${password}`);
        console.log(`   UID: ${user.uid}`);
      } else {
        throw error;
      }
    }
  } catch (error: any) {
    console.error('❌ Error creating demo user:', error.message);
    if (error.code === 'auth/email-already-exists') {
      console.log('User already exists. You can reset the password in Firebase Console.');
    }
    process.exit(1);
  }
}

createDemoUser()
  .then(() => {
    console.log('\n✅ Demo user setup complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Unexpected error:', error);
    process.exit(1);
  });
