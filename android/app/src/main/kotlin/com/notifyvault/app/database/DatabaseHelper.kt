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
                put("is_synced", 0) // default false
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

        // 1. Content-based OTP check (Highest Priority)
        if (containsOtp(content)) return "otp"

        // 2. Native Notification Category check
        if (notificationCategory != null) {
            when (notificationCategory.lowercase()) {
                "msg", "call" -> return "messages"
                "email" -> return "email"
                "promo", "recommendation" -> return "promotions"
                "social" -> {
                    // Chat/message style notifications are promoted to messages, others are social
                    return if (isMessagingStyle) "messages" else "social"
                }
                "transport" -> return "delivery"
                "event", "reminder" -> return "work"
            }
        }

        // 3. System App Category check
        when (appCategory.lowercase()) {
            "game", "audio", "video" -> return "entertainment"
            "social" -> {
                // Check if it's a direct conversation/chat message
                return if (isMessagingStyle) "messages" else "social"
            }
            "productivity" -> return "work"
            "maps" -> return "delivery"
        }

        // 4. Keyword analysis fallback
        var bestScore = 0
        var bestCategory = "other"

        for ((category, keywords) in keywordCategories) {
            var score = 0
            for (keyword in keywords) {
                if (content.contains(keyword)) {
                    score++
                }
            }
            if (score > bestScore) {
                bestScore = score
                bestCategory = category
            }
        }

        return bestCategory
    }

    private val keywordCategories = mapOf(
        "messages" to listOf("message", "messages", "chat", "text", "sms", "pinged", "sent a photo", "sent a video", "sticker"),
        "banking" to listOf("account", "balance", "credited", "debited", "transaction", "transfer", "neft", "rtgs", "imps", "bank", "atm", "withdrawal", "deposit", "statement", "ifsc"),
        "payments" to listOf("payment", "paid", "received", "upi", "rupee", "inr", "₹", "wallet", "cashback", "refund", "invoice"),
        "shopping" to listOf("order", "placed", "shipped", "dispatch", "cart", "wishlist", "deal", "offer", "discount", "coupon", "sale", "buy", "purchase"),
        "delivery" to listOf("delivered", "delivery", "out for delivery", "arriving", "tracking", "shipment", "courier", "parcel", "package", "eta"),
        "health" to listOf("appointment", "doctor", "hospital", "medicine", "prescription", "health", "medical", "vaccine", "lab report", "test result"),
        "promotions" to listOf("exclusive", "limited time", "special offer", "promo", "flash sale", "hurry", "don't miss", "subscribe", "free trial", "upgrade"),
        "work" to listOf("meeting", "calendar", "schedule", "deadline", "project", "task", "assigned", "jira", "sprint", "standup"),
        "government" to listOf("aadhaar", "pan card", "passport", "digilocker", "income tax", "gst", "government", "ministry"),
        "education" to listOf("class", "lecture", "exam", "assignment", "course", "grade", "study", "lesson", "quiz", "tutorial")
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
