/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

require("firebase-functions/v2/https");
require("dotenv").config({path: ".env.local"});
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

admin.initializeApp();

// Cấu hình email transporter
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

exports.subscribeToWeather = functions.https.onCall(async (request) => {
  try {
    const {email, city} = request.data;

    if (!email || !city) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Email và thành phố không được để trống",
      );
    }

    // Validate email format
    const emailRegex = /^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$/;
    if (!emailRegex.test(email)) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Email không hợp lệ",
      );
    }

    // Tạo token xác nhận
    const crypto = require("crypto");
    const confirmationToken = crypto.randomBytes(32).toString("hex");

    // Lưu thông tin đăng ký vào Firestore
    const db = admin.firestore();
    await db.collection("subscriptions").doc(email).set({
      email,
      city,
      confirmationToken,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isConfirmed: false,
    });

    // Gửi email xác nhận
    // eslint-disable-next-line max-len
    const confirmationUrl = `${process.env.APP_URL}/confirm?email=${email}&token=${confirmationToken}`;

    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: "Xác nhận đăng ký nhận thông tin thời tiết",
      html: `
        <h1>Xác nhận đăng ký</h1>
        <p>Bạn đã đăng ký nhận thông tin thời tiết cho thành phố ${city}.</p>
        <p>Vui lòng click vào link sau để xác nhận đăng ký:</p>
        <a href="${confirmationUrl}">${confirmationUrl}</a>
      `,
    });

    return {
      success: true,
      message: "Vui lòng kiểm tra email để xác nhận đăng ký.",
    };
  } catch (error) {
    console.error("Error subscribing:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

exports.confirmSubscription = functions.https.onCall(async (request) => {
  try {
    const {email, token} = request.data;

    if (!email || !token) {
      throw new Error("Email và token xác nhận không được để trống");
    }

    const db = admin.firestore();
    const subscriptionRef = db.collection("subscriptions").doc(email);
    const subscription = await subscriptionRef.get();

    if (!subscription.exists) {
      throw new Error("Không tìm thấy thông tin đăng ký");
    }

    const subscriptionData = subscription.data();
    if (subscriptionData.confirmationToken !== token) {
      throw new Error("Token xác nhận không hợp lệ");
    }

    await subscriptionRef.update({
      isConfirmed: true,
      confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
      confirmationToken: null,
    });

    return {
      success: true,
      message: "Xác nhận đăng ký thành công!",
    };
  } catch (error) {
    console.error("Error confirming subscription:", error);
    throw new Error(error.message);
  }
});

exports.unsubscribeFromWeather = functions.https.onCall(async (request) => {
  try {
    const {email} = request.data;

    if (!email) {
      throw new Error("Email không được để trống");
    }

    const db = admin.firestore();
    await db.collection("subscriptions").doc(email).delete();

    return {
      success: true,
      message: "Hủy đăng ký thành công!",
    };
  } catch (error) {
    console.error("Error unsubscribing:", error);
    throw new Error(error.message);
  }
});
