#pragma once

namespace flutter_inappwebview_plugin
{
  // Decides whether a captured frame is worth comparing with the previous one.
  // On some systems Windows.Graphics.Capture delivers a frame on every
  // compositor tick, and the comparison saves a redraw for each identical one.
  // Elsewhere frames arrive only on change, every comparison says "differs"
  // and its GPU wait is pure cost; a run of such results pauses comparing for
  // a while, after which it is retried.
  class FrameCompareGate {
  public:
    explicit FrameCompareGate(int differingToPause = 4, int pausedFrames = 120)
      : differingToPause_(differingToPause), pausedFrames_(pausedFrames) {}

    bool shouldCompare()
    {
      if (paused_ > 0) {
        --paused_;
        return false;
      }
      return true;
    }

    void recordResult(bool differ)
    {
      if (!differ) {
        differing_ = 0;
        return;
      }
      if (++differing_ >= differingToPause_) {
        differing_ = 0;
        paused_ = pausedFrames_;
      }
    }

    // A new size or a resumed capture: compare again from the next frame.
    void reset()
    {
      differing_ = 0;
      paused_ = 0;
    }

  private:
    const int differingToPause_;
    const int pausedFrames_;
    int differing_ = 0;
    int paused_ = 0;
  };
}
