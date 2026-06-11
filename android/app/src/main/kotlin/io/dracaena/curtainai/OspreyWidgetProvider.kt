package io.dracaena.curtainai

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget rèm Osprey — hiển thị thiết bị chính + 3 nút Open/Stop/Close.
 *
 * Dữ liệu đến từ `HomeWidgetService` (Dart) qua SharedPreferences của
 * home_widget. Nút bấm phát [HomeWidgetBackgroundIntent] → Dart callback
 * `ospreyWidgetCallback` chạy nền gọi API (không mở app).
 */
class OspreyWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.osprey_widget).apply {
                val name = widgetData.getString("widget_device_name", null) ?: "Curtain"
                val online = widgetData.getBoolean("widget_device_online", false)
                val error = widgetData.getString("widget_error", "") ?: ""
                val hasDevice =
                    !widgetData.getString("widget_device_id", "").isNullOrEmpty()

                setTextViewText(R.id.widget_device_name, name)
                val status = when {
                    !hasDevice -> "Mở app để thiết lập"
                    error == "no_auth" || error == "auth_expired" -> "Mở app để đăng nhập"
                    error == "network" -> "Lỗi mạng"
                    error.startsWith("http_") -> "Lỗi ${error.removePrefix("http_")}"
                    online -> "Online"
                    else -> "Offline"
                }
                setTextViewText(R.id.widget_status, status)
                setTextColor(
                    R.id.widget_status,
                    when {
                        error.isNotEmpty() || !hasDevice -> 0xFFD64545.toInt()
                        online -> 0xFF2E8B57.toInt()
                        else -> 0xFF6B8299.toInt()
                    },
                )

                setOnClickPendingIntent(R.id.btn_open, command(context, "open"))
                setOnClickPendingIntent(R.id.btn_stop, command(context, "stop"))
                setOnClickPendingIntent(R.id.btn_close, command(context, "close"))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun command(context: Context, action: String) =
        HomeWidgetBackgroundIntent.getBroadcast(
            context,
            Uri.parse("ospreywidget://control?action=$action"),
        )
}
