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

exports.addTransactionViaSiri = functions.https.onRequest(async (req, res) => {
  // CORS configuration if needed
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'GET, POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.set('Access-Control-Max-Age', '3600');
    return res.status(204).send('');
  }

  const uid = req.query.uid || req.body.uid;
  const amountStr = req.query.amount || req.body.amount;
  let amount = parseFloat(amountStr);
  const concept = req.query.concept || req.body.concept || "Siri / Voz";
  let type = req.query.type || req.body.type || "expense";
  const env = (req.query.env || req.body.env || process.env.QUIVO_ENV || "dev").toLowerCase();
  const isProd = env === "prod" || env === "production";
  const usersCol = isProd ? "prod_users" : "users";
  const txCol = isProd ? "prod_transactions" : "transactions";

  // Intentar deducir si es ingreso o gasto basado en el concepto o type
  const lowerConcept = concept.toLowerCase();
  if (lowerConcept.includes("ingreso") || lowerConcept.includes("ganancia") || lowerConcept.includes("pago a mi favor")) {
      type = "income";
  }

  if (!uid || isNaN(amount) || amount <= 0) {
    return res.status(400).send("Faltan datos o el monto es inválido. (Requiere uid y amount)");
  }

  try {
    // 1. Verificamos que el usuario sea Premium (revisa primero la colección del entorno, con fallback a prod_users/users)
    let userDoc = await admin.firestore().collection(usersCol).doc(uid).get();
    let targetTxCol = txCol;
    if (!userDoc.exists) {
      const altUsersCol = isProd ? "users" : "prod_users";
      const altDoc = await admin.firestore().collection(altUsersCol).doc(uid).get();
      if (altDoc.exists) {
        userDoc = altDoc;
        targetTxCol = isProd ? "transactions" : "prod_transactions";
      } else {
        return res.status(403).send("Usuario no encontrado.");
      }
    }
    const userData = userDoc.data();
    const unlockedItems = Array.isArray(userData.unlockedItems) ? userData.unlockedItems : [];
    const hasPremiumItem = unlockedItems.includes('premium') || unlockedItems.includes('spec1') || unlockedItems.includes('vip');
    if (userData.plan !== 'premium' && userData.plan !== 'PRO' && userData.isPremium !== true && !hasPremiumItem) {
      return res.status(403).send("Esta función es exclusiva para usuarios del plan Premium.");
    }

    // 2. Agregar a Firestore
    const newTx = {
      id: Date.now().toString(),
      userId: uid,
      amount: amount,
      description: concept,
      category: "general",
      type: type,
      date: new Date().toISOString(),
      isFixed: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await admin.firestore().collection(targetTxCol).doc(newTx.id).set(newTx);
    return res.status(200).send(`Transacción de ${amount} agregada a QUIVO exitosamente.`);
  } catch (error) {
    console.error("Siri Error:", error);
    return res.status(500).send("Ocurrió un error en el servidor.");
  }
});

exports.processFixedTransactions = functions.pubsub.schedule('1 0 * * *').timeZone('America/Guatemala').onRun(async (context) => {
  const db = admin.firestore();
  const environments = [
    { txCol: 'transactions', notifCol: 'notifications' },
    { txCol: 'prod_transactions', notifCol: 'prod_notifications' },
  ];
  
  try {
    // Obtener fecha actual en zona horaria de Guatemala
    const formatter = new Intl.DateTimeFormat('en-US', { timeZone: 'America/Guatemala', day: 'numeric' });
    const currentDay = parseInt(formatter.format(new Date()));
    const nowGuat = new Date(new Date().toLocaleString("en-US", { timeZone: "America/Guatemala" }));
    const year = nowGuat.getFullYear();
    const month = String(nowGuat.getMonth() + 1).padStart(2, '0');
    const day = String(nowGuat.getDate()).padStart(2, '0');
    const dateKey = `${year}_${month}_${day}`;

    let totalCount = 0;

    for (const { txCol, notifCol } of environments) {
      const snapshot = await db.collection(txCol).where('isFixed', '==', true).get();
      if (snapshot.empty) continue;

      const batch = db.batch();
      let count = 0;

      for (const doc of snapshot.docs) {
        const data = doc.data();
        if (!data.date) continue;

        const dayStr = data.date.substring(8, 10);
        const originalDay = parseInt(dayStr);

        if (currentDay === originalDay) {
          // ID determinista para evitar cualquier duplicación con la app o ejecuciones previas
          const newTxId = `auto_tx_${data.userId}_${doc.id}_${dateKey}`;
          const newTxRef = db.collection(txCol).doc(newTxId);
          
          // Verificar si ya fue generado hoy
          const existingTx = await newTxRef.get();
          if (existingTx.exists) {
            continue;
          }

          const cleanDesc = (data.description || data.category || 'Movimiento').trim();
          const newTx = {
            ...data,
            id: newTxId,
            isFixed: false,
            date: new Date().toISOString(),
            description: `${cleanDesc} (Automático)`,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
          };
          
          batch.set(newTxRef, newTx, { merge: true });

          // Notificación con ID determinista antiduplicados
          const notifId = `auto_notif_${data.userId}_${doc.id}_${dateKey}`;
          const notifRef = db.collection(notifCol).doc(notifId);
          const notif = {
            id: notifId,
            userId: data.userId,
            title: data.type === 'expense' ? 'Gasto Fijo Procesado' : 'Ingreso Fijo Procesado',
            body: `Se ha registrado automáticamente: ${cleanDesc} por Q${data.amount}`,
            date: new Date().toISOString(),
            isRead: false,
            type: 'system',
            data: JSON.stringify({ transactionId: newTxId })
          };
          
          batch.set(notifRef, notif, { merge: true });
          count++;
        }
      }

      if (count > 0) {
        await batch.commit();
        totalCount += count;
      }
    }
      }
    }
    console.log(`Job 12:01 AM ejecutado exitosamente. Se procesaron ${totalCount} movimientos fijos.`);
    return null;

  } catch (error) {
    console.error("Error procesando transacciones fijas:", error);
    return null;
  }
});

exports.backfillAugustFixedTransactions = functions.https.onRequest(async (req, res) => {
  const db = admin.firestore();
  
  try {
    const snapshot = await db.collection('transactions').where('isFixed', '==', true).get();
    const batch = db.batch();
    let count = 0;

    for (const doc of snapshot.docs) {
      const data = doc.data();
      if (!data.date) continue;

      // Extract original day
      const dayStr = data.date.substring(8, 10);
      const originalDay = parseInt(dayStr);
      
      if (originalDay >= 11 && originalDay <= 17) {
        const targetDateStr = `2026-08-${originalDay.toString().padStart(2, '0')}T12:00:00.000Z`;
        
        const newTxId = `backfill_aug_${doc.id}`;
        const newTxRef = db.collection('transactions').doc(newTxId);
        
        const newTx = {
          ...data,
          id: newTxId,
          isFixed: false,
          date: targetDateStr,
          description: `${data.description} (Backfill Agosto)`,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        };
        
        batch.set(newTxRef, newTx);

      const notifRef = db.collection('notifications').doc();
      const notif = {
        id: notifRef.id,
        userId: data.userId,
        title: data.type === 'expense' ? 'Gasto Fijo Recuperado' : 'Ingreso Fijo Recuperado',
        body: `Se ha registrado automáticamente tu movimiento fijo de agosto: ${data.description} por $${data.amount}`,
        date: targetDateStr,
        isRead: false,
        type: 'system',
        data: JSON.stringify({ transactionId: newTxId })
      };
      
      batch.set(notifRef, notif);
      count++;

      // If batch is full, commit and get a new one (safe guard)
      if (count % 200 === 0) {
        await batch.commit();
      }
      } // Close if (originalDay >= 11 && originalDay <= 17)
    } // Close for loop

    if (count % 200 !== 0 && count > 0) {
      await batch.commit();
    }

    return res.status(200).send(`Backfill ejecutado exitosamente. Se procesaron ${count} movimientos fijos para agosto.`);

  } catch (error) {
    console.error("Error en backfill de agosto:", error);
    return res.status(500).send("Ocurrió un error ejecutando el backfill.");
  }
});
