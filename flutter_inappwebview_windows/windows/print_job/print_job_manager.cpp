#include "print_job_manager.h"

#include "print_job_controller.h"
#include "print_job_settings.h"
#include "../in_app_webview/in_app_webview.h"

namespace flutter_inappwebview_plugin
{
  PrintJobManager::PrintJobManager(InAppWebView* webView, flutter::BinaryMessenger* messenger)
    : webView_(webView), messenger_(messenger)
  {}

  std::shared_ptr<PrintJobController> PrintJobManager::createPrintJobController(
    const std::string& id,
    std::shared_ptr<PrintJobSettings> settings)
  {
    if (id.empty() || !webView_ || !messenger_) {
      return nullptr;
    }

    auto controller = std::make_shared<PrintJobController>(id, messenger_, webView_, settings);
    controller->markStarted();
    webView_->addPrintJobController(id, controller);
    return controller;
  }

  PrintJobController* PrintJobManager::getPrintJobController(const std::string& id) const
  {
    if (!webView_) {
      return nullptr;
    }
    return webView_->getPrintJobController(id);
  }

  void PrintJobManager::addPrintJobController(const std::string& id, std::shared_ptr<PrintJobController> controller)
  {
    if (!webView_) {
      return;
    }
    webView_->addPrintJobController(id, std::move(controller));
  }

  void PrintJobManager::erasePrintJobController(const std::string& id)
  {
    if (!webView_) {
      return;
    }
    webView_->erasePrintJobController(id);
  }

  void PrintJobManager::dispose()
  {
    if (!webView_) {
      messenger_ = nullptr;
      return;
    }
    webView_->disposeAllPrintJobControllers();
    webView_ = nullptr;
    messenger_ = nullptr;
  }

  PrintJobManager::~PrintJobManager()
  {
    dispose();
  }
}
