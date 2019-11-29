package com.pichillilorenzo.flutter_inappwebview;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public abstract class RequestPermissionHandler implements ActivityCompat.OnRequestPermissionsResultCallback {

    private static Map<Integer, List<Runnable>> actionDictionary = new HashMap<>();

    public static void checkAndRun(Activity activity, String permission, int requestCode, Runnable runnable) {

        int permissionCheck = ContextCompat.checkSelfPermission(activity.getApplicationContext(), permission);

        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            if (actionDictionary.containsKey(requestCode))
                actionDictionary.get(requestCode).add(runnable);
            else
                actionDictionary.put(requestCode, Arrays.asList(runnable));
            ActivityCompat.requestPermissions(activity, new String[]{permission}, requestCode);
        }
        else
            runnable.run();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        Log.d("asdasd", "\n\na asd asd \n\n");
        if ((grantResults.length > 0) && (grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
            List<Runnable> callbacks = actionDictionary.get(requestCode);
            for (Runnable runnable : callbacks) {
                runnable.run();
                callbacks.remove(runnable);
            }
        }
    }

}
