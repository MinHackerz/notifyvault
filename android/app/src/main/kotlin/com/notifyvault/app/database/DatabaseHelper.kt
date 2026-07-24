package com.notifyvault.app.database

import android.content.ContentValues
import android.content.Context
import android.content.pm.ApplicationInfo
import android.database.sqlite.SQLiteDatabase
import android.os.Build
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object DatabaseHelper {
    private const val TAG = "NotifyVaultDB"
    private const val DATABASE_NAME = "notify_vault.db.sqlite"
    private const val DATABASE_NAME_FALLBACK = "notify_vault.db"

    fun logToFile(context: Context, message: String) {
        Log.d(TAG, message)
        try {
            val logFile = File(context.filesDir, "service_debug.txt")
            if (logFile.exists()) {
                logFile.delete()
            }
        } catch (e: Exception) {
            // ignore
        }
    }

    private fun getDatabase(context: Context): SQLiteDatabase? {
        val paths = listOf(
            File(context.filesDir.parentFile, "app_flutter/$DATABASE_NAME"),
            File(context.filesDir.parentFile, "app_flutter/$DATABASE_NAME_FALLBACK"),
            context.getDatabasePath(DATABASE_NAME),
            context.getDatabasePath(DATABASE_NAME_FALLBACK),
            File(context.filesDir, DATABASE_NAME),
            File(context.filesDir, DATABASE_NAME_FALLBACK)
        )
        
        logToFile(context, "Looking for database...")
        for (file in paths) {
            val exists = file.exists()
            logToFile(context, "Path: ${file.absolutePath} - Exists: $exists")
            if (exists) {
                try {
                    val db = SQLiteDatabase.openDatabase(file.absolutePath, null, SQLiteDatabase.OPEN_READWRITE)
                    logToFile(context, "Successfully opened database at ${file.absolutePath}")
                    return db
                } catch (e: Exception) {
                    logToFile(context, "Error opening database at ${file.absolutePath}: ${e.message}")
                }
            }
        }
        
        logToFile(context, "ERROR: Database file not found in any standard location")
        return null
    }

    fun saveNotificationDirectly(context: Context, data: Map<String, Any?>) {
        val id = data["id"] as? String ?: return
        val packageName = data["packageName"] as? String ?: return
        val appName = data["appName"] as? String ?: return
        val title = data["title"] as? String
        val body = data["body"] as? String
        val bigText = data["bigText"] as? String
        val timestampMs = data["timestamp"] as? Long ?: System.currentTimeMillis()
        val timestampSec = timestampMs / 1000
        val importance = data["importance"] as? Int ?: 3
        val senderName = data["senderName"] as? String
        val conversationId = data["conversationId"] as? String
        val iconPath = data["iconPath"] as? String
        val notificationCategory = data["category"] as? String
        val isMessagingStyle = data["isMessagingStyle"] as? Boolean ?: false

        logToFile(context, "Attempting to save notification directly from $packageName ($appName), Title: $title")

        // Skip notifications with no meaningful content (same as Dart side)
        if (title.isNullOrEmpty() && body.isNullOrEmpty() && bigText.isNullOrEmpty()) {
            logToFile(context, "Skipped notification from $packageName because title, body, and bigText are all empty")
            return
        }

        val db = getDatabase(context)
        if (db == null) {
            logToFile(context, "ERROR: Cannot save notification because database is null")
            return
        }

        db.beginTransaction()
        try {
            // Check for system bounce duplicates (identical text within ~1.5 seconds)
            val recentCursor = db.rawQuery("SELECT title, body, big_text, timestamp FROM notifications WHERE package_name = ? ORDER BY timestamp DESC LIMIT 1", arrayOf(packageName))
            if (recentCursor.moveToFirst()) {
                val rTitle = recentCursor.getString(0)
                val rBody = recentCursor.getString(1)
                val rBigText = recentCursor.getString(2)
                val rTimestampSec = recentCursor.getLong(3)
                
                if (rTitle == title && rBody == body && rBigText == bigText) {
                    if (Math.abs(timestampSec - rTimestampSec) <= 1) { // 0 or 1 second difference
                        logToFile(context, "Skipping system bounce duplicate for $packageName")
                        recentCursor.close()
                        db.endTransaction()
                        return
                    }
                }
            }
            recentCursor.close()

            // 1. Get system app category dynamically
            val appCategory = getAppCategory(context, packageName)

            // 2. Classify intelligently
            val category = determineCategory(packageName, title, body, bigText, appCategory, notificationCategory, isMessagingStyle)

            // 3. Generate final ID (matching rawId_timestampVal pattern in Dart)
            val finalId = "${id}_${timestampMs}"

            // 4. Insert or replace notification
            val values = ContentValues().apply {
                put("id", finalId)
                put("package_name", packageName)
                put("app_name", appName)
                put("title", title)
                put("body", body)
                put("big_text", bigText)
                put("timestamp", timestampSec)
                put("category", category)
                put("importance", importance)
                put("is_read", 0) // default false
                put("is_dismissed", 0) // default false
                put("sender_name", senderName)
                put("conversation_id", conversationId)
                put("icon_path", iconPath)
                put("is_favorite", 0) // default false
            }

            val rowId = db.insertWithOnConflict("notifications", null, values, SQLiteDatabase.CONFLICT_REPLACE)
            logToFile(context, "Inserted notification row: $rowId, finalId: $finalId")

            // 5. Upsert app (compatible with all SQLite/Android versions)
            val cursor = db.rawQuery("SELECT notification_count, icon_path FROM apps WHERE package_name = ?", arrayOf(packageName))
            if (cursor.moveToFirst()) {
                val currentCount = cursor.getInt(0)
                val existingIcon = cursor.getString(1)
                val newIcon = iconPath ?: existingIcon
                
                val appValues = ContentValues().apply {
                    put("app_name", appName)
                    put("icon_path", newIcon)
                    put("notification_count", currentCount + 1)
                    put("last_notification_at", timestampSec)
                }
                db.update("apps", appValues, "package_name = ?", arrayOf(packageName))
                logToFile(context, "Updated app tracker for $packageName: count = ${currentCount + 1}")
            } else {
                val appValues = ContentValues().apply {
                    put("package_name", packageName)
                    put("app_name", appName)
                    put("icon_path", iconPath)
                    put("notification_count", 1)
                    put("last_notification_at", timestampSec)
                }
                db.insert("apps", null, appValues)
                logToFile(context, "Created new app tracker for $packageName")
            }
            cursor.close()

            db.setTransactionSuccessful()
            logToFile(context, "Transaction successful. Saved notification from $packageName directly to SQLite ($category)")
        } catch (e: Exception) {
            logToFile(context, "ERROR in transaction: ${e.message}")
            Log.e(TAG, "Failed to save notification directly: ${e.message}", e)
        } finally {
            db.endTransaction()
            try {
                db.close()
                logToFile(context, "Database closed")
            } catch (e: Exception) {
                // ignore
            }
        }
    }

    fun dismissNotificationDirectly(context: Context, key: String) {
        logToFile(context, "Attempting to dismiss notification directly, key: $key")
        val db = getDatabase(context)
        if (db == null) {
            logToFile(context, "ERROR: Cannot dismiss notification because database is null")
            return
        }
        try {
            val values = ContentValues().apply {
                put("is_dismissed", 1)
            }
            val rows = db.update("notifications", values, "id = ? OR id LIKE ?", arrayOf(key, "$key%"))
            logToFile(context, "Successfully marked notification as dismissed: $key, rows affected: $rows")
        } catch (e: Exception) {
            logToFile(context, "ERROR dismissing notification: ${e.message}")
            Log.e(TAG, "Failed to mark notification as dismissed: ${e.message}", e)
        } finally {
            try {
                db.close()
                logToFile(context, "Database closed")
            } catch (e: Exception) {
                // ignore
            }
        }
    }

    fun isReadOutLoudEnabled(context: Context, packageName: String): Boolean {
        val db = getDatabase(context) ?: return false
        var enabled = false
        try {
            val cursor = db.rawQuery("SELECT read_out_loud FROM app_preferences WHERE package_name = ?", arrayOf(packageName))
            if (cursor.moveToFirst()) {
                enabled = cursor.getInt(0) == 1
            }
            cursor.close()
        } catch (e: Exception) {
            logToFile(context, "ERROR checking read_out_loud for $packageName: ${e.message}")
        } finally {
            try { db.close() } catch (e: Exception) {}
        }
        return enabled
    }

    private fun getAppCategory(context: Context, packageName: String): String {
        return try {
            val pm = context.packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                when (appInfo.category) {
                    ApplicationInfo.CATEGORY_GAME -> "game"
                    ApplicationInfo.CATEGORY_AUDIO -> "audio"
                    ApplicationInfo.CATEGORY_VIDEO -> "video"
                    ApplicationInfo.CATEGORY_IMAGE -> "image"
                    ApplicationInfo.CATEGORY_SOCIAL -> "social"
                    ApplicationInfo.CATEGORY_NEWS -> "news"
                    ApplicationInfo.CATEGORY_MAPS -> "maps"
                    ApplicationInfo.CATEGORY_PRODUCTIVITY -> "productivity"
                    else -> "undefined"
                }
            } else {
                "undefined"
            }
        } catch (e: Exception) {
            "undefined"
        }
    }

    // ─── Public entry point for NotificationCaptureService ───
    fun classifyNotification(
        context: Context,
        packageName: String,
        title: String?,
        body: String?,
        bigText: String?,
        appCategory: String,
        notificationCategory: String?,
        isMessagingStyle: Boolean
    ): String {
        // Priority 0: User-assigned category override (absolute highest priority)
        val userOverride = getCategoryOverride(context, packageName)
        if (userOverride != null) return userOverride

        return determineCategory(packageName, title, body, bigText, appCategory, notificationCategory, isMessagingStyle)
    }

    /// Query the app_preferences table for a user-set category override.
    private fun getCategoryOverride(context: Context, packageName: String): String? {
        val db = getDatabase(context) ?: return null
        var override: String? = null
        try {
            val cursor = db.rawQuery(
                "SELECT category_override FROM app_preferences WHERE package_name = ?",
                arrayOf(packageName)
            )
            if (cursor.moveToFirst()) {
                override = cursor.getString(0)
            }
            cursor.close()
        } catch (e: Exception) {
            logToFile(context, "Error checking category override for $packageName: ${e.message}")
        } finally {
            try { db.close() } catch (e: Exception) {}
        }
        return override
    }

    private fun determineCategory(
        packageName: String,
        title: String?,
        body: String?,
        bigText: String?,
        appCategory: String,
        notificationCategory: String?,
        isMessagingStyle: Boolean
    ): String {
        val content = "${title ?: ""} ${body ?: ""} ${bigText ?: ""}".lowercase()
        if (content.trim().isEmpty()) return "other"

        // 1. Content-based OTP check (Highest Priority — time-sensitive)
        if (containsOtp(content)) return "otp"

        // 2. Package name exact match (most accurate offline signal)
        val pkgCategory = packageCategoryMap[packageName]
        if (pkgCategory != null) return pkgCategory

        // 3. Package name prefix match (app families)
        for ((prefix, category) in packagePrefixRules) {
            if (packageName.startsWith(prefix)) return category
        }

        // 4. Native notification category metadata
        if (notificationCategory != null) {
            when (notificationCategory.lowercase()) {
                "msg", "call" -> return "messages"
                "email" -> return "email"
                "promo", "recommendation" -> return "promotions"
                "social" -> return if (isMessagingStyle) "messages" else "social"
                "transport" -> return "delivery"
                "event", "reminder" -> return "work"
            }
        }

        // 5. Android system app category
        when (appCategory.lowercase()) {
            "game", "audio", "video" -> return "entertainment"
            "social" -> return if (isMessagingStyle) "messages" else "social"
            "productivity" -> return "work"
            "maps" -> return "delivery"
        }

        // 6. Enhanced keyword analysis fallback
        var bestScore = 0
        var bestCategory = "other"

        for ((category, keywords) in keywordCategories) {
            var score = 0
            for (keyword in keywords) {
                if (content.contains(keyword)) {
                    // Multi-word phrases get bonus weight (more specific = more reliable)
                    score += if (keyword.contains(' ')) 3 else 1
                }
            }
            if (score > bestScore) {
                bestScore = score
                bestCategory = category
            }
        }

        return bestCategory
    }

    // ─── Package name → category exact mappings ───
    private val packageCategoryMap = mapOf(
        // ── Messages ──
        "com.whatsapp" to "messages",
        "com.whatsapp.w4b" to "messages",
        "org.telegram.messenger" to "messages",
        "org.telegram.messenger.web" to "messages",
        "org.thoughtcrime.securesms" to "messages",
        "com.facebook.orca" to "messages",
        "com.facebook.mlite" to "messages",
        "com.viber.voip" to "messages",
        "com.tencent.mm" to "messages",
        "jp.naver.line.android" to "messages",
        "com.discord" to "messages",
        "com.Slack" to "messages",
        "com.kakao.talk" to "messages",
        "com.imo.android.imoim" to "messages",
        "com.google.android.apps.messaging" to "messages",
        "com.samsung.android.messaging" to "messages",
        "com.android.mms" to "messages",
        "com.textra" to "messages",
        "com.jio.jioplay.tv" to "messages",
        "com.jiochat.jiochatapp" to "messages",
        "com.skype.raider" to "messages",
        "com.skype.m2" to "messages",
        "com.threema.app" to "messages",
        "com.wire" to "messages",
        "org.briarproject.briar.android" to "messages",
        "im.vector.app" to "messages",
        "io.element.android" to "messages",

        // ── Social ──
        "com.instagram.android" to "social",
        "com.instagram.lite" to "social",
        "com.facebook.katana" to "social",
        "com.facebook.lite" to "social",
        "com.twitter.android" to "social",
        "com.twitter.android.lite" to "social",
        "com.snapchat.android" to "social",
        "com.linkedin.android" to "social",
        "com.linkedin.android.lite" to "social",
        "com.reddit.frontpage" to "social",
        "com.zhiliaoapp.musically" to "social",
        "com.ss.android.ugc.trill" to "social",
        "com.pinterest" to "social",
        "in.mohalla.sharechat" to "social",
        "com.kustomer.koo" to "social",
        "com.tumblr" to "social",
        "com.quora.android" to "social",
        "com.mastodon.android" to "social",
        "com.bereal.ft" to "social",
        "com.lemon8.android" to "social",
        "com.threads.android" to "social",
        "com.bluesky.android" to "social",

        // ── Banking ──
        "com.sbi.SBIFreedomPlus" to "banking",
        "com.sbi.lotusintouch" to "banking",
        "com.csam.icici.bank.imobile" to "banking",
        "com.icicibank.pocketsunite" to "banking",
        "com.snapwork.hdfc" to "banking",
        "com.hdfc.retail" to "banking",
        "com.axis.mobile" to "banking",
        "com.kotak.mobile.banking" to "banking",
        "com.bob.bmir" to "banking",
        "com.pnb.nb.app" to "banking",
        "com.canaaboretail.mobilebanking" to "banking",
        "com.idbibank.abhay.pay" to "banking",
        "com.infrasofttech.centralbank" to "banking",
        "com.ucobank.ucoturbo" to "banking",
        "com.fss.iob" to "banking",
        "com.lcode.smartz" to "banking",
        "com.indus.induspay" to "banking",
        "com.msf.kbank.mobile" to "banking",
        "in.yesbank.yesmobile" to "banking",
        "com.rbl.mobank" to "banking",
        "com.jpm.sig.android" to "banking",
        "com.chase.sig.android" to "banking",
        "com.wf.wellsfargomobile" to "banking",
        "com.bankofamerica.cashpromobile" to "banking",
        "com.citi.citimobile" to "banking",
        "com.hsbc.hsbcnet" to "banking",
        "com.barclays.android.barclaysmobilebanking" to "banking",
        "uk.co.hsbc.hsbcukmobilebanking" to "banking",
        "com.revolut.revolut" to "banking",
        "com.n26.android" to "banking",
        "com.starfinanz.smob.android.sfinanzstatus" to "banking",
        "au.com.commbank.netbank" to "banking",
        "nz.co.anz.android.mobilebanking" to "banking",

        // ── Payments ──
        "com.google.android.apps.nbu.paisa.user" to "payments",
        "com.phonepe.app" to "payments",
        "net.one97.paytm" to "payments",
        "in.org.npci.upiapp" to "payments",
        "com.amazon.mShop.android.shopping" to "shopping",
        "com.amazon.pay.in" to "payments",
        "com.mobikwik_new" to "payments",
        "com.freecharge.android" to "payments",
        "in.juspay.nammayatri" to "payments",
        "com.myairtelapp" to "payments",
        "com.jio.myjio" to "payments",
        "com.paypal.android.p2pmobile" to "payments",
        "com.venmo" to "payments",
        "com.squareup.cash" to "payments",
        "com.zellepay.zelle" to "payments",
        "com.wise.android" to "payments",
        "com.stripe.android.dashboard" to "payments",
        "com.razorpay.payments.app" to "payments",
        "com.cred.android" to "payments",

        // ── Shopping ──
        "com.flipkart.android" to "shopping",
        "club.myntra" to "shopping",
        "com.meesho.supply" to "shopping",
        "com.ril.ajio" to "shopping",
        "com.shopsy.app" to "shopping",
        "in.firstcry.app" to "shopping",
        "com.nykaa.android" to "shopping",
        "com.purplle.purplle" to "shopping",
        "com.jiomart.app" to "shopping",
        "com.snapdeal.main" to "shopping",
        "com.ebay.mobile" to "shopping",
        "com.alibaba.aliexpresshd" to "shopping",
        "com.shopee.id" to "shopping",
        "com.lazada.android" to "shopping",
        "com.walmart.android" to "shopping",
        "com.target.ui" to "shopping",
        "com.tatacliq.app" to "shopping",
        "com.bigbasket.mobileapp" to "shopping",

        // ── Delivery ──
        "in.swiggy.android" to "delivery",
        "com.application.zomato" to "delivery",
        "com.dunzo.user" to "delivery",
        "com.zeptoconsumerapp" to "delivery",
        "com.grofers.customerapp" to "delivery",
        "com.blinkit.user" to "delivery",
        "com.ubercab.eats" to "delivery",
        "com.dd.doordash" to "delivery",
        "com.grubhub.android" to "delivery",
        "com.ubercab" to "delivery",
        "com.olacabs.customer" to "delivery",
        "com.rapido.passenger" to "delivery",
        "com.delhivery.rogue" to "delivery",
        "com.fedex.ida.android" to "delivery",
        "com.dhl.ship" to "delivery",
        "com.bluedart.android" to "delivery",
        "com.porter.driver" to "delivery",
        "com.instamart.consumer" to "delivery",
        "com.instacart.client" to "delivery",

        // ── Email ──
        "com.google.android.gm" to "email",
        "com.microsoft.office.outlook" to "email",
        "com.yahoo.mobile.client.android.mail" to "email",
        "com.samsung.android.email.provider" to "email",
        "ch.protonmail.android" to "email",
        "me.proton.android.mail" to "email",
        "com.tutanota.tutanota" to "email",
        "com.zoho.mail" to "email",
        "org.mozilla.thunderbird" to "email",
        "com.readdle.spark" to "email",
        "com.fastmail.app" to "email",
        "com.edison.apps.mail" to "email",
        "com.easilydo.mail" to "email",

        // ── Work ──
        "com.microsoft.teams" to "work",
        "us.zoom.videomeetings" to "work",
        "com.google.android.apps.meetings" to "work",
        "com.notion.id" to "work",
        "com.asana.app" to "work",
        "com.trello" to "work",
        "com.atlassian.android.jira.core" to "work",
        "com.microsoft.office.officehubrow" to "work",
        "com.google.android.apps.docs" to "work",
        "com.google.android.apps.docs.editors.sheets" to "work",
        "com.google.android.apps.docs.editors.slides" to "work",
        "com.google.android.apps.dynamite" to "work",
        "com.google.android.apps.meetings" to "work",
        "com.basecamp.bc3" to "work",
        "com.todoist" to "work",
        "com.ticktick.task" to "work",
        "com.microsoft.todos" to "work",
        "com.clickup.app" to "work",
        "com.monday.monday" to "work",
        "com.figma.mirror" to "work",

        // ── Entertainment ──
        "com.google.android.youtube" to "entertainment",
        "com.google.android.apps.youtube.music" to "entertainment",
        "com.netflix.mediaclient" to "entertainment",
        "com.spotify.music" to "entertainment",
        "com.amazon.avod.thirdpartyclient" to "entertainment",
        "com.amazon.avod" to "entertainment",
        "com.disney.disneyplus" to "entertainment",
        "in.startv.hotstar" to "entertainment",
        "com.jio.media.jiobeats" to "entertainment",
        "com.jio.jioplay.tv" to "entertainment",
        "com.bsbportal.music" to "entertainment",
        "com.hungama.myplay.activity" to "entertainment",
        "com.sonyliv" to "entertainment",
        "com.voot.android" to "entertainment",
        "com.zee5.hiburan" to "entertainment",
        "com.graymatrix.did" to "entertainment",
        "com.apple.android.music" to "entertainment",
        "com.soundcloud.android" to "entertainment",
        "tv.twitch.android.app" to "entertainment",
        "com.crunchyroll.crunchyroid" to "entertainment",
        "com.mxtech.videoplayer.ad" to "entertainment",
        "com.mxtech.videoplayer.pro" to "entertainment",
        "org.videolan.vlc" to "entertainment",

        // ── Health ──
        "com.practo.fabric" to "health",
        "com.aranoah.healthkart.plus" to "health",
        "com.pharmeasy.app" to "health",
        "com.netmeds.app" to "health",
        "com.lybrate.lybrate" to "health",
        "com.fitbit.FitbitMobile" to "health",
        "com.google.android.apps.fitness" to "health",
        "com.samsung.android.forest" to "health",
        "com.myfitnesspal.android" to "health",
        "com.calm.android" to "health",
        "com.headspace.android" to "health",
        "com.strava" to "health",
        "cc.pacer.androidapp" to "health",
        "com.noom.walk" to "health",
        "com.flo.health" to "health",
        "com.clue.android" to "health",
        "com.apollopharmacy.patient" to "health",

        // ── Education ──
        "com.google.android.apps.classroom" to "education",
        "com.duolingo" to "education",
        "com.byjus.thelearningapp" to "education",
        "com.unacademy.unacademylearningapp" to "education",
        "com.vedantu" to "education",
        "org.coursera.android" to "education",
        "com.khanacademy.android" to "education",
        "com.udemy.android" to "education",
        "com.linkedin.android.learning" to "education",
        "com.toppr.app" to "education",
        "com.meritnation.app" to "education",
        "com.extramarks.learningapp" to "education",
        "com.upgrad.learner" to "education",
        "com.simplilearn.app.android" to "education",
        "in.testbook.tbapp" to "education",
        "co.gradeup.android" to "education",
        "com.brainly" to "education",
        "com.photomath" to "education",
        "com.quizlet.quizletandroid" to "education",

        // ── Government ──
        "nic.goi.aarogyasetu" to "government",
        "in.gov.uidai.mAadhaarPlus" to "government",
        "in.gov.umang.negd.g2c" to "government",
        "com.digilocker.android" to "government",
        "in.org.npci.upiapp" to "government",
        "nic.goi.cowinapp" to "government",
        "com.mygov.mygov" to "government",
        "in.gov.epfindia.member" to "government",
        "com.gst.search" to "government",
        "in.gov.itr.efile" to "government"
    )

    // ─── Package prefix → category rules (for app families) ───
    private val packagePrefixRules = listOf(
        "com.sbi." to "banking",
        "com.icicibank." to "banking",
        "com.hdfc." to "banking",
        "com.axis." to "banking",
        "com.kotak." to "banking",
        "com.bob." to "banking",
        "com.pnb." to "banking",
        "com.google.android.gm" to "email",
        "com.whatsapp" to "messages",
        "org.telegram." to "messages"
    )

    // ─── Keyword categories with enhanced multi-word phrases ───
    private val keywordCategories = mapOf(
        "messages" to listOf("new message", "sent you a message", "chat", "sms", "pinged you", "sent a photo", "sent a video", "sent a sticker", "is typing", "voice message", "missed call"),
        "banking" to listOf("credited to your", "debited from your", "bank balance", "neft", "rtgs", "imps", "atm withdrawal", "bank account", "ifsc", "net banking", "a/c ending", "account ending"),
        "payments" to listOf("payment of", "paid to", "received from", "upi transaction", "₹", "cashback", "refund of", "invoice", "wallet balance", "money transferred", "payment successful", "payment failed"),
        "shopping" to listOf("order placed", "order shipped", "order confirmed", "add to cart", "wishlist", "flash sale", "coupon code", "buy now", "your order", "items in cart"),
        "delivery" to listOf("out for delivery", "has been delivered", "delivery partner", "arriving today", "tracking id", "shipment update", "courier", "parcel", "your package", "estimated delivery"),
        "health" to listOf("appointment with", "doctor", "hospital", "prescription", "medicine", "medical report", "vaccine", "lab report", "test result", "health checkup"),
        "promotions" to listOf("exclusive offer", "limited time", "special offer", "promo code", "flash sale", "hurry", "don't miss", "free trial", "upgrade now", "% off", "save up to", "claim now"),
        "work" to listOf("meeting at", "meeting in", "calendar event", "deadline", "project update", "task assigned", "sprint", "standup", "pull request", "code review", "deployed"),
        "government" to listOf("aadhaar", "pan card", "passport", "digilocker", "income tax", "gst", "government of", "ministry of"),
        "education" to listOf("lecture", "exam", "assignment due", "course", "study", "lesson", "quiz", "class starts", "homework", "new module"),
        "email" to listOf("new email", "email from", "inbox", "unread email", "reply to"),
        "social" to listOf("liked your", "commented on", "started following", "mentioned you", "tagged you", "new follower", "friend request", "shared your", "reacted to"),
        "entertainment" to listOf("now playing", "new episode", "new release", "watch now", "listen now", "live stream", "playlist", "trending", "recommended for you")
    )

    private fun containsOtp(content: String): Boolean {
        val otpPatterns = listOf(
            Regex("\\b\\d{4,8}\\b.*(?:otp|code|verify)", RegexOption.IGNORE_CASE),
            Regex("(?:otp|code|verify).*\\b\\d{4,8}\\b", RegexOption.IGNORE_CASE),
            Regex("one.?time.?password", RegexOption.IGNORE_CASE),
            Regex("verification\\s*code", RegexOption.IGNORE_CASE),
            Regex("security\\s*code", RegexOption.IGNORE_CASE),
            Regex("your\\s+\\w*\\s*code\\s+is", RegexOption.IGNORE_CASE)
        )
        return otpPatterns.any { it.containsMatchIn(content) }
    }
}

