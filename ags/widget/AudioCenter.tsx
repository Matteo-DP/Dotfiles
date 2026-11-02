// Audio panel: pick output/input devices, set their volume, and control
// per-app volume. Opened from the waybar pulseaudio module.
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { For, With, createBinding, createComputed, createState, onCleanup, type Accessor } from "ags"
import { timeout } from "ags/time"
import Pango from "gi://Pango"
import Wp from "gi://AstalWp"
import Apps from "gi://AstalApps"

const TRANSITION = 160 // ms, slide-down of the panel

let win: Astal.Window
let revealer: Gtk.Revealer
let closing = false
let setAppsOpen: (open: boolean) => void = () => {}

function volumeIcon(volume: number, muted: boolean) {
  const pct = Math.round(volume * 100)
  if (muted || pct === 0) return "audio-volume-muted-symbolic"
  if (pct <= 33) return "audio-volume-low-symbolic"
  if (pct <= 66) return "audio-volume-medium-symbolic"
  return "audio-volume-high-symbolic"
}

function micIcon(_volume: number, muted: boolean) {
  return muted ? "microphone-sensitivity-muted-symbolic" : "audio-input-microphone-symbolic"
}

export function openAudio() {
  closing = false
  setAppsOpen(false) // Applications starts collapsed every time
  win.visible = true
  revealer.revealChild = true
}

export function closeAudio() {
  if (!win.visible || closing) return
  closing = true
  revealer.revealChild = false
  timeout(TRANSITION, () => {
    if (closing) win.visible = false
    closing = false
  })
}

export function toggleAudio() {
  win.visible && !closing ? closeAudio() : openAudio()
}

/* ---------- Building blocks ---------- */

// "500 Series ... (HD Audio) Speaker" -> "Speaker": drop the sound card's name
function shortName(ep: Wp.Endpoint) {
  const full = ep.description ?? ""
  const card = ep.device?.description ?? ""
  if (card && full.startsWith(card) && full.length > card.length) {
    return full.slice(card.length).trim()
  }
  return full
}

// Application name and icon for an audio stream.
// Streams rarely carry an icon, so fall back to the app's desktop entry.
const apps = new Apps.Apps()

function appInfo(stream: Wp.Stream): { name: string; icon: string | null } {
  const prop = (key: string) => stream.get_pw_property(key) ?? ""
  const name = prop("application.name") || stream.name || stream.description || "Unknown"
  const theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default()!)
  const has = (icon?: string | null) => !!icon && theme.has_icon(icon)
  // AstalWp hands out generic placeholders when it knows no real icon
  const generic = (icon?: string | null) => !icon || /^(application-x-executable|audio-)/.test(icon)

  for (const icon of [stream.icon, prop("application.icon-name")])
    if (!generic(icon) && has(icon)) return { name, icon }

  const keys = [name, prop("application.process.binary"), prop("node.name")]
    .map((k) => k.toLowerCase())
    .filter((k) => k !== "")
  const entry = apps.list.find(
    (a) =>
      keys.includes(a.name.toLowerCase()) ||
      keys.some((k) => a.entry.toLowerCase().startsWith(k) || a.executable.toLowerCase().includes(k)),
  )
  if (has(entry?.iconName)) return { name, icon: entry!.iconName }

  for (const icon of keys) if (has(icon)) return { name, icon }
  return { name, icon: null }
}

// Same flat bar as the OSD, draggable, bound to a node's volume
function VolumeSlider({ node }: { node: Wp.Node }) {
  let lastUser = 0
  return (
    <Gtk.Scale
      class="osd-bar"
      hexpand
      valign={Gtk.Align.CENTER}
      drawValue={false}
      $={(self) => {
        self.set_range(0, 1)
        self.set_increments(0.01, 0.05)
        self.set_value(Math.min(node.volume, 1))
        const id = node.connect("notify::volume", () => {
          if (Date.now() - lastUser > 300) self.set_value(Math.min(node.volume, 1))
        })
        onCleanup(() => node.disconnect(id))
        self.connect("change-value", (_s, _scroll, value) => {
          lastUser = Date.now()
          const v = Math.max(0, Math.min(1, value))
          node.volume = v
          if (node.mute && v > 0) node.mute = false
          return false
        })
      }}
    />
  )
}

// Mute button + slider + percentage.
// For apps the button shows the app's icon (or its name) instead of a speaker.
function VolumeRow({
  node,
  icon,
  appName,
  appIcon,
}: {
  node: Wp.Node
  icon?: (volume: number, muted: boolean) => string
  appName?: string
  appIcon?: string | null
}) {
  const volume = createBinding(node, "volume")
  const mute = createBinding(node, "mute")
  return (
    <box class={mute.as((m) => (m ? "volume-row muted" : "volume-row"))} spacing={10}>
      <button
        class={appName === undefined ? "mute-button" : appIcon ? "mute-button app" : "mute-button app named"}
        tooltipText={
          appName !== undefined ? appName : mute.as((m) => (m ? "Unmute" : "Mute"))
        }
        onClicked={() => (node.mute = !node.mute)}
      >
        {appName === undefined ? (
          <image iconName={createComputed(() => icon!(volume(), mute()))} pixelSize={14} />
        ) : appIcon ? (
          <image iconName={appIcon} pixelSize={18} />
        ) : (
          <label label={appName} maxWidthChars={8} ellipsize={Pango.EllipsizeMode.END} />
        )}
      </button>
      <VolumeSlider node={node} />
      <label
        class="pct"
        widthChars={4}
        xalign={1}
        label={volume.as((v) => `${Math.round(v * 100)}%`)}
      />
    </box>
  )
}

// Selectable device list (outputs or inputs)
function DeviceList({ devices }: { devices: Accessor<Wp.Endpoint[]> }) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="device-list">
      <For each={devices}>
        {(ep: Wp.Endpoint) => {
          const isDefault = createBinding(ep, "isDefault")
          return (
            <button
              class={isDefault.as((d) => (d ? "device active" : "device"))}
              onClicked={() => ep.set_is_default(true)}
            >
              <box spacing={10}>
                <box class="radio" valign={Gtk.Align.CENTER} />
                <label
                  label={createBinding(ep, "description").as(() => shortName(ep))}
                  tooltipText={createBinding(ep, "description")}
                  xalign={0}
                  hexpand
                  maxWidthChars={1}
                  ellipsize={Pango.EllipsizeMode.END}
                />
              </box>
            </button>
          )
        }}
      </For>
    </box>
  )
}

function Section({ title, children }: { title: string; children: JSX.Element | JSX.Element[] }) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="section" spacing={6}>
      <label class="section-title" label={title} xalign={0} />
      {children}
    </box>
  )
}

// Collapsible per-app volume list (collapsed by default)
function AppsSection({ streams }: { streams: Accessor<Wp.Stream[]> }) {
  const [open, setOpen] = createState(false)
  setAppsOpen = setOpen
  const VERTICAL = Gtk.Orientation.VERTICAL

  return (
    <box orientation={VERTICAL} class="section">
      <button class="section-toggle" onClicked={() => setOpen(!open.peek())}>
        <box spacing={6}>
          <label class="section-title" label="Applications" xalign={0} />
          {/* While collapsed, show which apps are playing */}
          <box spacing={4} hexpand halign={Gtk.Align.END} visible={open.as((o) => !o)}>
            <For each={streams}>
              {(stream: Wp.Stream) => {
                const { name, icon } = appInfo(stream)
                return icon ? (
                  <image class="app-peek" iconName={icon} pixelSize={14} tooltipText={name} />
                ) : (
                  <label class="app-peek" label={name} />
                )
              }}
            </For>
          </box>
          <image
            class="chevron"
            hexpand={open}
            halign={Gtk.Align.END}
            iconName={open.as((o) => (o ? "pan-down-symbolic" : "pan-end-symbolic"))}
            pixelSize={12}
          />
        </box>
      </button>
      <revealer
        revealChild={open}
        transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        transitionDuration={150}
      >
        <box orientation={VERTICAL} spacing={8} class="apps-list">
          <label
            class="empty"
            label="No apps are playing audio"
            xalign={0}
            visible={streams.as((s) => s.length === 0)}
          />
          <For each={streams}>
            {(stream: Wp.Stream) => {
              const { name, icon } = appInfo(stream)
              return <VolumeRow node={stream} appName={name} appIcon={icon} />
            }}
          </For>
        </box>
      </revealer>
    </box>
  )
}

/* ---------- Window ---------- */

export default function AudioCenter() {
  const audio = Wp.get_default()!.audio
  const speakers = createBinding(audio, "speakers")
  const microphones = createBinding(audio, "microphones")
  const streams = createBinding(audio, "streams")
  const { TOP, RIGHT, BOTTOM, LEFT } = Astal.WindowAnchor
  const VERTICAL = Gtk.Orientation.VERTICAL

  return (
    <window
      $={(self) => {
        win = self
        // Escape closes
        const keys = new Gtk.EventControllerKey()
        keys.connect("key-pressed", (_c, keyval) => {
          if (keyval === Gdk.KEY_Escape) closeAudio()
          return false
        })
        self.add_controller(keys)
      }}
      name="audio"
      namespace="ags-audio"
      class="AudioCenter"
      application={app}
      visible={false}
      layer={Astal.Layer.TOP}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={TOP | RIGHT | BOTTOM | LEFT}
    >
      <Gtk.Overlay>
        {/* Transparent backdrop: clicking outside the panel closes it */}
        <box
          hexpand
          vexpand
          $={(self) => {
            const click = new Gtk.GestureClick()
            click.connect("released", () => closeAudio())
            self.add_controller(click)
          }}
        />
        <revealer
          $type="overlay"
          $={(self) => (revealer = self)}
          halign={Gtk.Align.END}
          valign={Gtk.Align.START}
          transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
          transitionDuration={TRANSITION}
        >
          <box class="audio-panel" orientation={VERTICAL} spacing={14} widthRequest={340}>
            <Section title="Output">
              <With value={createBinding(audio, "defaultSpeaker")}>
                {(sp: Wp.Endpoint | null) => (sp ? <VolumeRow node={sp} icon={volumeIcon} /> : <box />)}
              </With>
              <DeviceList devices={speakers} />
            </Section>

            <Section title="Input">
              <With value={createBinding(audio, "defaultMicrophone")}>
                {(mic: Wp.Endpoint | null) => (mic ? <VolumeRow node={mic} icon={micIcon} /> : <box />)}
              </With>
              <DeviceList devices={microphones} />
            </Section>

            <AppsSection streams={streams} />
          </box>
        </revealer>
      </Gtk.Overlay>
    </window>
  )
}
