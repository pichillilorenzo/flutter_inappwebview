/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package com.pichillilorenzo.flutter_inappwebview.print_job;

import android.os.Build;

import androidx.annotation.RequiresApi;

import com.pichillilorenzo.flutter_inappwebview.types.Disposable;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@RequiresApi(api = Build.VERSION_CODES.KITKAT)
public class PrintJobManager implements Disposable {
  protected static final String LOG_TAG = "PrintJobManager";
  
  public static final Map<String, PrintJobController> jobs = new HashMap<>();

  public PrintJobManager() {
    super();
  }

  public void dispose() {
    Collection<PrintJobController> printJobControllers = jobs.values();
    for (PrintJobController job : printJobControllers) {
      if (job != null) {
        job.dispose();
      }
    }
    jobs.clear();
  }
}
