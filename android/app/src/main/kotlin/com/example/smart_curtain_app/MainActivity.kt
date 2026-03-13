package com.example.smart_curtain_app

import android.os.Bundle
import android.webkit.CookieManager
import com.amazon.identity.auth.device.AuthError
import com.amazon.identity.auth.device.api.authorization.*
import com.amazon.identity.auth.device.api.workflow.RequestContext
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.osprey/alexa_lwa"
    private lateinit var requestContext: RequestContext
    private var pendingResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestContext = RequestContext.create(applicationContext)
        requestContext.registerListener(object : AuthorizeListener() {
            override fun onSuccess(result: AuthorizeResult) {
                runOnUiThread {
                    pendingResult?.success(mapOf(
                        "status" to "success",
                        "accessToken" to result.accessToken,
                        "userId" to result.user?.userId,
                        "email" to result.user?.userEmail,
                        "name" to result.user?.userName
                    ))
                    pendingResult = null
                }
            }

            override fun onError(ae: AuthError) {
                runOnUiThread {
                    pendingResult?.success(mapOf(
                        "status" to "error",
                        "error" to (ae.message ?: "Unknown error"),
                        "errorType" to ae.type.name
                    ))
                    pendingResult = null
                }
            }

            override fun onCancel(cancellation: AuthCancellation) {
                runOnUiThread {
                    pendingResult?.success(mapOf(
                        "status" to "cancelled",
                        "description" to (cancellation.description ?: "User cancelled")
                    ))
                    pendingResult = null
                }
            }
        })
    }

    override fun onResume() {
        super.onResume()
        requestContext.onResume()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "signIn" -> {
                        val scopes = call.argument<List<String>>("scopes") ?: listOf("profile")
                        // Clear cache before every sign-in to force login screen
                        clearLwaCache()
                        pendingResult = result
                        signInWithScopes(scopes)
                    }
                    "signOut" -> {
                        signOut(result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun signInWithScopes(scopes: List<String>) {
        val builder = AuthorizeRequest.Builder(requestContext)
            .shouldReturnUserData(false)  // Don't use cached user data

        for (scope in scopes) {
            when (scope) {
                "profile" -> builder.addScope(ProfileScope.profile())
                "postal_code" -> builder.addScope(ProfileScope.postalCode())
                else -> {
                    // Custom scope (ví dụ: alexa::skills:account_linking)
                    builder.addScope(ScopeFactory.scopeNamed(scope))
                }
            }
        }

        AuthorizationManager.authorize(builder.build())
    }

    private fun signOut(result: MethodChannel.Result) {
        // Clear all LWA cached data from SharedPreferences
        clearLwaCache()

        AuthorizationManager.signOut(applicationContext, object :
            com.amazon.identity.auth.device.api.Listener<Void?, AuthError?> {
            override fun onSuccess(response: Void?) {
                // Clear again after signOut completes to be thorough
                clearLwaCache()
                runOnUiThread { result.success(mapOf("status" to "success")) }
            }
            override fun onError(ae: AuthError?) {
                // Still clear cache even on error
                clearLwaCache()
                runOnUiThread {
                    result.success(mapOf(
                        "status" to "error",
                        "error" to (ae?.message ?: "Sign out failed")
                    ))
                }
            }
        })
    }

    private fun clearLwaCache() {
        // Clear all Amazon identity SharedPreferences files
        val prefNames = listOf(
            "com.amazon.identity.auth.device.appid",
            "com.amazon.identity.auth.device",
            "LWAAuthorizationState",
            "com.amazon.identity.auth.device.api"
        )
        for (name in prefNames) {
            try {
                applicationContext
                    .getSharedPreferences(name, MODE_PRIVATE)
                    .edit()
                    .clear()
                    .apply()
            } catch (_: Exception) { }
        }

        // Clear WebView cookies (LWA SDK uses WebView for login)
        try {
            val cookieManager = CookieManager.getInstance()
            cookieManager.removeAllCookies(null)
            cookieManager.flush()
        } catch (_: Exception) { }
    }
}
