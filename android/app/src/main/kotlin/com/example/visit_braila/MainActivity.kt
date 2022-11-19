package com.vmasoftware.visit_braila

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val methodChannel = "city.visit.braila"
    private val eventChannel = "city.visit.braila/incomingRedirects"

    private var startLink: String? = null;
    private var linksReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor, methodChannel).setMethodCallHandler {call, result ->
            if(call.method == "initialLink"){
                if(startLink != null){
                    result.success(startLink)
                }else{
                    result.error("UNAVAILABLE", "No link used to start the app", null)
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor, eventChannel).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any?, events: EventChannel.EventSink) {
                        linksReceiver = createChangeReceiver(events)
                    }

                    override fun onCancel(args: Any?) {
                        linksReceiver = null
                    }
                }
        )
    }

    override fun onCreate(savedInstanceState: Bundle?){
        super.onCreate(savedInstanceState)

        val intent = getIntent()
        startLink = intent.data?.toString()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action === Intent.ACTION_VIEW) {
            linksReceiver?.onReceive(this.applicationContext, intent)
        }
    }

    fun createChangeReceiver(events: EventChannel.EventSink): BroadcastReceiver? {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val dataString = intent.dataString ?:
                events.error("UNAVAILABLE", "Link unavailable", null)
                events.success(dataString)
            }
        }
    }
}
