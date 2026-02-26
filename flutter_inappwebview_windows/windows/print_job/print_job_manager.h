#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_MANAGER_H_

#include <flutter/binary_messenger.h>

#include <memory>
#include <string>

#include "print_job_settings.h"

namespace flutter_inappwebview_plugin
{
  class InAppWebView;
  class PrintJobController;

  class PrintJobManager
  {
  public:
    PrintJobManager(InAppWebView* webView, flutter::BinaryMessenger* messenger);
    ~PrintJobManager();

    std::shared_ptr<PrintJobController> createPrintJobController(
      const std::string& id,
      std::shared_ptr<PrintJobSettings> settings);
    PrintJobController* getPrintJobController(const std::string& id) const;
    void addPrintJobController(const std::string& id, std::shared_ptr<PrintJobController> controller);
    void erasePrintJobController(const std::string& id);
    void dispose();

  private:
    InAppWebView* webView_ = nullptr;
    flutter::BinaryMessenger* messenger_ = nullptr;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_MANAGER_H_
