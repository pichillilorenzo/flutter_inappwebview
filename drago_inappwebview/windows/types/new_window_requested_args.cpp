#include "new_window_requested_args.h"

namespace drago_inappwebview_plugin
{
  NewWindowRequestedArgs::NewWindowRequestedArgs(wil::com_ptr<ICoreWebView2NewWindowRequestedEventArgs> args,
    wil::com_ptr<ICoreWebView2Deferral> deferral)
    : args(std::move(args)), deferral(std::move(deferral))
  {}

  NewWindowRequestedArgs::~NewWindowRequestedArgs()
  {
    // never leave WebView2 waiting on an unanswered new window request
    if (deferral) {
      deferral->Complete();
    }
  }
}
