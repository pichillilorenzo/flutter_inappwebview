package com.pichillilorenzo.flutter_inappwebview.types;

public enum WebViewImplementation {
  NATIVE(0);

  private final int value;

  private WebViewImplementation(int value) {
    this.value = value;
  }

  public boolean equalsValue(int otherValue) {
    return value == otherValue;
  }

  public static WebViewImplementation fromValue(int value) {
    for( WebViewImplementation type : WebViewImplementation.values()) {
      if(value == type.value)
        return type;
    }
    throw new IllegalArgumentException("No enum constant: " + value);
  }

  public int rawValue() {
    return this.value;
  }

  @Override
  public String toString() {
    return String.valueOf(this.value);
  }
}