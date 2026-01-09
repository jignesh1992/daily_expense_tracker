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

async function resetDemoUserPassword() {
  const email = 'demo@gmail.com';
  const password = 'Demo@123';

  try {
    // Get user by email
    const user = await admin.auth().getUserByEmail(email);
    
    // Update password
    await admin.auth().updateUser(user.uid, {
      password: password,
      emailVerified: true,
    });
    
    console.log(`✅ Successfully reset password for demo user:`);
    console.log(`   Email: ${email}`);
    console.log(`   Password: ${password}`);
    console.log(`   UID: ${user.uid}`);
  } catch (error: any) {
    console.error('❌ Error resetting password:', error.message);
    if (error.code === 'auth/user-not-found') {
      console.log('User not found. Creating new user...');
      try {
        const newUser = await admin.auth().createUser({
          email: email,
          password: password,
          emailVerified: true,
        });
        console.log(`✅ Successfully created demo user:`);
        console.log(`   Email: ${email}`);
        console.log(`   Password: ${password}`);
        console.log(`   UID: ${newUser.uid}`);
      } catch (createError: any) {
        console.error('❌ Error creating user:', createError.message);
        process.exit(1);
      }
    } else {
      process.exit(1);
    }
  }
}

resetDemoUserPassword()
  .then(() => {
    console.log('\n✅ Password reset complete!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Unexpected error:', error);
    process.exit(1);
  });
