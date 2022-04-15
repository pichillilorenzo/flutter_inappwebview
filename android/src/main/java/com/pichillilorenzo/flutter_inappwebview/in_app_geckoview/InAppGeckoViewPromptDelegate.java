package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.mozilla.geckoview.Autocomplete;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;

import io.flutter.plugin.common.MethodChannel;

public class InAppGeckoViewPromptDelegate implements GeckoSession.PromptDelegate {

  protected static final String LOG_TAG = "IAGeckoViewPromptDelegate";
  private final MethodChannel channel;
  @Nullable
  private InAppGeckoView inAppGeckoView;

  public InAppGeckoViewPromptDelegate(@NonNull InAppGeckoView inAppGeckoView, MethodChannel channel) {
    super();

    this.inAppGeckoView = inAppGeckoView;
    this.channel = channel;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onAlertPrompt(@NonNull GeckoSession session, @NonNull AlertPrompt prompt) {
    GeckoResult<PromptResponse> promptResponse = new GeckoResult<>();
    if (inAppGeckoView != null && inAppGeckoView.isPausedTimers) {
      inAppGeckoView.isPausedTimersGeckoResult = promptResponse;
      inAppGeckoView.isPausedTimersPromptResponse = prompt.dismiss();
      return promptResponse;
    }

    // TODO: implement

    return promptResponse;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onBeforeUnloadPrompt(@NonNull GeckoSession session, @NonNull BeforeUnloadPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onRepostConfirmPrompt(@NonNull GeckoSession session, @NonNull RepostConfirmPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onButtonPrompt(@NonNull GeckoSession session, @NonNull ButtonPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onTextPrompt(@NonNull GeckoSession session, @NonNull TextPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onAuthPrompt(@NonNull GeckoSession session, @NonNull AuthPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onChoicePrompt(@NonNull GeckoSession session, @NonNull ChoicePrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onColorPrompt(@NonNull GeckoSession session, @NonNull ColorPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onDateTimePrompt(@NonNull GeckoSession session, @NonNull DateTimePrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onFilePrompt(@NonNull GeckoSession session, @NonNull FilePrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onPopupPrompt(@NonNull GeckoSession session, @NonNull PopupPrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onSharePrompt(@NonNull GeckoSession session, @NonNull SharePrompt prompt) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onLoginSave(@NonNull GeckoSession session, @NonNull AutocompleteRequest<Autocomplete.LoginSaveOption> request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onLoginSelect(@NonNull GeckoSession session, @NonNull AutocompleteRequest<Autocomplete.LoginSelectOption> request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onAddressSave(@NonNull GeckoSession session, @NonNull AutocompleteRequest<Autocomplete.AddressSaveOption> request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onCreditCardSave(@NonNull GeckoSession session, @NonNull AutocompleteRequest<Autocomplete.CreditCardSaveOption> request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onCreditCardSelect(@NonNull GeckoSession session, @NonNull AutocompleteRequest<Autocomplete.CreditCardSelectOption> request) {
    // TODO: implement
    return null;
  }

  @Nullable
  @Override
  public GeckoResult<PromptResponse> onAddressSelect(@NonNull GeckoSession session, @NonNull AutocompleteRequest<Autocomplete.AddressSelectOption> request) {
    // TODO: implement
    return null;
  }

  public void dispose() {
    if (inAppGeckoView != null) {
      inAppGeckoView = null;
    }
  }
}
