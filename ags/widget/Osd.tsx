import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { interval, timeout, Timer } from "ags/time"
import GLib from "gi://GLib"
import Pango from "gi://Pango"
import Wp from "gi://AstalWp"
import Mpris from "gi://AstalMpris"

type Mode = "volume" | "mic" | "backlight" | "media"

const HIDE_AFTER = { volume: 1800, mic: 1800, backlight: 1800, media: 3500 }
const HIDE_AFTER_HOVER = 1200 // after the pointer leaves the pill
const USER_GRACE = 500 // ms to stop live updates from fighting a drag

let win: Astal.Window
let mode: Mode = "volume"
let player: Mpris.Player | null = null
let hideTimer: Timer | null = null
let tickTimer: Timer | null = null
let hovered = false
let lastUserChange = 0

// Shared
let hoverArea: Gtk.Overlay

// Volume / mic / backlight card
let levelCard: Gtk.Box
let levelIcon: Gtk.Image
let levelPct: Gtk.Label
let levelBar: Gtk.Scale

// Media card
let mediaCard: Gtk.Box
let coverBox: Gtk.Box
let cover: Gtk.Image
let coverFallback: Gtk.Image
let coverPath = ""
let badgeIcon: Gtk.Image
let mediaState: Gtk.Label
let mediaTitle: Gtk.Label
let mediaArtist: Gtk.Label
let mediaProgress: Gtk.ProgressBar
let mediaTime: Gtk.Label

const toggleClass = (w: Gtk.Widget, name: string, on: boolean) =>
  on ? w.add_css_class(name) : w.remove_css_class(name)

const fmtTime = (s: number) => {
  if (!(s > 0)) return "0:00"
  const m = Math.floor(s / 60)
  return `${m}:${String(Math.floor(s % 60)).padStart(2, "0")}`
}

function volumeIcon(pct: number, muted: boolean) {
  if (muted || pct === 0) return "audio-volume-muted-symbolic"
  if (pct <= 33) return "audio-volume-low-symbolic"
  if (pct <= 66) return "audio-volume-medium-symbolic"
  return "audio-volume-high-symbolic"
}

function setLevel(pct: number) {
  // Don't move the slider under the user's pointer while they drag
  if (Date.now() - lastUserChange > USER_GRACE) levelBar.set_value(Math.min(pct, 100) / 100)
  levelPct.label = `${pct}%`
  toggleClass(levelCard, "over", pct > 100)
}

/* ---------- Backlight (sysfs read, brightnessctl write) ---------- */

function backlightDir() {
  const dir = firstEntry("/sys/class/backlight")
  return dir ? `/sys/class/backlight/${dir}` : null
}

function firstEntry(path: string): string | null {
  try {
    const d = GLib.Dir.open(path, 0)
    const name = d.read_name()
    d.close()
    return name
  } catch {
    return null
  }
}

function readInt(path: string) {
  const [ok, bytes] = GLib.file_get_contents(path)
  return ok ? parseInt(new TextDecoder().decode(bytes)) : NaN
}

function backlightPct() {
  const dir = backlightDir()
  if (!dir) return null
  const cur = readInt(`${dir}/brightness`)
  const max = readInt(`${dir}/max_brightness`)
  return max > 0 ? Math.round((cur / max) * 100) : null
}

// Only one brightnessctl at a time; remember the latest value while busy
let backlightBusy = false
let backlightPending: number | null = null
function setBacklight(pct: number) {
  if (backlightBusy) {
    backlightPending = pct
    return
  }
  backlightBusy = true
  execAsync(["brightnessctl", "-q", "s", `${pct}%`])
    .catch(console.error)
    .finally(() => {
      backlightBusy = false
      if (backlightPending !== null) {
        const next = backlightPending
        backlightPending = null
        setBacklight(next)
      }
    })
}

/* ---------- Updates ---------- */

function updateVolume() {
  const speaker = Wp.get_default()?.audio.defaultSpeaker
  if (!speaker) return
  const pct = Math.round(speaker.volume * 100)
  const muted = speaker.mute
  levelIcon.iconName = volumeIcon(pct, muted)
  setLevel(pct)
  toggleClass(levelCard, "muted", muted)
}

function updateMic() {
  const mic = Wp.get_default()?.audio.defaultMicrophone
  if (!mic) return
  const muted = mic.mute
  levelIcon.iconName = muted
    ? "microphone-sensitivity-muted-symbolic"
    : "audio-input-microphone-symbolic"
  setLevel(Math.round(mic.volume * 100))
  toggleClass(levelCard, "muted", muted)
}

function updateBacklight() {
  const pct = backlightPct()
  if (pct === null) return
  levelIcon.iconName = "display-brightness-symbolic"
  setLevel(pct)
  toggleClass(levelCard, "muted", false)
}

function updateMedia() {
  if (!player) return
  const playing = player.playbackStatus === Mpris.PlaybackStatus.PLAYING

  mediaTitle.label = player.title || "Unknown title"
  mediaArtist.label = player.artist || player.identity || ""
  mediaState.label = playing ? "Now playing" : "Paused"
  badgeIcon.iconName = playing
    ? "media-playback-start-symbolic"
    : "media-playback-pause-symbolic"
  toggleClass(mediaCard, "paused", !playing)
  toggleClass(coverBox, "spinning", playing)

  const art = player.coverArt ?? ""
  if (art !== coverPath) {
    coverPath = art
    const hasArt = art !== "" && GLib.file_test(art, GLib.FileTest.EXISTS)
    if (hasArt) cover.set_from_file(art)
    cover.visible = hasArt
    coverFallback.visible = !hasArt
  }

  const length = player.length
  const position = Math.max(0, player.position)
  const known = length > 0
  mediaProgress.fraction = known ? Math.min(position / length, 1) : 0
  mediaTime.label = known ? `${fmtTime(position)} / ${fmtTime(length)}` : fmtTime(position)
}

function update() {
  if (mode === "volume") updateVolume()
  else if (mode === "mic") updateMic()
  else if (mode === "backlight") updateBacklight()
  else updateMedia()
}

// The user dragged or scrolled the slider
function onUserLevel(value: number) {
  lastUserChange = Date.now()
  const v = Math.max(0, Math.min(1, value))
  const pct = Math.round(v * 100)
  levelPct.label = `${pct}%`

  const audio = Wp.get_default()?.audio
  if (mode === "volume" && audio?.defaultSpeaker) {
    audio.defaultSpeaker.volume = v
    if (audio.defaultSpeaker.mute && v > 0) audio.defaultSpeaker.mute = false
  } else if (mode === "mic" && audio?.defaultMicrophone) {
    audio.defaultMicrophone.volume = v
    if (audio.defaultMicrophone.mute && v > 0) audio.defaultMicrophone.mute = false
  } else if (mode === "backlight") {
    setBacklight(Math.max(1, pct)) // never fully black
  }
}

/* ---------- Showing / hiding ---------- */

function scheduleHide(ms: number) {
  hideTimer?.cancel()
  hideTimer = hovered ? null : timeout(ms, hide)
}

function hide() {
  hideTimer?.cancel()
  hideTimer = null
  tickTimer?.cancel()
  tickTimer = null
  hovered = false
  hoverArea.remove_css_class("hover")
  win.visible = false
}

function show(next: Mode) {
  mode = next
  levelCard.visible = mode !== "media"
  mediaCard.visible = mode === "media"
  update()
  win.visible = true

  // Keep values live while visible (track changes, other volume sources)
  if (!tickTimer) tickTimer = interval(250, update)
  scheduleHide(HIDE_AFTER[mode])
}

export const showVolume = () => show("volume")
export const showMic = () => show("mic")
export const showBacklight = () => show("backlight")

export function showMedia(name?: string) {
  const players = Mpris.get_default().players
  player =
    (name && players.find((p) => p.busName.includes(`.${name}`))) ||
    players.find((p) => p.playbackStatus === Mpris.PlaybackStatus.PLAYING) ||
    players[0] ||
    null
  if (!player) return false
  show("media")
  return true
}

export default function Osd() {
  // Start watching players now; the list fills in asynchronously
  Mpris.get_default()

  const { CENTER, START, END } = Gtk.Align
  const VERTICAL = Gtk.Orientation.VERTICAL

  const setupHover = (self: Gtk.Overlay) => {
    hoverArea = self
    const motion = new Gtk.EventControllerMotion()
    motion.connect("enter", () => {
      hovered = true
      self.add_css_class("hover")
      hideTimer?.cancel()
      hideTimer = null
    })
    motion.connect("leave", () => {
      hovered = false
      self.remove_css_class("hover")
      if (win.visible) scheduleHide(HIDE_AFTER_HOVER)
    })
    self.add_controller(motion)
  }

  const setupSlider = (self: Gtk.Scale) => {
    levelBar = self
    self.set_range(0, 1)
    self.set_increments(0.01, 0.05)
    self.connect("change-value", (_scale, _scroll, value) => {
      onUserLevel(value)
      return false
    })
  }

  return (
    <window
      $={(self) => (win = self)}
      name="osd"
      namespace="ags-osd"
      class="Osd"
      application={app}
      visible={false}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.NONE}
      anchor={Astal.WindowAnchor.TOP}
      marginTop={6}
    >
      <Gtk.Overlay $={setupHover}>
        <box class="osd-wrap">
          {/* Volume / microphone / backlight */}
          <box $={(self) => (levelCard = self)} class="osd-card osd-level" spacing={10}>
            <box class="osd-icon" valign={CENTER}>
              <image
                $={(self) => (levelIcon = self)}
                pixelSize={14}
                hexpand
                vexpand
                halign={CENTER}
                valign={CENTER}
              />
            </box>
            <Gtk.Scale
              $={setupSlider}
              class="osd-bar"
              widthRequest={190}
              valign={CENTER}
              drawValue={false}
            />
            <label
              $={(self) => (levelPct = self)}
              class="osd-pct"
              valign={CENTER}
              xalign={1}
              widthChars={4}
            />
          </box>

          {/* Media */}
          <box
            $={(self) => (mediaCard = self)}
            class="osd-card osd-media"
            spacing={10}
            visible={false}
          >
            <Gtk.Overlay valign={CENTER}>
              <box
                $={(self) => {
                  coverBox = self
                  self.overflow = Gtk.Overflow.HIDDEN
                }}
                class="osd-cover"
                widthRequest={46}
                heightRequest={46}
              >
                <image
                  $={(self) => (cover = self)}
                  pixelSize={46}
                  hexpand
                  vexpand
                  visible={false}
                />
                <image
                  $={(self) => (coverFallback = self)}
                  iconName="audio-x-generic-symbolic"
                  pixelSize={20}
                  hexpand
                  vexpand
                  halign={CENTER}
                  valign={CENTER}
                />
              </box>
              <box $type="overlay" class="osd-badge" halign={END} valign={END}>
                <image $={(self) => (badgeIcon = self)} pixelSize={8} hexpand halign={CENTER} />
              </box>
            </Gtk.Overlay>

            <box orientation={VERTICAL} valign={CENTER} spacing={1} widthRequest={190}>
              <label $={(self) => (mediaState = self)} class="osd-state" xalign={0} />
              <label
                $={(self) => (mediaTitle = self)}
                class="osd-title"
                xalign={0}
                ellipsize={Pango.EllipsizeMode.END}
                maxWidthChars={24}
              />
              <label
                $={(self) => (mediaArtist = self)}
                class="osd-sub"
                xalign={0}
                ellipsize={Pango.EllipsizeMode.END}
                maxWidthChars={30}
              />
              <box spacing={8} class="osd-progress-row">
                <Gtk.ProgressBar
                  $={(self) => (mediaProgress = self)}
                  class="osd-progress"
                  hexpand
                  valign={CENTER}
                />
                <label $={(self) => (mediaTime = self)} class="osd-time" halign={START} />
              </box>
            </box>
          </box>
        </box>

        {/* Close button, shown while hovering */}
        <button
          $type="overlay"
          class="osd-close"
          halign={END}
          valign={START}
          tooltipText="Dismiss"
          onClicked={hide}
        >
          <image iconName="window-close-symbolic" pixelSize={8} />
        </button>
      </Gtk.Overlay>
    </window>
  )
}
