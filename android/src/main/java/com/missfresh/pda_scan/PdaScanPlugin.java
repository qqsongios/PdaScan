package com.missfresh.pda_scan;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.device.ScanManager;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Vibrator;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.uuzuche.lib_zxing.activity.CodeUtils;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static com.uuzuche.lib_zxing.activity.CodeUtils.RESULT_TYPE;
import static com.uuzuche.lib_zxing.activity.CodeUtils.RESULT_SUCCESS;


/**
 * PdaScanPlugin
 */
public class PdaScanPlugin implements FlutterPlugin, EventChannel.StreamHandler, MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener, ActivityAware {

    private Context applicationContext;
    private BroadcastReceiver scanResultReceiver;
    private EventChannel eventChannel;
    private Vibrator mVibrator;
    private SoundPool soundpool;
    private int soundId;
    private MethodChannel methodChannel;
    private Result scanResultByPhone;
    private Activity activity;
    private int REQUEST_CODE = 100;
    public static final String ACTION_DECODE = "android.intent.ACTION_DECODE_DATA";
    private ScanManager scanManager;
    private Handler handler = new Handler();
    public static final String TAG = "PdaScanPlugin";

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        onAttachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    private void onAttachedToEngine(Context applicationContext, BinaryMessenger messenger) {
        this.applicationContext = applicationContext;
        eventChannel = new EventChannel(messenger, "plugins.flutter.io/missfresh.scan");
        methodChannel = new MethodChannel(messenger, "plugins.flutter.io/missfresh.qrcode");
        eventChannel.setStreamHandler(this);
        methodChannel.setMethodCallHandler(this);


    }


    public static void registerWith(Registrar registrar) {
        final PdaScanPlugin instance = new PdaScanPlugin();
        instance.onAttachedToEngine(registrar.context(), registrar.messenger());
        registrar.addActivityResultListener(instance);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        applicationContext = null;
        eventChannel.setStreamHandler(null);
        eventChannel = null;

    }

    private void init(Context context) {
        mVibrator = (Vibrator) context.getSystemService(Context.VIBRATOR_SERVICE);
        soundpool = new SoundPool(1, AudioManager.STREAM_NOTIFICATION, 100);
        try {
            soundId = soundpool.load("/etc/Scan_new.ogg", 1);
        }catch (Exception e){
            Log.e(TAG,"该设备系统下没有Scan_new.ogg资源");
        }
    }

    private BroadcastReceiver createScanStateChangeReceiver(final EventChannel.EventSink events) {
        return new BroadcastReceiver() {
            public void onReceive(Context context, Intent intent) {
                soundpool.play(soundId, 1, 1, 0, 0, 1);
                mVibrator.vibrate(100);
                String code = intent.getStringExtra("barcode_string");
                events.success(code);
            }
        };
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        init(activity);
        scanResultReceiver = createScanStateChangeReceiver(events);
        applicationContext.registerReceiver(
                scanResultReceiver, getIntentFilter());
    }

    private IntentFilter getIntentFilter() {
        IntentFilter filter = new IntentFilter();
        filter.addAction("android.intent.ACTION_DECODE_DATA");
        filter.setPriority(Integer.MAX_VALUE);
        return filter;
    }

    @Override
    public void onCancel(Object arguments) {
        applicationContext.unregisterReceiver(scanResultReceiver);
        scanResultReceiver = null;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        this.scanResultByPhone = result;
        if (call.method.equals("scan")) {
            showBarcodeView();
        } else if (call.method.equals("isPDA")) {
            if ("qcom".equals(Build.BRAND)) {
                scanResultByPhone.success(true);
            } else {
                scanResultByPhone.success(false);
            }
        }else if(call.method.equals("scanStatus")){
            if(scanManager!=null)
            this.scanResultByPhone.success(scanManager.getOutputMode()+"");
        }else if(call.method.equals("switchModel0")){
            changeScanMode(0);
        }else if(call.method.equals("switchModel1")){
            changeScanMode(1);
        }
    }

    private void showBarcodeView() {
        Intent intent = new Intent(activity, ScanViewActivity.class);
        activity.startActivityForResult(intent, REQUEST_CODE);
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && intent != null) {
                Bundle secondBundle = intent.getBundleExtra("secondBundle");
                if (secondBundle != null) {
                    try {
                        CodeUtils.AnalyzeCallback analyzeCallback = new CustomAnalyzeCallback(this.scanResultByPhone, intent);
                        CodeUtils.analyzeBitmap(secondBundle.getString("path"), analyzeCallback);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    Bundle bundle = intent.getExtras();
                    if (bundle != null) {
                        if (bundle.getInt(RESULT_TYPE) == RESULT_SUCCESS) {
                            String barcode = bundle.getString(CodeUtils.RESULT_STRING);
                            if (scanResultByPhone != null && !TextUtils.isEmpty(barcode)) {
                                this.scanResultByPhone.success(barcode);
                            }
                        } else {
                            if (this.scanResultByPhone != null) {
                                this.scanResultByPhone.success(null);
                            }
                        }
                    }
                }
            } else {
                String errorCode = intent != null ? intent.getStringExtra("ERROR_CODE") : null;
                if (errorCode != null) {
                    this.scanResultByPhone.error(errorCode, null, null);
                }
            }
        }
        return true;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        binding.addActivityResultListener(this);
        this.activity = binding.getActivity();
        CheckPermissionUtils.initPermission(activity);
        changeScanMode(0);


    }

    private void changeScanMode(final int i) {
        handler.post(new Runnable() {
            @Override
            public void run() {
                try {
                    if (scanManager == null)
                        scanManager = new ScanManager();
                    scanManager.switchOutputMode(i);
                } catch (Exception e) {
                    Log.e(TAG, "该设备不支持红外扫描");
                }

            }
        });

    }


    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        binding.removeActivityResultListener(this);
    }

    @Override
    public void onDetachedFromActivity() {
        changeScanMode(1);

    }
}
