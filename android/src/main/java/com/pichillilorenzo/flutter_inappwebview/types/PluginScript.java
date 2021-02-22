package com.pichillilorenzo.flutter_inappwebview.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class PluginScript extends UserScript {
  private boolean requiredInAllContentWorlds;

  public PluginScript(@Nullable String groupName, @NonNull String source, @NonNull UserScriptInjectionTime injectionTime, @Nullable ContentWorld contentWorld, boolean requiredInAllContentWorlds) {
    super(groupName, source, injectionTime, contentWorld);
    this.requiredInAllContentWorlds = requiredInAllContentWorlds;
  }

  public boolean isRequiredInAllContentWorlds() {
    return requiredInAllContentWorlds;
  }

  public void setRequiredInAllContentWorlds(boolean requiredInAllContentWorlds) {
    this.requiredInAllContentWorlds = requiredInAllContentWorlds;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    if (!super.equals(o)) return false;

    PluginScript that = (PluginScript) o;

    return requiredInAllContentWorlds == that.requiredInAllContentWorlds;
  }

  @Override
  public int hashCode() {
    int result = super.hashCode();
    result = 31 * result + (requiredInAllContentWorlds ? 1 : 0);
    return result;
  }

  @Override
  public String toString() {
    return "PluginScript{" +
            "requiredInContentWorld=" + requiredInAllContentWorlds +
            "} " + super.toString();
  }
}
