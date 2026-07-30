const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

exports.sendCustomResetEmail = functions.https.onCall(async (data, context) => {
  const email = data.email;

  if (!email) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with an 'email' argument."
    );
  }

  try {
    // 1. Generate the secure reset password link
    const actionCodeSettings = {
      // URL you want to redirect back to.
      // Firebase default handler works if this is the default url
      url: `https://${process.env.GCP_PROJECT}.firebaseapp.com/__/auth/action?mode=resetPassword`,
      handleCodeInApp: false,
    };
    
    // We don't actually need actionCodeSettings if we just want the default oobLink
    // generatePasswordResetLink returns a link that points to the default Firebase handler
    // e.g. https://zentai-9b38a.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=...
    const link = await admin.auth().generatePasswordResetLink(email);

    // 2. Prepare the email HTML
    const emailHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
</head>
<body style="background-color: #0F172A; color: #ffffff; font-family: 'Inter', Helvetica, Arial, sans-serif; padding: 40px 20px; text-align: center;">
  <div style="max-width: 500px; margin: 0 auto; background-color: #1E293B; padding: 40px; border-radius: 16px; border: 1px solid #334155; box-shadow: 0 10px 25px rgba(0,0,0,0.5);">
    <h1 style="color: #F59E0B; margin-bottom: 10px; font-size: 28px; letter-spacing: -0.5px;">Zentai</h1>
    <h2 style="font-size: 20px; font-weight: 600; margin-bottom: 24px;">Restablecer Contraseña</h2>
    <p style="color: #94A3B8; font-size: 15px; line-height: 1.6; margin-bottom: 32px; text-align: left;">
      Hola,<br><br>
      Hemos recibido una solicitud para restablecer la contraseña de tu cuenta en Zentai. 
      Si no fuiste tú, puedes ignorar este correo de forma segura.
    </p>
    <a href="${link}" style="display: inline-block; background: linear-gradient(135deg, #F97316 0%, #F59E0B 100%); color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 12px; font-weight: bold; font-size: 16px; margin-bottom: 32px; box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);">
      Cambiar mi Contraseña
    </a>
    <p style="color: #64748B; font-size: 13px; margin-top: 20px; border-top: 1px solid #334155; padding-top: 20px;">
      El equipo de Zentai
    </p>
  </div>
</body>
</html>
`;

    // 3. Send email using Resend
    const resendApiKey = process.env.RESEND_API_KEY || "TU_API_KEY_DE_RESEND";
    const resendResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "onboarding@resend.dev",
        to: [email],
        subject: "Restablece tu contraseña - Zentai",
        html: emailHtml,
      }),
    });

    if (!resendResponse.ok) {
      const errorText = await resendResponse.text();
      console.error("Resend API error:", errorText);
      throw new functions.https.HttpsError("internal", "Failed to send email");
    }

    return { success: true };
  } catch (error) {
    console.error("Error generating or sending reset link:", error);
    
    // Check if error is user-not-found
    if (error.code === 'auth/user-not-found') {
      throw new functions.https.HttpsError('not-found', 'user-not-found');
    }
    
    throw new functions.https.HttpsError("internal", error.message);
  }
});
