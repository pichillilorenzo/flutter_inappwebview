/*
 * Copyright (C) 2025 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#include "MediaSessionGroupIdentifier.h"
#include "MediaUniqueIdentifier.h"
#include "NowPlayingMetadataObserver.h"
#include "PlatformMediaSessionTypes.h"
#include <wtf/LoggerHelper.h>
#include <wtf/ProcessID.h>
#include <wtf/ThreadSafeWeakPtr.h>
#include <wtf/WeakPtr.h>

namespace WebCore {

class Page;
class PlatformMediaSessionInterface;
struct MediaConfiguration;
struct NowPlayingInfo;
struct NowPlayingMetadata;

enum class MediaSessionRestriction : uint32_t {
    NoRestrictions = 0,
    ConcurrentPlaybackNotPermitted = 1 << 0,
    BackgroundProcessPlaybackRestricted = 1 << 1,
    BackgroundTabPlaybackRestricted = 1 << 2,
    InterruptedPlaybackNotPermitted = 1 << 3,
    InactiveProcessPlaybackRestricted = 1 << 4,
    SuspendedUnderLockPlaybackRestricted = 1 << 5,
};
using MediaSessionRestrictions = OptionSet<MediaSessionRestriction>;

class MediaSessionManagerInterface
    : public ThreadSafeRefCountedAndCanMakeThreadSafeWeakPtr<MediaSessionManagerInterface>
#if !RELEASE_LOG_DISABLED
    , private LoggerHelper
#endif
{
public:
    WEBCORE_EXPORT MediaSessionManagerInterface() = default;
    WEBCORE_EXPORT virtual ~MediaSessionManagerInterface() = default;

    virtual void addSession(PlatformMediaSessionInterface&) = 0;
    virtual void removeSession(PlatformMediaSessionInterface&) = 0;

    virtual bool activeAudioSessionRequired() const = 0;
    virtual bool hasActiveAudioSession() const = 0;
    virtual bool canProduceAudio() const = 0;

    virtual void setShouldDeactivateAudioSession(bool) = 0;
    virtual bool shouldDeactivateAudioSession() = 0;

    virtual void updateNowPlayingInfoIfNecessary() = 0;
    virtual void updateAudioSessionCategoryIfNecessary() = 0;

    virtual std::optional<NowPlayingInfo> nowPlayingInfo() const = 0;
    virtual bool hasActiveNowPlayingSession() const { return false; }
    virtual String lastUpdatedNowPlayingTitle() const { return emptyString(); }
    virtual double lastUpdatedNowPlayingDuration() const { return NAN; }
    virtual double lastUpdatedNowPlayingElapsedTime() const { return NAN; }
    virtual std::optional<MediaUniqueIdentifier> lastUpdatedNowPlayingInfoUniqueIdentifier() const { return std::nullopt; }
    virtual void addNowPlayingMetadataObserver(const NowPlayingMetadataObserver&) = 0;
    virtual void removeNowPlayingMetadataObserver(const NowPlayingMetadataObserver&) = 0;
    virtual bool hasActiveNowPlayingSessionInGroup(std::optional<MediaSessionGroupIdentifier>) = 0;
    virtual bool registeredAsNowPlayingApplication() const { return false; }
    virtual bool haveEverRegisteredAsNowPlayingApplication() const { return false; }
    virtual void resetHaveEverRegisteredAsNowPlayingApplicationForTesting() { };

    virtual void prepareToSendUserMediaPermissionRequestForPage(Page&) { }

    virtual bool willIgnoreSystemInterruptions() const = 0;
    virtual void setWillIgnoreSystemInterruptions(bool) = 0;
    virtual void beginInterruption(PlatformMediaSessionInterruptionType) = 0;
    virtual void endInterruption(PlatformMediaSessionEndInterruptionFlags) = 0;

    virtual void applicationWillEnterForeground(bool) = 0;
    virtual void applicationDidEnterBackground(bool) = 0;
    virtual void applicationWillBecomeInactive() = 0;
    virtual void applicationDidBecomeActive() = 0;
    virtual void processWillSuspend() = 0;
    virtual void processDidResume() = 0;

    virtual void stopAllMediaPlaybackForProcess() = 0;
    virtual bool mediaPlaybackIsPaused(std::optional<MediaSessionGroupIdentifier>) = 0;
    virtual void pauseAllMediaPlaybackForGroup(std::optional<MediaSessionGroupIdentifier>) = 0;
    virtual void suspendAllMediaPlaybackForGroup(std::optional<MediaSessionGroupIdentifier>) = 0;
    virtual void resumeAllMediaPlaybackForGroup(std::optional<MediaSessionGroupIdentifier>) = 0;
    virtual void suspendAllMediaBufferingForGroup(std::optional<MediaSessionGroupIdentifier>) = 0;
    virtual void resumeAllMediaBufferingForGroup(std::optional<MediaSessionGroupIdentifier>) = 0;

    virtual void addRestriction(PlatformMediaSessionMediaType, MediaSessionRestrictions) = 0;
    virtual void removeRestriction(PlatformMediaSessionMediaType, MediaSessionRestrictions) = 0;
    virtual MediaSessionRestrictions restrictions(PlatformMediaSessionMediaType) = 0;
    virtual void resetRestrictions() = 0;

    virtual bool sessionWillBeginPlayback(PlatformMediaSessionInterface&) = 0;
    virtual void sessionWillEndPlayback(PlatformMediaSessionInterface&, DelayCallingUpdateNowPlaying) = 0;
    virtual void sessionStateChanged(PlatformMediaSessionInterface&) = 0;
    virtual void sessionDidEndRemoteScrubbing(PlatformMediaSessionInterface&) { }
    virtual void sessionCanProduceAudioChanged() = 0;
    virtual void clientCharacteristicsChanged(PlatformMediaSessionInterface&, bool) { }

    virtual void configureWirelessTargetMonitoring() { }
    virtual bool hasWirelessTargetsAvailable() { return false; }
    virtual bool isMonitoringWirelessTargets() const { return false; }
    virtual void sessionIsPlayingToWirelessPlaybackTargetChanged(PlatformMediaSessionInterface&) = 0;

    virtual void setCurrentSession(PlatformMediaSessionInterface&) = 0;
    virtual RefPtr<PlatformMediaSessionInterface> currentSession() const = 0;

    virtual void setIsPlayingToAutomotiveHeadUnit(bool) = 0;
    virtual bool isPlayingToAutomotiveHeadUnit() const = 0;

    virtual void setSupportsSpatialAudioPlayback(bool) = 0;
    virtual std::optional<bool> supportsSpatialAudioPlaybackForConfiguration(const MediaConfiguration&) = 0;

    virtual void addAudioCaptureSource(AudioCaptureSource&) = 0;
    virtual void removeAudioCaptureSource(AudioCaptureSource&) = 0;
    virtual void audioCaptureSourceStateChanged() = 0;
    virtual size_t audioCaptureSourceCount() const = 0;

    virtual void processDidReceiveRemoteControlCommand(PlatformMediaSessionRemoteControlCommandType, const PlatformMediaSessionRemoteCommandArgument&) = 0;
    virtual bool processIsSuspended() const = 0;
    virtual void processSystemWillSleep() = 0;
    virtual void processSystemDidWake() = 0;

    virtual bool isApplicationInBackground() const = 0;
    virtual bool isInterrupted() const = 0;
    virtual bool hasNoSession() const = 0;

    virtual void addSupportedCommand(PlatformMediaSessionRemoteControlCommandType) { };
    virtual void removeSupportedCommand(PlatformMediaSessionRemoteControlCommandType) { };
    virtual PlatformMediaSessionRemoteCommandsSet supportedCommands() const { return { }; };

    virtual void scheduleSessionStatusUpdate() { }
    virtual void resetSessionState() { };

    virtual WeakPtr<PlatformMediaSessionInterface> bestEligibleSessionForRemoteControls(NOESCAPE const Function<bool(const PlatformMediaSessionInterface&)>&, PlatformMediaSessionPlaybackControlsPurpose) = 0;

    virtual void updatePresentingApplicationPIDIfNecessary(ProcessID) { }
};

} // namespace WebCore
