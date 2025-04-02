import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';
import * as crypto from 'crypto';

admin.initializeApp();

const db = admin.firestore();

// Cấu hình email
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

// Tạo token xác nhận
function generateConfirmationToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

// Hàm đăng ký nhận thông tin thời tiết
export const subscribeToWeather = functions.https.onCall(async (data, context) => {
  const { email, city } = data;
  
  if (!email || !city) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and city are required');
  }

  const confirmationToken = generateConfirmationToken();
  
  // Lưu thông tin đăng ký vào Firestore
  await db.collection('subscriptions').doc(email).set({
    email,
    city,
    isConfirmed: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    confirmationToken,
  });

  // Gửi email xác nhận
  const confirmationUrl = `${functions.config().app.url}/confirm?email=${email}&token=${confirmationToken}`;
  
  await transporter.sendMail({
    from: functions.config().email.user,
    to: email,
    subject: 'Xác nhận đăng ký nhận thông tin thời tiết',
    html: `
      <h1>Xác nhận đăng ký</h1>
      <p>Bạn đã đăng ký nhận thông tin thời tiết cho thành phố ${city}.</p>
      <p>Vui lòng click vào link sau để xác nhận đăng ký:</p>
      <a href="${confirmationUrl}">${confirmationUrl}</a>
    `,
  });

  return { success: true };
});

// Hàm xác nhận đăng ký
export const confirmSubscription = functions.https.onCall(async (data, context) => {
  const { email, token } = data;

  if (!email || !token) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and token are required');
  }

  const subscriptionRef = db.collection('subscriptions').doc(email);
  const subscription = await subscriptionRef.get();

  if (!subscription.exists) {
    throw new functions.https.HttpsError('not-found', 'Subscription not found');
  }

  const subscriptionData = subscription.data();
  if (subscriptionData?.confirmationToken !== token) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid confirmation token');
  }

  await subscriptionRef.update({
    isConfirmed: true,
    confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
    confirmationToken: null,
  });

  return { success: true };
});

// Hàm hủy đăng ký
export const unsubscribeFromWeather = functions.https.onCall(async (data, context) => {
  const { email } = data;

  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'Email is required');
  }

  await db.collection('subscriptions').doc(email).delete();

  return { success: true };
}); 