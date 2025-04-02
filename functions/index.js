/* eslint-disable max-len */
/* eslint-disable linebreak-style */
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
const {onSchedule} = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");
const https = require("https");

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

// HTTP endpoint để xử lý xác nhận
exports.confirmEmail = functions.https.onRequest(async (req, res) => {
  try {
    const email = req.query.email;
    const token = req.query.token;

    if (!email || !token) {
      // eslint-disable-next-line max-len
      return res.status(400).send("Email và token xác nhận không được để trống");
    }

    const db = admin.firestore();
    const subscriptionRef = db.collection("subscriptions").doc(email);
    const subscription = await subscriptionRef.get();

    if (!subscription.exists) {
      return res.status(404).send("Không tìm thấy thông tin đăng ký");
    }

    const subscriptionData = subscription.data();
    if (subscriptionData.confirmationToken !== token) {
      return res.status(400).send("Token xác nhận không hợp lệ");
    }

    await subscriptionRef.update({
      isConfirmed: true,
      confirmedAt: admin.firestore.FieldValue.serverTimestamp(),
      confirmationToken: null,
    });

    // Chuyển hướng về trang chủ với thông báo thành công
    res.redirect(`${process.env.APP_URL}?confirmed=true`);
  } catch (error) {
    console.error("Error confirming subscription:", error);
    res.status(500).send("Có lỗi xảy ra khi xác nhận đăng ký");
  }
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

    // Kiểm tra xem email đã đăng ký và xác nhận chưa
    const db = admin.firestore();
    const subscriptionRef = db.collection("subscriptions").doc(email);
    const subscription = await subscriptionRef.get();

    if (subscription.exists) {
      const subscriptionData = subscription.data();
      if (subscriptionData.isConfirmed) {
        throw new functions.https.HttpsError(
            "already-exists",
            "Email này đã được đăng ký và xác nhận trước đó",
        );
      }
    }

    // Tạo token xác nhận
    const crypto = require("crypto");
    const confirmationToken = crypto.randomBytes(32).toString("hex");

    // Lưu thông tin đăng ký vào Firestore
    await subscriptionRef.set({
      email,
      city,
      confirmationToken,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isConfirmed: false,
    });

    // Gửi email xác nhận với URL mới
    const region = process.env.FUNCTION_REGION || "us-central1";
    const projectId = process.env.GCLOUD_PROJECT;
    const confirmationUrl = `https://${region}-${projectId}.cloudfunctions.net/confirmEmail?email=${email}&token=${confirmationToken}`;

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
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError("internal", error.message);
  }
});

exports.unsubscribeFromWeather = functions.https.onCall(async (request) => {
  try {
    const {email} = request.data;

    if (!email) {
      throw new functions.https.HttpsError(
          "invalid-argument",
          "Email không được để trống",
      );
    }

    const db = admin.firestore();
    const subscriptionRef = db.collection("subscriptions").doc(email);
    const subscription = await subscriptionRef.get();

    if (!subscription.exists || !subscription.data().isConfirmed) {
      throw new functions.https.HttpsError(
          "not-found",
          "Không tìm thấy thông tin đăng ký hoặc đăng ký chưa được xác nhận",
      );
    }

    await subscriptionRef.delete();

    return {
      success: true,
      message: "Hủy đăng ký thành công!",
    };
  } catch (error) {
    console.error("Error unsubscribing:", error);
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// Hàm gửi dự báo thời tiết hằng ngày cho người dùng đã xác nhận
exports.sendDailyForecast = onSchedule({
  schedule: "0 7 * * *", 
  timeZone: "Asia/Ho_Chi_Minh", 
  retryCount: 3, 
  memory: "256MiB", 
}, async (context) => {
  try {
    console.log("Starting daily forecast email job");
    
    // Lấy danh sách các subscription đã được xác nhận
    const db = admin.firestore();
    const confirmedSubscriptionsSnapshot = await db.collection("subscriptions")
        .where("isConfirmed", "==", true)
        .get();
    
    if (confirmedSubscriptionsSnapshot.empty) {
      console.log("No confirmed subscribers found.");
      return null;
    }
    
    console.log(`Found ${confirmedSubscriptionsSnapshot.size} confirmed subscribers.`);
    
    // Lấy API key từ biến môi trường
    const weatherApiKey = process.env.WEATHER_API_KEY;
    if (!weatherApiKey) {
      throw new Error("Weather API key is not configured.");
    }
    
    // Hàm helper để lấy dữ liệu từ API thời tiết
    function getWeatherData(city) {
      return new Promise((resolve, reject) => {
        const apiUrl = `https://api.weatherapi.com/v1/forecast.json?key=${weatherApiKey}&q=${encodeURIComponent(city)}&days=1&aqi=no&alerts=no`;
        
        https.get(apiUrl, (res) => {
          let data = "";
          
          res.on("data", (chunk) => {
            data += chunk;
          });
          
          res.on("end", () => {
            if (res.statusCode !== 200) {
              reject(new Error(`Weather API error: ${res.statusMessage}`));
              return;
            }
            
            try {
              const weatherData = JSON.parse(data);
              resolve(weatherData);
            } catch (e) {
              reject(new Error(`Failed to parse weather data: ${e.message}`));
            }
          });
        }).on("error", (err) => {
          reject(new Error(`Weather API request failed: ${err.message}`));
        });
      });
    }
    
    // Xử lý từng người đăng ký
    const promises = confirmedSubscriptionsSnapshot.docs.map(async (doc) => {
      const subscription = doc.data();
      const {email, city} = subscription;
      
      try {
        // Gọi API lấy dự báo thời tiết
        const weatherData = await getWeatherData(city);
        
        // Lấy thông tin dự báo
        const forecast = weatherData.forecast.forecastday[0];
        const current = weatherData.current;
        const location = weatherData.location;
        
        // Tạo nội dung email
        const emailHtml = `
          <html>
            <head>
              <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }
                h1 { color: #2c3e50; }
                .forecast-card { border: 1px solid #ddd; border-radius: 8px; padding: 15px; margin-top: 20px; }
                .forecast-header { background-color: #f8f9fa; padding: 10px; border-radius: 5px; }
                .temp { font-size: 24px; font-weight: bold; color: #e74c3c; }
                .condition { display: flex; align-items: center; margin: 10px 0; }
                .condition img { margin-right: 10px; }
                .detail { margin: 5px 0; color: #34495e; }
                .footer { margin-top: 30px; font-size: 12px; color: #7f8c8d; }
              </style>
            </head>
            <body>
              <h1>Dự báo thời tiết hằng ngày</h1>
              <p>Xin chào! Dưới đây là dự báo thời tiết hôm nay cho ${location.name}, ${location.country}:</p>
              
              <div class="forecast-card">
                <div class="forecast-header">
                  <h2>${new Date(forecast.date).toLocaleDateString("vi-VN", {"weekday": "long", "year": "numeric", "month": "long", "day": "numeric"})}</h2>
                </div>
                
                <div class="condition">
                  <img src="https:${current.condition.icon}" alt="${current.condition.text}" width="64" height="64">
                  <p><span class="temp">${current.temp_c}°C</span> - ${current.condition.text}</p>
                </div>
                
                <p class="detail"><strong>Nhiệt độ:</strong> Thấp nhất ${forecast.day.mintemp_c}°C / Cao nhất ${forecast.day.maxtemp_c}°C</p>
                <p class="detail"><strong>Cảm giác như:</strong> ${current.feelslike_c}°C</p>
                <p class="detail"><strong>Độ ẩm:</strong> ${current.humidity}%</p>
                <p class="detail"><strong>Gió:</strong> ${current.wind_kph} km/h</p>
                <p class="detail"><strong>Khả năng mưa:</strong> ${forecast.day.daily_chance_of_rain}%</p>
                <p class="detail"><strong>Lượng mưa:</strong> ${forecast.day.totalprecip_mm} mm</p>
                <p class="detail"><strong>Chỉ số UV:</strong> ${forecast.day.uv}</p>
                <p class="detail"><strong>Bình minh:</strong> ${forecast.astro.sunrise}</p>
                <p class="detail"><strong>Hoàng hôn:</strong> ${forecast.astro.sunset}</p>
              </div>
              
              <p><strong>Lời khuyên:</strong> ${forecast.day.daily_chance_of_rain > 50 ? "Hôm nay có khả năng cao sẽ mưa, hãy mang theo ô hoặc áo mưa." : "Tận hưởng ngày mới của bạn!"}</p>
              
              <div class="footer">
                <p>Email này được gửi tự động từ ứng dụng Weather App.</p>
                <p>Để hủy đăng ký, <a href="${process.env.APP_URL}/unsubscribe?email=${email}">nhấn vào đây</a>.</p>
              </div>
            </body>
          </html>
        `;
        
        // Gửi email
        await transporter.sendMail({
          from: process.env.EMAIL_USER,
          to: email,
          subject: `Dự báo thời tiết hôm nay cho ${location.name}`,
          html: emailHtml,
        });
        
        console.log(`Sent daily forecast to ${email} for ${city}`);
        return {email, success: true};
      } catch (error) {
        console.error(`Error sending forecast to ${email} for ${city}:`, error);
        return {email, success: false, error: error.message};
      }
    });
    
    // Đợi tất cả các email được gửi
    const results = await Promise.all(promises);
    
    // Thống kê
    const successCount = results.filter((r) => r.success).length;
    const failureCount = results.length - successCount;
    
    console.log(`Daily forecast job completed: ${successCount} succeeded, ${failureCount} failed`);
    return null;
  } catch (error) {
    console.error("Error in sendDailyForecast function:", error);
    return null;
  }
});
